import 'package:formz/formz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/email_input.dart';
import 'package:paciente_citas_1/shared/infrastructure/inputs/password_input.dart';

final formularioProvider =
    StateNotifierProvider.autoDispose<FormularioNotifier, FormularioState>(
        (ref) {
  final loginUserCallback = ref.watch(authProvider.notifier).loginUser;

  return FormularioNotifier(loginUserCallback: loginUserCallback);
});

class FormularioNotifier extends StateNotifier<FormularioState> {
  final Function(String, String) loginUserCallback;
  bool _isDisposed = false;

  FormularioNotifier({
    required this.loginUserCallback,
  }) : super(const FormularioState());

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void onEmailChanged(String value) {
    if (_isDisposed) return;

    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail, state.password]),
    );
  }

  void onPasswordChanged(String value) {
    if (_isDisposed) return;

    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([state.email, newPassword]),
    );
  }

  Future<void> onFormSubmit() async {
    if (_isDisposed) return;

    _touchEveryField();

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true);

    try {
      await loginUserCallback(state.email.value, state.password.value);
    } catch (e) {
      if (!_isDisposed) {
        print('Error al enviar el formulario: $e');
      }
    } finally {
      if (!_isDisposed) {
        state = state.copyWith(isPosting: false);
      }
    }
  }

  void _touchEveryField() {
    if (_isDisposed) return;

    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      isValid: Formz.validate([email, password]),
    );
  }
}

class FormularioState {
  final Email email;
  final Password password;

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;

  const FormularioState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
  });

  FormularioState copyWith({
    Email? email,
    Password? password,
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
  }) {
    return FormularioState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
    );
  }
}
