
import 'package:paciente_citas_1/type_therapy/domain/datasources/type_therapy_datasource.dart';
import 'package:paciente_citas_1/type_therapy/domain/entities/type_therapy_entity.dart';
import 'package:paciente_citas_1/type_therapy/domain/repositories/type_therapy_repository.dart';
import 'package:paciente_citas_1/type_therapy/infrastructure/datasources/type_therapy_datasource_impl.dart';

class TypeTherapyRepositoryImpl implements TypeTherapyRepository {
  final TypeTherapyDatasource datasource;

  TypeTherapyRepositoryImpl({TypeTherapyDatasource? datasource})
      : datasource = datasource ?? TypeTherapyDatasourceImpl();

  @override
  Future<List<TypeTherapyEntity>> getTypeTherapies() {
    return datasource.getTypeTherapies();
  }
}
