import 'package:paciente_citas_1/home/domain/datasources/appointment_datasource.dart';
import 'package:paciente_citas_1/home/domain/entities/cita.entity.dart';
import 'package:paciente_citas_1/home/domain/entities/registerCita.entity.dart';
import 'package:paciente_citas_1/home/domain/repositories/appointment_repository.dart';
import 'package:paciente_citas_1/home/infrastructure/datasources/appointment_datasource_impl.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentDatasource datasource;

  AppointmentRepositoryImpl({AppointmentDatasource? datasource})
      : datasource = datasource ?? AppointmentDatasourceImpl();
  @override
  Future<void> createAppointment(
      CreateAppointments appointment, String patientName) {
    return datasource.createAppointment(appointment, patientName);
  }

  @override
  Future<void> deleteAppointment(Appointments appointment) {
    return datasource.deleteAppointment(appointment);
  }

  @override
  Future<List<Appointments>> getAppointments(String patientId) {
    return datasource.getAppointments(patientId);
  }

  @override
  Future<List<Appointments>> getAppointmentsByDate(
      DateTime date, String patientId) {
    return datasource.getAppointmentsByDate(date, patientId);
  }

  @override
  Future<void> updateAppointment(Appointments appointment) {
    return datasource.updateAppointment(appointment);
  }

  @override
  Stream<List<Appointments>> streamAppointments(String patientId) {
    return datasource.streamAppointments(patientId);
  }
}
