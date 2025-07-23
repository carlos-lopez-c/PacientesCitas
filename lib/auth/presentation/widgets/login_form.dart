import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/auth/presentation/providers/login_form_provider.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_filled_button.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_text_form_fiield.dart';


class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final loginForm = ref.watch(formularioProvider);
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            prefixIcon: Icon(Icons.email_outlined, color: colors.primary),
            errorMessage:
                loginForm.isFormPosted ? loginForm.email.errorMessage : null,
            label: 'Correo Electrónico',
            hint: 'ejemplo@correo.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: ref.read(formularioProvider.notifier).onEmailChanged,
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            prefixIcon: Icon(Icons.lock_outline, color: colors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: colors.primary,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            errorMessage:
                loginForm.isFormPosted ? loginForm.password.errorMessage : null,
            obscureText: !_showPassword,
            label: 'Contraseña',
            hint: '',
            onChanged: ref.read(formularioProvider.notifier).onPasswordChanged,
          ),
          const SizedBox(height: 30),
          CustomFilledButton(
            text: 'INICIAR SESIÓN',
            onPressed: (loginForm.isPosting || authState.isLoading)
                ? null
                : () {
                    ref.read(formularioProvider.notifier).onFormSubmit();
                  },
            isLoading: loginForm.isPosting || authState.isLoading,
          ),
        ],
      ),
    );
  }
}
