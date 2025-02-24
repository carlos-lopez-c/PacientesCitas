import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fundacion_paciente_app/home/domain/datasources/appointment_datasource.dart';
import 'package:fundacion_paciente_app/home/domain/entities/cita.entity.dart';
import 'package:fundacion_paciente_app/home/domain/entities/registerCita.entity.dart';

class AppointmentDatasourceImpl implements AppointmentDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createAppointment(
      CreateAppointments appointment, String patientName) async {
    try {
      // Convierte el objeto appointment a un mapa
      Map<String, dynamic> appointmentData = appointment.toJson();
      // Agrega el nombre del paciente al mapa\
      print("Nombre del paciente: $patientName");
      appointmentData['patient'] = patientName;
      // Agrega la cita a la colección "appointments" en Firestore
      await _firestore.collection('appointments').add(appointmentData);
      print("Cita creada correctamente en Firestore");
    } catch (e) {
      print("Error al crear la cita: $e");
      throw Exception('Error al crear la cita');
    }
  }

  @override
  Future<void> deleteAppointment(Appointments appointment) async {
    try {
      // Elimina la cita por su ID
      await _firestore.collection('appointments').doc(appointment.id).delete();
      print("Cita eliminada correctamente en Firestore");
    } catch (e) {
      print("Error al eliminar la cita: $e");
      throw Exception('Error al eliminar la cita');
    }
  }

  @override
  Future<void> updateAppointment(Appointments appointment) async {
    try {
      // Actualiza la cita por su ID
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toJson());
      print("Cita actualizada correctamente en Firestore");
    } catch (e) {
      print("Error al actualizar la cita: $e");
      throw Exception('Error al actualizar la cita');
    }
  }

  @override
  Future<List<Appointments>> getAppointmentsByDate(
      DateTime date, String patientId) async {
    try {
      // Formatea la fecha para que coincida con el formato almacenado en Firestore
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Consulta las citas que coinciden con la fecha y el patientId proporcionados
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('date', isEqualTo: formattedDate)
          .where('patientId', isEqualTo: patientId)
          .get();

      // Mapea los documentos obtenidos a objetos Appointments
      List<Appointments> appointments = querySnapshot.docs
          .map((doc) =>
              Appointments.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return appointments;
    } catch (e) {
      print("Error al obtener las citas: $e");
      throw Exception('Error al obtener las citas');
    }
  }

  @override
  Future<List<Appointments>> getAppointments(String patientId) async {
    try {
      // Obtiene todas las citas de la colección "appointments"
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('patientID', isEqualTo: patientId)
          .get();

      // Mapea los documentos obtenidos a objetos Appointments
      List<Appointments> appointments = querySnapshot.docs
          .map((doc) =>
              Appointments.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return appointments;
    } catch (e) {
      print("Error al obtener las citas: $e");
      throw Exception('Error al obtener las citas');
    }
  }
}
