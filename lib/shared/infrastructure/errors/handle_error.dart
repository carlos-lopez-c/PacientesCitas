import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'custom_error.dart';

class FirebaseErrorHandler {
  static CustomError handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return CustomError('El correo electrónico no es válido.', code: e.code);
      case 'user-disabled':
        return CustomError('El usuario ha sido deshabilitado.', code: e.code);
      case 'user-not-found':
        return CustomError('No se encontró una cuenta con este correo.',
            code: e.code);
      case 'wrong-password':
        return CustomError('Contraseña incorrecta.', code: e.code);
      case 'email-already-in-use':
        return CustomError('Este correo ya está en uso.', code: e.code);
      case 'weak-password':
        return CustomError('La contraseña es demasiado débil.', code: e.code);
      case 'operation-not-allowed':
        return CustomError('Esta operación no está permitida.', code: e.code);
      case 'too-many-requests':
        return CustomError('Demasiados intentos. Inténtelo más tarde.',
            code: e.code);
      default:
        return CustomError('Error de autenticación: ${e.message}',
            code: e.code);
    }
  }

  static CustomError handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return CustomError('No tienes permisos para realizar esta acción.',
            code: e.code);
      case 'not-found':
        return CustomError('El documento solicitado no existe.', code: e.code);
      case 'unavailable':
        return CustomError('El servicio no está disponible temporalmente.',
            code: e.code);
      case 'deadline-exceeded':
        return CustomError('El tiempo de espera ha expirado.', code: e.code);
      case 'already-exists':
        return CustomError('El documento ya existe en Firestore.',
            code: e.code);
      case 'cancelled':
        return CustomError('La operación fue cancelada.', code: e.code);
      case 'invalid-argument':
        return CustomError('El argumento proporcionado no es válido.',
            code: e.code);
      default:
        return CustomError('Error de Firestore: ${e.message}', code: e.code);
    }
  }

  static CustomError handlePlatformException(PlatformException e) {
    return CustomError('Error del sistema: ${e.message}',
        code: e.code ?? "platform-error");
  }

  static CustomError handleGenericException(dynamic e) {
    return CustomError('Error desconocido: ${e.toString()}', code: "unknown");
  }
}
