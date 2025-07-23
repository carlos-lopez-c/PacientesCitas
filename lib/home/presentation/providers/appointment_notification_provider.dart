import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/home/domain/entities/cita.entity.dart';
import 'package:paciente_citas_1/notifications/presentation/providers/notification_provider.dart';


final appointmentNotificationProvider = Provider<AppointmentNotificationService>((ref) {
  final notificationNotifier = ref.read(notificationProvider.notifier);
  return AppointmentNotificationService(notificationNotifier);
});

class AppointmentNotificationService {
  final NotificationNotifier _notificationNotifier;
  List<Appointments>? _previousAppointments;

  AppointmentNotificationService(this._notificationNotifier);

  void handleAppointmentChanges(List<Appointments> currentAppointments) {
    if (_previousAppointments != null) {
      _detectAppointmentChanges(_previousAppointments!, currentAppointments);
    }
    _previousAppointments = List.from(currentAppointments);
  }

  void _detectAppointmentChanges(
    List<Appointments> previous, 
    List<Appointments> current
  ) {
    // Detectar nuevas citas
    for (final appointment in current) {
      final existed = previous.any((p) => p.id == appointment.id);
      if (!existed) {
        _notificationNotifier.showLocalNotification(
          title: 'Nueva Cita Médica',
          body: 'Se ha programado una nueva cita para el ${appointment.date} a las ${appointment.appointmentTime}',
          data: {
            'type': 'new_appointment',
            'appointmentId': appointment.id,
            'date': appointment.date,
            'time': appointment.appointmentTime,
            'specialty': appointment.specialtyTherapy,
            'doctor': appointment.doctor,
          },
        );
      }
    }

    // Detectar cambios en citas existentes
    for (final currentAppointment in current) {
      final previousAppointment = previous.where(
        (p) => p.id == currentAppointment.id,
      ).firstOrNull;

      if (previousAppointment != null) {
        // Verificar cambios en el estado
        if (previousAppointment.status != currentAppointment.status) {
          String statusMessage = _getStatusMessage(currentAppointment.status);
          _notificationNotifier.showLocalNotification(
            title: 'Estado de Cita Actualizado',
            body: 'Su cita del ${currentAppointment.date} $statusMessage',
            data: {
              'type': 'status_changed',
              'appointmentId': currentAppointment.id,
              'newStatus': currentAppointment.status,
              'previousStatus': previousAppointment.status,
              'date': currentAppointment.date,
              'time': currentAppointment.appointmentTime,
            },
          );
        }

        // Verificar cambios en fecha u hora
        if (previousAppointment.date != currentAppointment.date ||
            previousAppointment.appointmentTime != currentAppointment.appointmentTime) {
          _notificationNotifier.showLocalNotification(
            title: 'Cita Reprogramada',
            body: 'Su cita ha sido reprogramada para el ${currentAppointment.date} a las ${currentAppointment.appointmentTime}',
            data: {
              'type': 'appointment_updated',
              'appointmentId': currentAppointment.id,
              'newDate': currentAppointment.date,
              'newTime': currentAppointment.appointmentTime,
              'previousDate': previousAppointment.date,
              'previousTime': previousAppointment.appointmentTime,
            },
          );
        }

        // Verificar cambios en doctor
        if (previousAppointment.doctor != currentAppointment.doctor) {
          _notificationNotifier.showLocalNotification(
            title: 'Doctor Asignado',
            body: 'Se ha asignado al Dr. ${currentAppointment.doctor} para su cita del ${currentAppointment.date}',
            data: {
              'type': 'doctor_assigned',
              'appointmentId': currentAppointment.id,
              'newDoctor': currentAppointment.doctor,
              'previousDoctor': previousAppointment.doctor,
              'date': currentAppointment.date,
              'time': currentAppointment.appointmentTime,
            },
          );
        }
      }
    }

    // Detectar citas canceladas/eliminadas
    for (final previousAppointment in previous) {
      final stillExists = current.any((c) => c.id == previousAppointment.id);
      if (!stillExists) {
        _notificationNotifier.showLocalNotification(
          title: 'Cita Cancelada',
          body: 'Su cita del ${previousAppointment.date} a las ${previousAppointment.appointmentTime} ha sido cancelada',
          data: {
            'type': 'appointment_cancelled',
            'appointmentId': previousAppointment.id,
            'date': previousAppointment.date,
            'time': previousAppointment.appointmentTime,
            'specialty': previousAppointment.specialtyTherapy,
            'doctor': previousAppointment.doctor,
          },
        );
      }
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return 'ha sido confirmada';
      case 'pendiente':
        return 'está pendiente de confirmación';
      case 'cancelada':
        return 'ha sido cancelada';
      case 'completada':
        return 'ha sido completada';
      case 'en_proceso':
        return 'está en proceso';
      default:
        return 'cambió de estado a: $status';
    }
  }

  void scheduleAppointmentReminder(Appointments appointment) {
    // Programar recordatorio 1 día antes
    final appointmentDate = DateTime.tryParse('${appointment.date} ${appointment.appointmentTime}');
    if (appointmentDate != null) {
      final reminderDate = appointmentDate.subtract(const Duration(days: 1));
      final now = DateTime.now();
      
      if (reminderDate.isAfter(now)) {
        _notificationNotifier.showLocalNotification(
          title: 'Recordatorio de Cita',
          body: 'Tienes una cita mañana a las ${appointment.appointmentTime} con ${appointment.doctor}',
          data: {
            'type': 'appointment_reminder',
            'appointmentId': appointment.id,
            'date': appointment.date,
            'time': appointment.appointmentTime,
            'specialty': appointment.specialtyTherapy,
            'doctor': appointment.doctor,
          },
        );
      }
    }
  }

  void clearPreviousAppointments() {
    _previousAppointments = null;
  }
}