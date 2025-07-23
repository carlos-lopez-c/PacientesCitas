

import 'package:paciente_citas_1/home/domain/entities/cita.entity.dart';
import 'package:paciente_citas_1/home/domain/entities/registerCita.entity.dart';

abstract class AppointmentDatasource {
  Future<List<Appointments>> getAppointmentsByDate(
      DateTime date, String patientId);
  Future<List<Appointments>> getAppointments(String patientId);
  Future<void> createAppointment(
      CreateAppointments appointment, String patientName);
  Future<void> updateAppointment(Appointments appointment);
  Future<void> deleteAppointment(Appointments appointment);
  Stream<List<Appointments>> streamAppointments(String patientId);
}
