import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fundacion_paciente_app/auth/domain/datasources/auth_datasource.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_information_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/handle_error.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/custom_error.dart';
import 'dart:async';
import 'dart:math';

class FirebaseAuthDatasource implements AuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
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
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseException(
            plugin: 'auth',
            code: 'no-auth',
            message: 'No hay usuario autenticado.');
      }

      // Obtener los datos del usuario
      final userData = await _fetchUserData(user.uid);

      // Si el usuario tiene teléfono registrado, cerrar sesión para forzar 2FA
      if (userData.userInformation.phone != null &&
          userData.userInformation.phone!.isNotEmpty) {
        await _firebaseAuth.signOut();
        throw FirebaseException(
            plugin: 'auth',
            code: 'requires-2fa',
            message: 'Se requiere autenticación de dos factores.');
      }

      return userData;
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
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
      if (e is CustomError) throw e;
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<bool> verifyPhoneCode(String verificationId, String code) async {
    try {
      print("Verification ID: $verificationId");
      print("Code: $code");
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      print("Credential: ${credential}");

      // Verificar si hay un usuario ya autenticado por correo
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null &&
          currentUser.email != null &&
          currentUser.email!.isNotEmpty) {
        // Si hay un usuario con correo, vincular las credenciales de teléfono
        try {
          await currentUser.linkWithCredential(credential);
          print("Credenciales vinculadas exitosamente");
          return true;
        } catch (linkError) {
          print("Error al vincular credenciales: $linkError");
          // Si no se puede vincular (por ejemplo, si el teléfono ya está en uso),
          // aún podemos autenticar al usuario con su correo original
          return true;
        }
      } else {
        // Si no hay un usuario autenticado por correo, hacer el login normal con teléfono
        await _firebaseAuth.signInWithCredential(credential);
        print("Sign In With Credential: ${_firebaseAuth.currentUser}");
        return true;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error: ${e}");
      throw FirebaseErrorHandler.handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      print("Error: ${e}");
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      print("Error: ${e}");
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
}
