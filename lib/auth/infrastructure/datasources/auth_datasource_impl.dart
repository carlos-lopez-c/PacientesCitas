import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

import 'package:paciente_citas_1/auth/domain/datasources/auth_datasource.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_information_entities.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_register.dart';
import 'package:paciente_citas_1/auth/infrastructure/services/auth_session_service.dart';
import 'package:paciente_citas_1/shared/infrastructure/errors/handle_error.dart';
import 'package:paciente_citas_1/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_entities.dart';

class FirebaseAuthDatasource implements AuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final AuthSessionService _sessionService;

  FirebaseAuthDatasource() {
    _sessionService = AuthSessionService(KeyValueStorageServiceImpl());
  }

  /// Formatea el número de teléfono al formato E.164
  String _formatPhoneNumber(String phoneNumber) {
    // Eliminar todos los caracteres no numéricos
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Si el número no comienza con el código de país, agregarlo
    if (!cleanedNumber.startsWith('593')) {
      cleanedNumber = '593$cleanedNumber';
    }

    // Agregar el prefijo '+' requerido por E.164
    return '+$cleanedNumber';
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseException(
            plugin: 'auth',
            code: 'user-null',
            message: 'Error al obtener los datos del usuario.');
      }

      // Obtener los datos del usuario
      final userData = await _fetchUserData(user.uid);

      // Verificar si el usuario tiene teléfono registrado
      if (userData.userInformation.phone == null ||
          userData.userInformation.phone!.isEmpty) {
        // Si no tiene teléfono, cerrar sesión
        await _firebaseAuth.signOut();
        throw FirebaseException(
            plugin: 'auth',
            code: 'no-phone',
            message:
                'Se requiere un número de teléfono para la autenticación de dos factores.');
      }

      return userData;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<bool> register(RequestData requestData) async {
    try {
      // Validar que el número de teléfono sea único ANTES de crear el usuario
      final phoneNumber = requestData.createUser.userInformation.phone;
      if (phoneNumber.isNotEmpty) {
        final isPhoneUnique = await _validatePhoneUniqueness(phoneNumber);
        if (!isPhoneUnique) {
          throw FirebaseException(
            plugin: 'auth',
            code: 'phone-already-exists',
            message:
                'Este número de teléfono ya está registrado con otra cuenta.',
          );
        } else {
          final userCredential =
              await _firebaseAuth.createUserWithEmailAndPassword(
            email: requestData.createUser.email,
            password: requestData.createUser.password,
          );

          final user = userCredential.user;
          if (user == null) {
            throw FirebaseException(
                plugin: 'auth',
                code: 'user-null',
                message: 'Error al crear el usuario.');
          }

          await _createUserInFirestore(user.uid, requestData);
          return true;
        }
      } else {
        throw FirebaseException(
          plugin: 'auth',
          code: 'no-phone-registered',
          message:
              'Se requiere un número de teléfono para la autenticación de dos factores.',
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<User> checkAuthStatus() async {
    try {
      // 🔥 Fast path: verificar inmediatamente si hay usuario
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        // Limpiar sesión de forma asíncrona pero no esperar
        _sessionService
            .clearSession()
            .catchError((e) => print('Error clearing session: $e'));
        throw FirebaseException(
            plugin: 'auth',
            code: 'no-auth',
            message: 'No hay usuario autenticado.');
      }

      // Verificar estado de sesión primero (más rápido que Firestore)
      final has2FACompleted =
          await _sessionService.hasTwoFactorCompleted(user.uid);
      final hasValidSession = await _sessionService.hasValidSession();

      // Si ya completó 2FA y tiene sesión válida, solo obtener datos del usuario
      if (has2FACompleted && hasValidSession) {
        print('✅ User already authenticated with 2FA, session valid');
        final userData = await _fetchUserData(user.uid);
        return userData;
      }

      // Obtener los datos del usuario para verificar si necesita 2FA
      final userData = await _fetchUserData(user.uid);

      // Si el usuario tiene teléfono registrado y NO ha completado 2FA, requerir 2FA
      if (userData.userInformation.phone != null &&
          userData.userInformation.phone!.isNotEmpty &&
          !has2FACompleted) {
        print('🔐 User requires 2FA verification');
        throw FirebaseException(
            plugin: 'auth',
            code: 'requires-2fa',
            message: 'Se requiere autenticación de dos factores.');
      }

      // Si no tiene teléfono registrado, marcar sesión como válida
      if (userData.userInformation.phone == null ||
          userData.userInformation.phone!.isEmpty) {
        await _sessionService.setTwoFactorCompleted(user.uid);
      }

      return userData;
    } catch (e) {
      if (e is FirebaseException && e.code == 'requires-2fa') {
        rethrow;
      }
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Verificar si el correo existe en Firestore antes de enviar el reset
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'email-not-registered',
          message: 'El correo electrónico no está registrado.',
        );
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // Obtener los datos del usuario sin verificar 2FA
      final userData = await _fetchUserData(user.uid);
      return userData;
    } catch (e) {
      print("❌ Error getting current user: $e");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _sessionService.clearSession();
      print("✅ Sesión cerrada y estado limpiado");
    } catch (e) {
      print("❌ Error cerrando sesión: $e");
      // Limpiar sesión aunque falle Firebase signOut
      await _sessionService.clearSession();
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<String> sendPhoneVerification(String phoneNumber) async {
    try {
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
      print('Enviando verificación a: $formattedPhoneNumber');

      final completer = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          try {
            await _firebaseAuth.signInWithCredential(credential);
            if (!completer.isCompleted) completer.complete('');
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          print('Error de verificación: ${e.message}');
          if (!completer.isCompleted) {
            final customError =
                FirebaseErrorHandler.handleFirebaseAuthException(e);
            completer.completeError(customError);
          }
        },
        codeSent: (String id, int? resendToken) {
          print('Código enviado. ID: $id');
          if (!completer.isCompleted) completer.complete(id);
        },
        codeAutoRetrievalTimeout: (String id) {
          print('Timeout de recuperación automática. ID: $id');
        },
      );

      final verificationId = await completer.future;
      if (verificationId.isEmpty) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'verification-failed',
          message: 'No se pudo obtener el ID de verificación',
        );
      }

      return verificationId;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Error en sendPhoneVerification: $e');
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      print('Error en sendPhoneVerification: $e');
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<bool> verifyPhoneCode(String verificationId, String code) async {
    try {
      print("🔐 Verifying phone code: $code");
      print("🔐 Verification ID: $verificationId");

      // Crear credencial con el código proporcionado
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      // Verificar si hay un usuario ya autenticado por correo
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null &&
          currentUser.email != null &&
          currentUser.email!.isNotEmpty) {
        // Si hay un usuario con correo, vincular las credenciales de teléfono
        try {
          // Intentar vincular las credenciales - esto VALIDARÁ el código automáticamente
          await currentUser.linkWithCredential(credential);
          print("✅ Phone credential linked successfully");

          // Marcar 2FA como completado en la sesión
          await _sessionService.setTwoFactorCompleted(currentUser.uid);
          return true;
        } on firebase_auth.FirebaseAuthException catch (linkError) {
          print(
              "❌ Error linking credential: ${linkError.code} - ${linkError.message}");

          if (linkError.code == 'provider-already-linked') {
            // El teléfono ya está vinculado - usar reauthenticate para validar el código
            print(
                "📱 Phone already linked - validating code via reauthentication");

            try {
              // Re-autenticar con el código - esto VALIDARÁ el código sin desvincular
              await currentUser.reauthenticateWithCredential(credential);
              print("✅ Code validated successfully via reauthentication");

              await _sessionService.setTwoFactorCompleted(currentUser.uid);
              return true;
            } on firebase_auth.FirebaseAuthException catch (reauthError) {
              print(
                  "❌ Reauthentication failed: ${reauthError.code} - ${reauthError.message}");
              // Si reauthenticate falla, el código es definitivamente inválido
              throw FirebaseErrorHandler.handleFirebaseAuthException(
                  reauthError);
            }
          } else {
            // Otros errores (incluidos códigos inválidos)
            throw FirebaseErrorHandler.handleFirebaseAuthException(linkError);
          }
        }
      } else {
        // Si no hay un usuario autenticado por correo, hacer el login normal con teléfono
        try {
          final userCredential =
              await _firebaseAuth.signInWithCredential(credential);
          if (userCredential.user != null) {
            print("✅ Phone sign in successful");
            await _sessionService
                .setTwoFactorCompleted(userCredential.user!.uid);
            return true;
          } else {
            throw FirebaseException(
              plugin: 'auth',
              code: 'sign-in-failed',
              message: 'Error en la autenticación con credencial',
            );
          }
        } on firebase_auth.FirebaseAuthException catch (signInError) {
          print(
              "❌ Error in signInWithCredential: ${signInError.code} - ${signInError.message}");
          throw FirebaseErrorHandler.handleFirebaseAuthException(signInError);
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      print("❌ FirebaseException: ${e.code} - ${e.message}");
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      print("❌ PlatformException: $e");
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      print("❌ Generic Error: $e");
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<String> resendPhoneCode(String phoneNumber) async {
    try {
      return await sendPhoneVerification(phoneNumber);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    try {
      print('Enviando verificación a: $email');
      print('currentUser: ${_firebaseAuth.currentUser}');

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'no-user',
          message: 'No hay usuario autenticado',
        );
      }

      // Generar un código de verificación de 6 dígitos
      final verificationCode = (100000 + Random().nextInt(900000)).toString();

      // Guardar el código en Firestore con un tiempo de expiración
      await _firestore.collection('verification_codes').doc(user.uid).set({
        'code': verificationCode,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt':
            Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 5))),
      });

      // Enviar el código por correo electrónico
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: firebase_auth.ActionCodeSettings(
          url: 'https://funesami.page.link/verify',
          handleCodeInApp: true,
        ),
      );

      // Cerrar sesión después de enviar el código
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error en sendEmailVerification: $e');
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<bool> verifyEmailCode(String code) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'no-user',
          message: 'No hay usuario autenticado',
        );
      }

      // Obtener el código de verificación de Firestore
      final verificationDoc =
          await _firestore.collection('verification_codes').doc(user.uid).get();

      if (!verificationDoc.exists) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'no-code',
          message: 'No hay código de verificación pendiente',
        );
      }

      final verificationData = verificationDoc.data()!;
      final storedCode = verificationData['code'] as String;
      final expiresAt = (verificationData['expiresAt'] as Timestamp).toDate();

      // Verificar si el código ha expirado
      if (DateTime.now().isAfter(expiresAt)) {
        await verificationDoc.reference.delete();
        throw FirebaseException(
          plugin: 'auth',
          code: 'code-expired',
          message: 'El código de verificación ha expirado',
        );
      }

      // Verificar si el código coincide
      if (code != storedCode) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'invalid-code',
          message: 'Código de verificación inválido',
        );
      }

      // Eliminar el código usado
      await verificationDoc.reference.delete();
      return true;
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> resendEmailCode(String email) async {
    try {
      await sendEmailVerification(email);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  /// 🔹 Obtiene los datos completos del usuario desde Firestore
  Future<User> _fetchUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw FirebaseException(
            plugin: 'firestore',
            code: 'user-not-found',
            message: 'Usuario no encontrado en la base de datos.');
      }

      final userData = userDoc.data()!;
      final userInformationDoc = await _firestore
          .collection('userInformation')
          .doc(userData['userInformationId'])
          .get();

      if (!userInformationDoc.exists) {
        throw FirebaseException(
            plugin: 'firestore',
            code: 'info-not-found',
            message: 'Información del usuario no encontrada.');
      }

      final userInformationData = userInformationDoc.data()!;
      final userInformation = UserInformationEntity(
        id: userInformationDoc.id,
        firstName: userInformationData['firstname'],
        lastName: userInformationData['lastname'],
        address: userInformationData['address'],
        phone: userInformationData['phone'],
        email: userInformationData['email'],
      );

      return User(
        id: uid,
        email: userData['email'],
        username: userData['username'],
        isActive: userData['isActive'],
        userInformation: userInformation,
        role: userData['role'],
        patientID: userData['patientID'],
      );
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  /// 🔹 Valida que el número de teléfono sea único en la base de datos
  Future<bool> _validatePhoneUniqueness(String phoneNumber) async {
    try {
      // Normalizar el número de teléfono para la búsqueda
      final normalizedPhone = _formatPhoneNumber(phoneNumber);

      // Buscar en la colección userInformation si ya existe ese teléfono
      final querySnapshot = await _firestore
          .collection('userInformation')
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      // También buscar por el número sin formato por si acaso
      final querySnapshot2 = await _firestore
          .collection('userInformation')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      // Si no encontramos ningún documento, el teléfono es único
      return querySnapshot.docs.isEmpty && querySnapshot2.docs.isEmpty;
    } catch (e) {
      print('Error validando unicidad del teléfono: $e');
      // En caso de error, ser conservador y no permitir el registro
      return false;
    }
  }

  /// 🔹 Crea los datos del usuario en Firestore
  Future<void> _createUserInFirestore(
      String uid, RequestData requestData) async {
    try {
      final userInformationRef = _firestore.collection('userInformation').doc();
      await userInformationRef
          .set(requestData.createUser.userInformation.toMap());

      final patientRef = _firestore.collection('patients').doc();
      await patientRef.set(requestData.createPatient.toMap());

      await _firestore.collection('users').doc(uid).set({
        'email': requestData.createUser.email,
        'username': requestData.createUser.username,
        'isActive': true,
        'userInformationId': userInformationRef.id,
        'role': 'user',
        'patientID': patientRef.id,
      });
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }
}
