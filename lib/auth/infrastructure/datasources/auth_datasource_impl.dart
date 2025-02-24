import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fundacion_paciente_app/auth/domain/datasources/auth_datasource.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_information_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/errors/auth_errors.dart';

class FirebaseAuthDatasource implements AuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw CustomError('Error al obtener los datos del usuario.');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw CustomError('Usuario no encontrado en la base de datos.');
      }

      final userData = userDoc.data()!;
      final userInformationDoc = await _firestore
          .collection('userInformation')
          .doc(userData['userInformationId'])
          .get();

      if (!userInformationDoc.exists) {
        throw CustomError('Información del usuario no encontrada.');
      }

      final userInformationData = userInformationDoc.data()!;
      final userInformation = UserInformationEntity(
        id: userInformationDoc.id,
        firstName: userInformationData['firstname'],
        lastName: userInformationData['lastname'],
        address: userInformationData['address'],
        phone: userInformationData['phone'],
      );

      return User(
        id: user.uid,
        email: user.email!,
        username: userData['username'],
        isActive: userData['isActive'],
        userInformation: userInformation,
        role: userData['role'],
        patientID: userData['patientID'],
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw CustomError(e.message ?? 'Error de autenticación.');
    } catch (e) {
      throw CustomError('Error desconocido: $e');
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
        throw CustomError('Error al crear el usuario.');
      }

      final userInformationRef = _firestore.collection('userInformation').doc();
      await userInformationRef
          .set(requestData.createUser.userInformation.toMap());

      final patientRef = _firestore.collection('patients').doc();
      await patientRef.set(requestData.createPatient.toMap());

      await _firestore.collection('users').doc(user.uid).set({
        'email': requestData.createUser.email,
        'username': requestData.createUser.username,
        'isActive': true,
        'userInformationId': userInformationRef.id,
        'role': 'user', // Asigna el rol por defecto
        'patientID': patientRef.id,
      });

      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw CustomError(e.message ?? 'Error al registrar el usuario.');
    } catch (e) {
      throw CustomError('Error desconocido: $e');
    }
  }

  @override
  Future<User> checkAuthStatus() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw CustomError('No hay usuario autenticado.');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw CustomError('Usuario no encontrado en la base de datos.');
      }

      final userData = userDoc.data()!;
      final userInformationDoc = await _firestore
          .collection('userInformation')
          .doc(userData['userInformationId'])
          .get();

      if (!userInformationDoc.exists) {
        throw CustomError('Información del usuario no encontrada.');
      }

      final userInformationData = userInformationDoc.data()!;
      final userInformation = UserInformationEntity(
        id: userInformationDoc.id,
        firstName: userInformationData['firstname'],
        lastName: userInformationData['lastname'],
        address: userInformationData['address'],
        phone: userInformationData['phone'],
      );

      return User(
        id: user.uid,
        email: user.email!,
        username: userData['username'],
        isActive: userData['isActive'],
        userInformation: userInformation,
        role: userData['role'],
        patientID: userData['patientID'],
      );
    } catch (e) {
      throw CustomError('Error al verificar el estado de autenticación: $e');
    }
  }

  @override
  Future<void> sendCode(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw CustomError(
          e.message ?? 'Error al enviar el correo de restablecimiento.');
    } catch (e) {
      throw CustomError('Error desconocido: $e');
    }
  }

  @override
  Future<void> validateCode(String email, String code) async {
    // Firebase no proporciona una forma directa de validar un código de restablecimiento de contraseña.
    // Generalmente, el usuario sigue el enlace proporcionado en el correo electrónico para restablecer la contraseña.
    throw UnimplementedError('La validación de código no está implementada.');
  }

  @override
  Future<void> resetPassword(
      String email, String token, String newPassword) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
          code: token, newPassword: newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw CustomError(e.message ?? 'Error al restablecer la contraseña.');
    } catch (e) {
      throw CustomError('Error desconocido: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      // Si utilizas proveedores de autenticación como Google, Facebook, etc.,
      // asegúrate de cerrar sesión en ellos también.
      // Por ejemplo, para Google:
      // await GoogleSignIn().signOut();
    } catch (e) {
      throw CustomError('Error al cerrar sesión: $e');
    }
  }
}
