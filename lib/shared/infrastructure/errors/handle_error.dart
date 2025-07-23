import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'custom_error.dart';

class FirebaseErrorHandler {
  static CustomError handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return CustomError(
            'El correo electrónico o la contraseña son incorrectos',
            code: e.code);
      case 'invalid-email':
        return CustomError('Correo electrónico inválido', code: e.code);
      case 'user-not-found':
        return CustomError('Usuario no encontrado', code: e.code);
      case 'wrong-password':
        return CustomError('Usuario o contraseña incorrecta', code: e.code);
      case 'user-disabled':
        return CustomError(
            'Tu cuenta ha sido deshabilitada. Por favor, contacta a soporte.',
            code: e.code);
      case 'email-already-in-use':
        return CustomError(
            'Este correo ya está registrado. Por favor, inicia sesión.',
            code: e.code);
      case 'weak-password':
        return CustomError('La contraseña debe tener al menos 6 caracteres',
            code: e.code);
      case 'operation-not-allowed':
        return CustomError(
            'Operación no permitida. Por favor, intenta más tarde.',
            code: e.code);
      case 'too-many-requests':
        return CustomError(
            'Demasiados intentos. Por favor, espera unos minutos antes de intentar nuevamente.',
            code: e.code);
      case 'invalid-verification-code':
        return CustomError(
            'El código de verificación es incorrecto. Por favor, revisa e intenta nuevamente.',
            code: e.code);
      case 'invalid-verification-id':
        return CustomError(
            'La sesión de verificación ha expirado. Por favor, solicita un nuevo código.',
            code: e.code);
      case 'code-expired':
        return CustomError(
            'El código ha expirado. Por favor, solicita uno nuevo.',
            code: e.code);
      case 'requires-2fa':
        return CustomError('Se requiere verificación de dos factores.',
            code: e.code);
      case 'email-not-registered':
        return CustomError('El correo electrónico no está registrado.',
            code: e.code);
      case 'phone-already-exists':
        return CustomError(
            'Este número de teléfono ya está registrado con otra cuenta.',
            code: e.code);
      default:
        return CustomError(
            'Ha ocurrido un error. Por favor, intenta nuevamente.',
            code: e.code);
    }
  }

  static CustomError handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return CustomError('No tienes permisos para realizar esta acción.',
            code: e.code);
      case 'not-found':
        return CustomError('No se encontró la información solicitada.',
            code: e.code);
      case 'unavailable':
        return CustomError(
            'Servicio no disponible. Por favor, intenta más tarde.',
            code: e.code);
      case 'deadline-exceeded':
        return CustomError(
            'La operación tardó demasiado. Por favor, intenta nuevamente.',
            code: e.code);
      case 'already-exists':
        return CustomError('Esta información ya existe en el sistema.',
            code: e.code);
      case 'cancelled':
        return CustomError('La operación fue cancelada.', code: e.code);
      case 'invalid-argument':
        return CustomError(
            'Información no válida. Por favor, verifica los datos.',
            code: e.code);
      case 'verification-failed':
        return CustomError(
            'Error en la verificación. Por favor, intenta nuevamente.',
            code: e.code);
      case 'no-auth':
        return CustomError('No hay una sesión activa.', code: e.code);
      case 'requires-2fa':
        return CustomError('Se requiere verificación de dos factores.',
            code: e.code);
      case 'email-not-registered':
        return CustomError('El correo electrónico no está registrado.',
            code: e.code);
      case 'phone-already-exists':
        return CustomError(
            'Este número de teléfono ya está registrado con otra cuenta.',
            code: e.code);
      default:
        return CustomError(
            'Ha ocurrido un error. Por favor, intenta nuevamente.',
            code: e.code);
    }
  }

  static CustomError handlePlatformException(PlatformException e) {
    return CustomError('Error del sistema. Por favor, intenta nuevamente.',
        code: e.code ?? "platform-error");
  }

  static CustomError handleGenericException(dynamic e) {
    print('Error en handleGenericException: ${e}');
    return CustomError(
        'Ha ocurrido un error inesperado. Por favor, intenta nuevamente.',
        code: "unknown");
  }
}
