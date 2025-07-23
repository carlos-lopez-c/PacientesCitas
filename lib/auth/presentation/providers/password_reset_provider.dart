import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:paciente_citas_1/auth/domain/repositories/auth_repository.dart';
import 'package:paciente_citas_1/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:paciente_citas_1/shared/infrastructure/errors/custom_error.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/email_input.dart';


// Estado del formulario de recuperación de contraseña
class PasswordResetState {
  final Email email;
  final bool isSubmitting;
  final bool isFormPosted;
  final bool isValid;
  final String errorMessage;
  final String? successMessage;

  const PasswordResetState({
    this.email = const Email.pure(),
    this.isSubmitting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.errorMessage = '',
    this.successMessage,
  });

  PasswordResetState copyWith({
    Email? email,
    bool? isSubmitting,
    bool? isFormPosted,
    bool? isValid,
    String? errorMessage,
    String? successMessage,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
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
      state = state.copyWith(isSubmitting: true, errorMessage: '');
      await authRepository.sendPasswordResetEmail(state.email.value);

      // Mostrar mensaje de éxito en lugar de redireccionar
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '',
        isFormPosted: false,
        // Reiniciamos el email para permitir enviar de nuevo si es necesario
      );

      // Aquí no redirigimos, simplemente mostramos un mensaje de éxito
      // que se manejará en la UI
      showSuccessMessage();
    } on CustomError catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      print('Error en sendPasswordResetEmail: ${e.message}');
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

  // Nuevo método para mostrar mensaje de éxito
  void showSuccessMessage() {
    print('Email enviado a ${state.email.value}');
    state = state.copyWith(
      errorMessage: '',
      successMessage:
          'Se ha enviado un correo de restablecimiento a ${state.email.value}. Por favor, revisa tu bandeja de entrada.',
    );
  }
}

final passwordResetProvider = StateNotifierProvider.autoDispose<
    PasswordResetNotifier, PasswordResetState>((ref) {
  final authRepository = AuthRepositoryImpl();
  return PasswordResetNotifier(authRepository: authRepository, ref: ref);
});
