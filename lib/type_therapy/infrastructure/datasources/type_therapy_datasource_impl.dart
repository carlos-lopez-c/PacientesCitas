import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:paciente_citas_1/shared/infrastructure/errors/handle_error.dart';
import 'package:paciente_citas_1/type_therapy/domain/datasources/type_therapy_datasource.dart';
import 'package:paciente_citas_1/type_therapy/domain/entities/type_therapy_entity.dart';

class TypeTherapyDatasourceImpl implements TypeTherapyDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<TypeTherapyEntity>> getTypeTherapies() async {
    try {
      // Filtrar solo los documentos que tengan name = "Terapia" o "Psicología"
      QuerySnapshot querySnapshot = await _firestore
          .collection('specialtyTherapy')
          .where('name', whereIn: ['Terapia', 'Psicología']).get();

      List<TypeTherapyEntity> typeTherapies = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TypeTherapyEntity.fromJson(data);
      }).toList();

      return typeTherapies;
    } on FirebaseException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseException(e);
    } on PlatformException catch (e) {
      throw FirebaseErrorHandler.handlePlatformException(e);
    } catch (e) {
      throw FirebaseErrorHandler.handleGenericException(e);
    }
  }
}
