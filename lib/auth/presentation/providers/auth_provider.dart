import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/auth/domain/repositories/auth_repository.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/custom_error.dart';
import 'package:fundacion_paciente_app/notifications/presentation/providers/notification_provider.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/services/auth_session_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();
  final authSessionService = AuthSessionService(keyValueStorageService);

  return AuthNotifier(
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService,
      authSessionService: authSessionService,
      ref: ref);
});

enum AuthStatus { checking, authenticated, notAuthenticated, requires2FA }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final String? verificationId;
  final String? phoneNumber;
  final String successMessage;
  final bool isLoading;
  final bool isRegisterLoading;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.successMessage = '',
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
    String? successMessage,
    String? phoneNumber,
    bool? isLoading,
    bool? isRegisterLoading,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        successMessage: successMessage ?? this.successMessage,
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
  final AuthSessionService authSessionService;
  final Ref ref;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
    required this.authSessionService,
    required this.ref,
  }) : super(AuthState(authStatus: AuthStatus.checking)) {
    checkAuthStatus();
  }

  Future<User?> getCurrentUser() async {
    return await authRepository.getCurrentUser();
  }

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
        // Verificar si ya completó 2FA anteriormente
        final hasCompleted2FA =
            await authSessionService.hasTwoFactorCompleted(user.patientID);

        if (hasCompleted2FA) {
          // Ya completó 2FA, autenticar directamente
          _setLoggedUser(user);
        } else {
          // Requiere 2FA
          final verificationId =
              await sendPhoneVerification(user.userInformation.phone!);

          state = state.copyWith(
            user: user,
            authStatus: AuthStatus.requires2FA,
            phoneNumber: user.userInformation.phone,
            verificationId: verificationId,
            isLoading: false,
          );
        }
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

      // Reset isLoading to false when successful
      state = state.copyWith(
        isLoading: false,
      );

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
        // Marcar que completó el 2FA exitosamente
        await authSessionService.setTwoFactorCompleted(state.user!.patientID);
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

  Future<void> cancelPhoneAuth() async {
    try {
      // Limpiar la sesión y volver al estado de no autenticado
      await authRepository.logout();
      await authSessionService.clearSession();
      
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: '',
        verificationId: null,
        phoneNumber: null,
        isLoading: false,
      );
    } catch (e) {
      // En caso de error, al menos limpiar el estado local
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: '',
        verificationId: null,
        phoneNumber: null,
        isLoading: false,
      );
    }
  }

  Future<bool> registerUser(RequestData register) async {
    try {
      state = state.copyWith(
        isRegisterLoading: true,
        errorMessage: '',
      );

      await authRepository.register(register);

      state = state.copyWith(
        isRegisterLoading: false,
        errorMessage: '',
        successMessage: 'Registro exitoso. Por favor, inicie sesión.',
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

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: '');
  }

  void checkAuthStatus() async {
    try {
      print('🔍 Checking auth status...');

      final user = await authRepository.checkAuthStatus();
      print('✅ User found: ${user.email}');

      // Verificar si ya completó 2FA en sesiones anteriores
      final hasCompleted2FA =
          await authSessionService.hasTwoFactorCompleted(user.patientID);

      if (hasCompleted2FA) {
        // Ya completó 2FA, autenticar directamente
        print('✅ User already completed 2FA in previous session');
        _setLoggedUser(user);
      } else {
        // Requiere 2FA
        print('🔐 User requires 2FA verification');
        if (user.userInformation.phone != null &&
            user.userInformation.phone!.isNotEmpty) {
          state = state.copyWith(
            user: user,
            authStatus: AuthStatus.requires2FA,
            phoneNumber: user.userInformation.phone,
            isLoading: false,
          );

          try {
            final verificationId =
                await sendPhoneVerification(user.userInformation.phone!);
            state = state.copyWith(
              verificationId: verificationId,
              isLoading: false,
            );
          } catch (e) {
            print("❌ Error sending verification code: $e");
            state = state.copyWith(
              errorMessage: 'Error enviando código de verificación',
              isLoading: false,
            );
          }
        } else {
          await logout('Se requiere un número de teléfono válido');
        }
      }
    } on CustomError catch (e) {
      print("❌ Error al verificar el estado de autenticación: ${e.message}");

      // Verificar si es específicamente un error de 2FA requerido
      if (e.message.contains('requiere autenticación de dos factores') ||
          e.message.contains('requires-2fa')) {
        print("🔐 Handling 2FA requirement...");
        _handle2FARequirement();
      } else {
        print("🔄 No authenticated user found - immediate redirect to login");
        _forceLogout();
      }
    } catch (e) {
      print("❌ Unexpected error al verificar el estado de autenticación: $e");

      // Verificar si es un error de 2FA requerido
      if (e.toString().contains('requires-2fa') ||
          e.toString().contains('requiere autenticación de dos factores')) {
        print("🔐 Handling 2FA requirement from unexpected error...");
        _handle2FARequirement();
      } else {
        print("🔄 Unexpected error - redirecting to login");
        _forceLogout();
      }
    }
  }

  void _handle2FARequirement() async {
    try {
      // Obtener el usuario actual de Firebase Auth directamente
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final hasCompleted2FA = await authSessionService
            .hasTwoFactorCompleted(currentUser.patientID);

        if (hasCompleted2FA) {
          _setLoggedUser(currentUser);
        } else {
          if (currentUser.userInformation.phone != null &&
              currentUser.userInformation.phone!.isNotEmpty) {
            state = state.copyWith(
              user: currentUser,
              authStatus: AuthStatus.requires2FA,
              phoneNumber: currentUser.userInformation.phone,
              isLoading: false,
            );

            try {
              final verificationId = await sendPhoneVerification(
                  currentUser.userInformation.phone!);
              state = state.copyWith(
                verificationId: verificationId,
                isLoading: false,
              );
            } catch (sendError) {
              print("❌ Error sending verification code: $sendError");
              state = state.copyWith(
                errorMessage: 'Error enviando código de verificación',
                isLoading: false,
              );
            }
          } else {
            await logout('Se requiere un número de teléfono válido');
          }
        }
      } else {
        _forceLogout();
      }
    } catch (innerError) {
      print("❌ Error obteniendo datos de usuario para 2FA: $innerError");
      _forceLogout();
    }
  }

  void _forceLogout() {
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: '',
      verificationId: null,
      phoneNumber: null,
      isLoading: false,
    );
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

    // Guardar token FCM cuando el usuario se autentica
    try {
      final notificationNotifier = ref.read(notificationProvider.notifier);
      await notificationNotifier.saveTokenToFirestore(user.patientID);
    } catch (e) {
      print('Error guardando token FCM: $e');
    }
  }

  Future<void> logout([String? errorMessage]) async {
    try {
      // Limpiar sesión de 2FA al hacer logout
      await authSessionService.clearSession();
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

  Future<void> signOut() async {
    try {
      // Limpiar sesión de 2FA al cerrar sesión
      await authSessionService.clearSession();
      await authRepository.signOut();
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: '',
      );
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: e.message,
      );
    }
  }
}
