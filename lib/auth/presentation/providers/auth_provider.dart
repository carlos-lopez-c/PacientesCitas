import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/auth/domain/repositories/auth_repository.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:fundacion_paciente_app/config/routes/app_routes.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/services/key_value_storage_service_impl.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService,
      ref: ref);
});

enum AuthStatus { checking, authenticated, notAuthenticated, requires2FA }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final String? verificationId;
  final String? phoneNumber;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.verificationId,
    this.phoneNumber,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
        verificationId: verificationId ?? this.verificationId,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  final Ref ref;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
    required this.ref,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    try {
      state = state.copyWith(
        authStatus: AuthStatus.checking,
        errorMessage: '',
        user: null,
        verificationId: null,
        phoneNumber: null,
      );

      final user = await authRepository.login(email, password);

      // Verificar si se requiere autenticación de dos pasos
      if (user.userInformation.phone != null &&
          user.userInformation.phone!.isNotEmpty) {
        // Si el usuario tiene teléfono registrado, enviamos el código para 2FA
        final verificationId =
            await sendPhoneVerification(user.userInformation.phone!);
        state = state.copyWith(
          user: user,
          authStatus: AuthStatus.requires2FA,
          phoneNumber: user.userInformation.phone,
          verificationId: verificationId,
        );
      } else {
        // Si no tiene teléfono, cerrar sesión y mostrar error
        await logout();
        state = state.copyWith(
          authStatus: AuthStatus.notAuthenticated,
          errorMessage:
              'Se requiere un número de teléfono para la autenticación de dos factores',
        );
      }
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.toString(),
        user: null,
        verificationId: null,
        phoneNumber: null,
      );
    }
  }

  Future<String> sendPhoneVerification(String phoneNumber) async {
    try {
      state = state.copyWith(
        authStatus: AuthStatus.checking,
        errorMessage: '',
      );

      final verificationId =
          await authRepository.sendPhoneVerification(phoneNumber);
      return verificationId;
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        errorMessage:
            'Error al enviar el código de verificación: ${e.toString()}',
      );
      throw e;
    }
  }

  Future<void> verifyPhoneCode(String code) async {
    try {
      if (state.verificationId == null) {
        throw Exception('No hay ID de verificación disponible');
      }

      state = state.copyWith(
        authStatus: AuthStatus.checking,
        errorMessage: '',
      );

      final isValid = await authRepository.verifyPhoneCode(
        state.verificationId!,
        code,
      );

      if (isValid && state.user != null) {
        _setLoggedUser(state.user!);
      } else {
        state = state.copyWith(
          authStatus: AuthStatus.requires2FA,
          errorMessage: 'Código de verificación inválido',
        );
      }
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        errorMessage: 'Error al verificar el código: ${e.toString()}',
      );
    }
  }

  Future<void> resendPhoneCode() async {
    try {
      if (state.phoneNumber == null) {
        throw Exception('No hay un número de teléfono registrado');
      }

      state = state.copyWith(
        authStatus: AuthStatus.checking,
        errorMessage: '',
      );

      final verificationId =
          await authRepository.resendPhoneCode(state.phoneNumber!);
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        verificationId: verificationId,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        errorMessage: 'Error al reenviar el código: ${e.toString()}',
      );
    }
  }

  Future<void> registerUser(RequestData register) async {
    try {
      state = state.copyWith(
        authStatus: AuthStatus.checking,
        errorMessage: '',
      );

      await authRepository.register(register);
      ref.read(goRouterProvider).go('/login');
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  void checkAuthStatus() async {
    try {
      state = state.copyWith(
        authStatus: AuthStatus.checking,
        errorMessage: '',
      );

      final user = await authRepository.checkAuthStatus();

      // Verificar si el usuario tiene teléfono registrado
      if (user.userInformation.phone != null &&
          user.userInformation.phone!.isNotEmpty) {
        // Si tiene teléfono, requiere 2FA
        state = state.copyWith(
          user: user,
          authStatus: AuthStatus.requires2FA,
          phoneNumber: user.userInformation.phone,
        );
        // Enviar el código de verificación
        final verificationId =
            await sendPhoneVerification(user.userInformation.phone!);
        state = state.copyWith(verificationId: verificationId);
      } else {
        // Si no tiene teléfono, cerrar sesión
        await logout();
      }
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      verificationId: null,
      phoneNumber: null,
    );
  }

  Future<void> logout([String? errorMessage]) async {
    try {
      await authRepository.logout();
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: errorMessage ?? '',
        verificationId: null,
        phoneNumber: null,
      );
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: 'Error al cerrar sesión: ${e.toString()}',
        verificationId: null,
        phoneNumber: null,
      );
    }
  }
}
