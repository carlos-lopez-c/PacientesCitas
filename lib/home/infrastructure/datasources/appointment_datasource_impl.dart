import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fundacion_paciente_app/home/domain/datasources/appointment_datasource.dart';
import 'package:fundacion_paciente_app/home/domain/entities/cita.entity.dart';
import 'package:fundacion_paciente_app/home/domain/entities/registerCita.entity.dart';
import 'package:fundacion_paciente_app/shared/infrastructure/errors/handle_error.dart';

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

      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('date', isEqualTo: formattedDate)
          .where('patientID', isEqualTo: patientId)
          .get();

      List<Appointments> appointments = querySnapshot.docs
          .map((doc) =>
              Appointments.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

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
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('patientID', isEqualTo: patientId)
          .get();

      List<Appointments> appointments = querySnapshot.docs
          .map((doc) =>
              Appointments.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

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
  Stream<List<Appointments>> streamAppointments(String patientId) {
    try {
      return _firestore
          .collection('appointments')
          .where('patientID', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  Appointments.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }
}
