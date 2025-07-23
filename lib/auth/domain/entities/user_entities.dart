import 'package:paciente_citas_1/auth/domain/entities/user_information_entities.dart';

class User {
  String id;
  String email;
  String username;
  bool isActive;
  UserInformationEntity userInformation;
  String role;
  String patientID;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isActive,
    required this.userInformation,
    required this.role,
    required this.patientID,
  });
}
