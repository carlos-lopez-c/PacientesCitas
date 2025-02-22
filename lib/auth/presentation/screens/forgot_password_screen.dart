import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/presentation/providers/password_reset_provider.dart';
import 'package:fundacion_paciente_app/shared/presentation/widgets/custom_text_form_fiield.dart';
import 'package:fundacion_paciente_app/shared/presentation/widgets/header.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  static const name = 'forgot-password-screen';
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordResetState = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Header(
              heightScale: 1.0,
              imagePath: 'assets/images/logo.png',
              title: 'Fundación de niños especiales',
              subtitle: '"SAN MIGUEL" FUNESAMI',
              item: '"Recuperar Contraseña"',
            ),
            const SizedBox(height: 30),
            const Text(
              'Ingresa tu correo para recuperar la contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Campo de entrada de correo
            CustomTextFormField(
              prefixIcon: const Icon(Icons.email),
              errorMessage: passwordResetState.isFormPosted
                  ? passwordResetState.email.errorMessage
                  : null,
              label: 'Correo Electrónico',
              hint: 'Ingrese su correo',
              keyboardType: TextInputType.emailAddress,
              onChanged: notifier.onEmailChanged,
            ),
            const SizedBox(height: 30),

            // Botón para enviar el código
            SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  notifier.sendCode();
                },
                child: const Text('Enviar Código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
