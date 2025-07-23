import 'package:paciente_citas_1/home/domain/entities/patient_entities.dart';

abstract class PatientRepository {
  Future<Patient> getPatient(String id);
}
