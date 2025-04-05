import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/auth/domain/repositories/auth_repository.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:fundacion_paciente_app/config/routes/app_routes.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/custom_error.dart';

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
  final bool isLoading;
  final bool isRegisterLoading;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.verificationId,
    this.phoneNumber,
    this.isLoading = false,
    this.isRegisterLoading = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
    bool? isLoading,
    bool? isRegisterLoading,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
        verificationId: verificationId ?? this.verificationId,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        isLoading: isLoading ?? this.isLoading,
        isRegisterLoading: isRegisterLoading ?? this.isRegisterLoading,
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
  }) : super(AuthState(authStatus: AuthStatus.notAuthenticated));

  Future<void> loginUser(String email, String password) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
        user: null,
        verificationId: null,
        phoneNumber: null,
      );

      final user = await authRepository.login(email, password);

      if (user.userInformation.phone != null &&
          user.userInformation.phone!.isNotEmpty) {
        final verificationId =
            await sendPhoneVerification(user.userInformation.phone!);

        state = state.copyWith(
          user: user,
          authStatus: AuthStatus.requires2FA,
          phoneNumber: user.userInformation.phone,
          verificationId: verificationId,
          isLoading: false,
        );
      } else {
        await logout();
        state = state.copyWith(
          authStatus: AuthStatus.notAuthenticated,
          errorMessage:
              'Se requiere un número de teléfono para la autenticación de dos factores',
          isLoading: false,
        );
      }
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.message,
        user: null,
        verificationId: null,
        phoneNumber: null,
        isLoading: false,
      );
    }
  }

  Future<String> sendPhoneVerification(String phoneNumber) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
      );

      final verificationId =
          await authRepository.sendPhoneVerification(phoneNumber);
      return verificationId;
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        errorMessage: e.message,
        isLoading: false,
      );
      throw e;
    }
  }

  Future<void> verifyPhoneCode(String code) async {
    try {
      if (state.verificationId == null) {
        throw CustomError('No hay ID de verificación disponible');
      }

      state = state.copyWith(
        isLoading: true,
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
          isLoading: false,
        );
      }
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        errorMessage: e.message,
        isLoading: false,
      );
    }
  }

  Future<void> resendPhoneCode() async {
    try {
      if (state.phoneNumber == null) {
        throw CustomError('No hay un número de teléfono registrado');
      }

      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
      );

      final verificationId =
          await authRepository.resendPhoneCode(state.phoneNumber!);
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        verificationId: verificationId,
        errorMessage: '',
        isLoading: false,
      );
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.requires2FA,
        errorMessage: e.message,
        isLoading: false,
      );
    }
  }

  Future<bool> registerUser(RequestData register) async {
    try {
      state = state.copyWith(
        isRegisterLoading: true,
        errorMessage: '',
        authStatus: state.authStatus,
      );

      await authRepository.register(register);

      state = state.copyWith(
        isRegisterLoading: false,
        errorMessage: '',
        authStatus: AuthStatus.notAuthenticated,
      );

      return true;
    } on CustomError catch (e) {
      state = state.copyWith(
        errorMessage: e.message,
        isRegisterLoading: false,
        authStatus: AuthStatus.notAuthenticated,
      );
      return false;
    }
  }

  void checkAuthStatus() async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
      );

      final user = await authRepository.checkAuthStatus();

      if (user.userInformation.phone != null &&
          user.userInformation.phone!.isNotEmpty) {
        state = state.copyWith(
          user: user,
          authStatus: AuthStatus.requires2FA,
          phoneNumber: user.userInformation.phone,
          isLoading: false,
        );
        final verificationId =
            await sendPhoneVerification(user.userInformation.phone!);
        state = state.copyWith(verificationId: verificationId);
      } else {
        await logout();
      }
    } on CustomError catch (e) {
      print("Error al verificar el estado de autenticación: $e");
      logout(e.message);
    }
  }

  void _setLoggedUser(User user) async {
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      verificationId: null,
      phoneNumber: null,
      isLoading: false,
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
        isLoading: false,
      );
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: e.message,
        verificationId: null,
        phoneNumber: null,
        isLoading: false,
      );
    }
  }
}
