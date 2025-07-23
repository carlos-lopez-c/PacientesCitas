import 'package:paciente_citas_1/type_therapy/domain/entities/type_therapy_entity.dart';

abstract class TypeTherapyRepository {
  Future<List<TypeTherapyEntity>> getTypeTherapies();
}
