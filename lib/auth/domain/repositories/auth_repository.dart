import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<bool> register(RequestData user);
  Future<User> checkAuthStatus();
  Future<void> logout();
  //forgot password
  Future<void> sendCode(String email);
  //validate code
  Future<void> validateCode(String email, String code);
  Future<void> resetPassword(String email, String token, String newPassword);
}
