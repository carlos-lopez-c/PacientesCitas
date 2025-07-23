import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:paciente_citas_1/home/domain/datasources/appointment_datasource.dart';
import 'package:paciente_citas_1/home/domain/entities/cita.entity.dart';
import 'package:paciente_citas_1/home/domain/entities/registerCita.entity.dart';
import 'package:paciente_citas_1/shared/infrastructure/errors/handle_error.dart';


class AppointmentDatasourceImpl implements AppointmentDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createAppointment(
      CreateAppointments appointment, String patientName) async {
    try {
      Map<String, dynamic> appointmentData = appointment.toJson();
      appointmentData['patient'] = patientName;

      await _firestore.collection('appointments').add(appointmentData);
      print("Cita creada correctamente en Firestore");
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> deleteAppointment(Appointments appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).delete();
      print("Cita eliminada correctamente en Firestore");
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<void> updateAppointment(Appointments appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toJson());
      print("Cita actualizada correctamente en Firestore");
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<List<Appointments>> getAppointmentsByDate(
      DateTime date, String patientId) async {
    try {
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Traer las citas del paciente en la fecha específica
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('date', isEqualTo: formattedDate)
          .where('patientID', isEqualTo: patientId)
          .get();

      // Traer todas las especialidades para mapear ID -> nombre
      QuerySnapshot specialtySnapshot =
          await _firestore.collection('specialtyTherapy').get();

      // Mapa de ID de especialidad -> nombre
      Map<String, String> specialtyMap = {
        for (var doc in specialtySnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? ''
      };

      // Convertir documentos a objetos Appointment y añadir el nombre de la especialidad
      List<Appointments> appointments = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Obtener el ID de la especialidad y su nombre
        String specialtyId = data['specialtyTherapyId'] ?? '';
        String specialtyName = specialtyMap[specialtyId] ?? 'Sin especialidad';

        // Sobrescribir el campo con el nombre
        data['specialtyTherapy'] = specialtyName;
        return Appointments.fromJson(data);
      }).toList();

      return appointments;
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Future<List<Appointments>> getAppointments(String patientId) async {
    try {
      // Obtener todas las citas del paciente
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('patientID', isEqualTo: patientId)
          .get();

      // Obtener todas las especialidades para mapear ID -> nombre
      QuerySnapshot specialtySnapshot =
          await _firestore.collection('specialtyTherapy').get();

      // Crear el mapa de ID -> nombre
      Map<String, String> specialtyMap = {
        for (var doc in specialtySnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? ''
      };

      // Convertir documentos a objetos Appointment y añadir el nombre de la especialidad
      List<Appointments> appointments = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String specialtyId = data['specialtyTherapyId'] ?? '';
        String specialtyName = specialtyMap[specialtyId] ?? 'Sin especialidad';

        // Sobrescribir el campo con el nombre de la especialidad
        data['specialtyTherapy'] = specialtyName;

        return Appointments.fromJson(data);
      }).toList();

      return appointments;
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }

  @override
  Stream<List<Appointments>> streamAppointments(String patientId) async* {
    try {
      // Obtener y guardar el mapa de especialidades una sola vez
      QuerySnapshot specialtySnapshot =
          await _firestore.collection('specialtyTherapy').get();

      final Map<String, String> specialtyMap = {
        for (var doc in specialtySnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? ''
      };

      // Escuchar cambios en las citas del paciente
      yield* _firestore
          .collection('appointments')
          .where('patientID', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          String specialtyId = data['specialtyTherapyId'] ?? '';
          String specialtyName =
              specialtyMap[specialtyId] ?? 'Sin especialidad';

          data['specialtyTherapy'] = specialtyName;

          return Appointments.fromJson(data);
        }).toList();
      });
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }
}
