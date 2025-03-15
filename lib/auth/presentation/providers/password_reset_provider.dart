import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:fundacion_paciente_app/auth/domain/repositories/auth_repository.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:fundacion_paciente_app/config/routes/app_routes.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/custom_error.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/inputs/inputs.dart';

// Estado del formulario de recuperación de contraseña
class PasswordResetState {
  final Email email;
  final bool isSubmitting;
  final bool isFormPosted;
  final bool isValid;
  final String errorMessage;

  const PasswordResetState({
    this.email = const Email.pure(),
    this.isSubmitting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.errorMessage = '',
  });

  PasswordResetState copyWith({
    Email? email,
    bool? isSubmitting,
    bool? isFormPosted,
    bool? isValid,
    String? errorMessage,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  final AuthRepository authRepository;
  final Ref ref;
  PasswordResetNotifier({
    required this.ref,
    required this.authRepository,
  }) : super(const PasswordResetState());

  // Validar email
  void onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail]),
    );
  }

  // Enviar correo de restablecimiento
  Future<void> sendPasswordResetEmail() async {
    _touchFieldEmail();
    if (!state.isValid) return;

    try {
      state = state.copyWith(isSubmitting: true);
      await authRepository.sendPasswordResetEmail(state.email.value);

      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '',
      );
      ref.read(goRouterProvider).push('/login');
    } on CustomError catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
          isSubmitting: false,
          errorMessage:
              'Error inesperado al enviar el correo de restablecimiento');
    }
  }

  // Marcar los campos como modificados
  void _touchFieldEmail() {
    final email = Email.dirty(state.email.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      isValid: Formz.validate([email]),
    );
  }
}

final passwordResetProvider = StateNotifierProvider.autoDispose<
    PasswordResetNotifier, PasswordResetState>((ref) {
  final authRepository = AuthRepositoryImpl();
  return PasswordResetNotifier(authRepository: authRepository, ref: ref);
});
