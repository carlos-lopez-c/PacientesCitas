import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/presentation/providers/auth_provider.dart';
import 'package:fundacion_paciente_app/home/presentation/providers/appointments_provider.dart';
import 'package:fundacion_paciente_app/home/presentation/widgets/appointment_calendar.dart';
import 'package:fundacion_paciente_app/home/presentation/widgets/home_view.dart';
import 'package:fundacion_paciente_app/shared/presentation/widgets/header.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  static const String name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);

    // Verificar si el usuario está autenticado
    if (authState.authStatus != AuthStatus.authenticated ||
        authState.user == null) {
      // Redirigir al login si no está autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    ref.listen<AppointmentState>(appointmentProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colors.primary.withOpacity(0.05),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: colors.primary,
                ),
                tooltip: 'Cerrar sesión',
                onPressed: () {
                  // Mostrar diálogo de confirmación
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content:
                          const Text('¿Estás seguro que deseas cerrar sesión?'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: colors.primary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref.read(authProvider.notifier).logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          toolbarHeight: 80,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withOpacity(0.1),
                  colors.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 20, left: 40),
              child: Header(
                heightScale: 0.80,
                imagePath: 'assets/images/logo.png',
                title: 'Fundación de niños especiales',
                subtitle: '"SAN MIGUEL" FUNESAMI',
                item: 'Centro de Terapias',
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: colors.primary,
            indicatorWeight: 3,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurface.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.home_rounded, color: colors.primary),
                text: 'Inicio',
              ),
              Tab(
                icon: Icon(Icons.calendar_month_rounded, color: colors.primary),
                text: 'Calendario',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            HomeView(),
            AppointmentCalendar(),
          ],
        ),
      ),
    );
  }
}
