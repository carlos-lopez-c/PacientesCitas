import 'package:fundacion_paciente_app/auth/domain/entities/role_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_information_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_role_entities.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
      username: json['username'] ?? '', // Manejo de posibles nulos
      isActive: json['isActive'] ?? false, // Asegura valores predeterminados
      userInformation: UserInformationEntity(
        firstName: json['userInformation']['firstName'] ?? '',
        lastName: json['userInformation']['lastName'] ?? '',
        address: json['userInformation']['address'] ?? '',
        phone: json['userInformation']['phone'] ?? '',
        id: json['userInformation']['id'] ?? '',
      ),
      id: json['id'] ?? '',
      patientID: json['patientID'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] // Lista vacía si `userRoles` es nulo
      );
}
