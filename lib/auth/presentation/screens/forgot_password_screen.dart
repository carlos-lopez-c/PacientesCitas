import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paciente_citas_1/auth/presentation/providers/password_reset_provider.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_filled_button.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/custom_text_form_fiield.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/header.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  static const name = 'forgot-password-screen';
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordResetState = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo y título con animación
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: const Header(
                      heightScale: 0.75,
                      imagePath: 'assets/images/logo.png',
                      title: 'Fundación de niños especiales',
                      subtitle: '"SAN MIGUEL" FUNESAMI',
                      item: 'Recuperar Contraseña',
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Descripción
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 40,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Para restablecer tu contraseña, ingresa tu correo electrónico registrado. Te enviaremos un enlace para crear una nueva contraseña de forma segura.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Formulario
                  Card(
                    elevation: 8,
                    shadowColor: colors.primary.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (passwordResetState.errorMessage.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                ),
                              ),
                              child: Text(
                                passwordResetState.errorMessage,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Mensaje de éxito
                          if (passwordResetState.successMessage != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    passwordResetState.successMessage!,
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text(
                                        'Volver al inicio de sesión'),
                                  ),
                                ],
                              ),
                            ),

                          // Solo mostrar el formulario si no hay mensaje de éxito
                          if (passwordResetState.successMessage == null) ...[
                            CustomTextFormField(
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: colors.primary),
                              errorMessage: passwordResetState.isFormPosted
                                  ? passwordResetState.email.errorMessage
                                  : null,
                              label: 'Correo Electrónico',
                              hint: 'ejemplo@correo.com',
                              keyboardType: TextInputType.emailAddress,
                              onChanged: notifier.onEmailChanged,
                            ),
                            const SizedBox(height: 30),
                            CustomFilledButton(
                              text: 'ENVIAR INSTRUCCIONES',
                              onPressed: () {
                                notifier.sendPasswordResetEmail();
                              },
                              isLoading: passwordResetState.isSubmitting,
                            ),
                            if (passwordResetState.isSubmitting)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Enviando instrucciones...',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón para volver
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: colors.primary),
                    label: Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
