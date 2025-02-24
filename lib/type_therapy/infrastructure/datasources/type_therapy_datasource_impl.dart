import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fundacion_paciente_app/type_therapy/domain/datasources/type_therapy_datasource.dart';
import 'package:fundacion_paciente_app/type_therapy/domain/entities/type_therapy_entity.dart';

class TypeTherapyDatasourceImpl implements TypeTherapyDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<TypeTherapyEntity>> getTypeTherapies() async {
    try {
      // Obtiene la colección de 'specialtyTherapy'
      QuerySnapshot querySnapshot =
          await _firestore.collection('specialtyTherapy').get();

      // Mapea los documentos a una lista de TypeTherapyEntity
      List<TypeTherapyEntity> typeTherapies = querySnapshot.docs.map((doc) {
        // Obtiene los datos del documento
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Añade el ID del documento a los datos
        data['id'] = doc.id;

        // Crea una instancia de TypeTherapyEntity con los datos modificados
        return TypeTherapyEntity.fromJson(data);
      }).toList();

      return typeTherapies;
    } catch (e) {
      print('Error al obtener las especialidades de terapia: $e');
      throw Exception('Error al obtener las especialidades de terapia');
    }
  }
}
