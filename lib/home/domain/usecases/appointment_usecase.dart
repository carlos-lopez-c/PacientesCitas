import 'package:fundacion_paciente_app/home/domain/entities/cita.entity.dart';
import 'package:fundacion_paciente_app/home/domain/entities/registerCita.entity.dart';
import 'package:fundacion_paciente_app/home/domain/repositories/appointment_repository.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/custom_error.dart';

class AppointmentUseCase {
  final AppointmentRepository repository;

  AppointmentUseCase(this.repository);

  /// 🔹 Obtener todas las citas de un paciente
  Future<List<Appointments>> fetchAppointments(String patientId) async {
    try {
      return await repository.getAppointments(patientId);
    } on CustomError catch (e) {
      throw e;
    }
  }

  /// 🔹 Obtener citas por fecha específica
  Future<List<Appointments>> fetchAppointmentsByDate(
      DateTime date, String patientId) async {
    try {
      return await repository.getAppointmentsByDate(date, patientId);
    } on CustomError catch (e) {
      throw e;
    }
  }

  /// 🔹 Crear una nueva cita
  Future<void> createAppointment(
      CreateAppointments appointment, String patientName) async {
    try {
      await repository.createAppointment(appointment, patientName);
    } on CustomError catch (e) {
      throw e;
    }
  }

  /// 🔹 Obtener citas en tiempo real
  Stream<List<Appointments>> streamAppointments(String patientId) {
    return repository.streamAppointments(patientId);
  }
}
