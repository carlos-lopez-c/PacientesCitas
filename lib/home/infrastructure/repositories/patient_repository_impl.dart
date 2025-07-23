

import 'package:paciente_citas_1/home/domain/datasources/patient_datasource.dart';
import 'package:paciente_citas_1/home/domain/entities/patient_entities.dart';
import 'package:paciente_citas_1/home/domain/repositories/patient_repository.dart';
import 'package:paciente_citas_1/home/infrastructure/datasources/patient_datasource_impl.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientDatasource patientDatasource;

  PatientRepositoryImpl({PatientDatasource? patientDatasource})
      : patientDatasource = patientDatasource ?? PatientDatasourceImpl();

  @override
  Future<Patient> getPatient(String id) {
    return patientDatasource.getPatient(id);
  }
}
