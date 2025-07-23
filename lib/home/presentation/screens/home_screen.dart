import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/home/presentation/providers/appointments_provider.dart';
import 'package:paciente_citas_1/home/presentation/widgets/appointment_calendar.dart';
import 'package:paciente_citas_1/home/presentation/widgets/home_view.dart';
import 'package:paciente_citas_1/notifications/presentation/providers/notification_provider.dart';
import 'package:paciente_citas_1/notifications/presentation/widgets/notification_dialog.dart';
import 'package:paciente_citas_1/shared/presentation/widgets/header.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  static const String name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final notificationState = ref.watch(notificationProvider);

    // Escuchar notificaciones push en foreground
    ref.listen(notificationStreamProvider, (previous, next) {
      next.whenData((notification) {
        if (!notification.read) {
          NotificationDialog.show(
            context,
            notification,
            onTap: () {
              // Navegar a la pantalla relevante según el tipo de notificación
              _handleNotificationTap(context, notification, ref);
            },
          );
        }
      });
    });

    // Ya no necesitamos la redirección manual aquí porque el GoRouter se encargará automáticamente
    // El usuario no autenticado será redirigido a login por el router

    // En lugar de verificar y redirigir, simplemente mostramos un indicador de carga
    // mientras esperamos que el GoRouter haga su trabajo
    if (authState.authStatus != AuthStatus.authenticated ||
        authState.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Verificando autenticación...',
                style: TextStyle(color: colors.primary),
              ),
            ],
          ),
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
            // Botón de prueba con estado de permisos

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
                          onPressed: () {
                            Navigator.pop(context);
                            ref.read(authProvider.notifier).signOut();
                          },
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

  void _handleNotificationTap(
      BuildContext context, notification, WidgetRef ref) {
    final notificationNotifier = ref.read(notificationProvider.notifier);
    notificationNotifier.markAsRead(notification.id);

    // Navegar según el tipo de notificación
    final type = notification.type;
    switch (type) {
      case 'new_appointment':
      case 'appointment_updated':
      case 'appointment_reminder':
        // Navegar al calendario y mostrar la cita específica
        DefaultTabController.of(context).animateTo(1);
        break;
      case 'appointment_cancelled':
        // Mostrar mensaje y refrescar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cita cancelada: ${notification.body}'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case 'status_changed':
        // Refrescar la lista de citas
        DefaultTabController.of(context).animateTo(0);
        break;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_appointment':
        return Icons.event_available;
      case 'appointment_updated':
        return Icons.update;
      case 'appointment_cancelled':
        return Icons.event_busy;
      case 'appointment_reminder':
        return Icons.alarm;
      case 'status_changed':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  void _showPermissionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Permisos de Notificaciones'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para recibir notificaciones sobre cambios en tus citas médicas, necesitamos activar las notificaciones.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Nuevas citas programadas',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                  Text(
                    '✅ Cambios de horario',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                  Text(
                    '✅ Confirmaciones de citas',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                  Text(
                    '✅ Recordatorios importantes',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _requestNotificationPermissions(context, ref);
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Activar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestNotificationPermissions(
      BuildContext context, WidgetRef ref) async {
    try {
      // Intentar solicitar permisos
      await ref.read(notificationProvider.notifier).requestPermissions();

      // Verificar si se otorgaron
      final hasPermission =
          await ref.read(notificationProvider.notifier).checkPermissions();

      if (hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Notificaciones activadas correctamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        _showSettingsDialog(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al activar notificaciones: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Configurar Manualmente'),
          ],
        ),
        content: const Text(
          'Para activar las notificaciones, ve a:\n\n'
          '1. Configuración del dispositivo\n'
          '2. Aplicaciones\n'
          '3. FUNESAMI\n'
          '4. Notificaciones\n'
          '5. Activa "Permitir notificaciones"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }
}
