import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/auth/presentation/providers/page_register.dart';
import 'package:paciente_citas_1/auth/presentation/widgets/register_controller.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const name = 'register-screen';
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _hasShownSuccess = false;

  @override
  void initState() {
    super.initState();
    // Reiniciar el controlador de páginas al montar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pageControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.successMessage.isNotEmpty && !_hasShownSuccess) {
        _hasShownSuccess = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage),
            backgroundColor: Colors.green.shade300,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(authProvider.notifier).clearSuccessMessage();
          _hasShownSuccess = false;
          context.go('/login');
        });
      }
    });

    return Scaffold(
      appBar: AppBar(),
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
            physics: const ClampingScrollPhysics(),
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
                      heightScale: 0.7,
                      imagePath: 'assets/images/logo.png',
                      title: 'Fundación de niños especiales',
                      subtitle: '"SAN MIGUEL" FUNESAMI',
                      item: 'Registro de Usuario',
                    ),
                  ),
                  const SizedBox(height: 20),
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
                    child: Text(
                      'Complete el formulario de registro para crear su cuenta en FUNESAMI. El proceso consta de tres pasos sencillos.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.primary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Formulario de registro
                  Card(
                    elevation: 8,
                    shadowColor: colors.primary.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: RegisterController(),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
