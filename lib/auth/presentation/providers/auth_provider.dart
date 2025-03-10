import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/auth/domain/repositories/auth_repository.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/errors/auth_errors.dart';
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
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logout(e.message);
    } catch (e) {
      logout('Error no controlado');
    }

    // final user = await authRepository.login(email, password);
    // state =state.copyWith(user: user, authStatus: AuthStatus.authenticated)
  }

  void registerUser(RequestData register, BuildContext context) async {
    try {
      final userResponseValid = await authRepository.register(register);

      if (userResponseValid) {
        // 🔥 Redirigir a la pantalla de Login después del registro exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(goRouterProvider).go('/login');
      }
    } on CustomError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
      logout(e.message);
    } catch (e) {
      logout('Error no controlado');
    }
  }

  void checkAuthStatus() async {
    try {
      final user = await authRepository.checkAuthStatus();
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await authRepository.logout();
    state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: errorMessage);
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.checking,
      this.user,
      this.errorMessage = ''});

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
          authStatus: authStatus ?? this.authStatus,
          user: user ?? this.user,
          errorMessage: errorMessage ?? this.errorMessage);
}
