import 'package:paciente_citas_1/home/domain/entities/patient_entities.dart';

abstract class PatientDatasource {
  Future<Patient> getPatient(String id);
}
