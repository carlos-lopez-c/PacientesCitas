import 'package:fundacion_paciente_app/auth/domain/datasources/auth_datasource.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_entities.dart';
import 'package:fundacion_paciente_app/auth/domain/entities/user_register.dart';
import 'package:fundacion_paciente_app/auth/domain/repositories/auth_repository.dart';
import 'package:fundacion_paciente_app/auth/infrastructure/datasources/auth_datasource_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource authDatasource;

  AuthRepositoryImpl({AuthDatasource? authDatasource})
      : authDatasource = authDatasource ?? FirebaseAuthDatasource();

  @override
  Future<User> login(String email, String password) {
    return authDatasource.login(email, password);
  }

  @override
  Future<User> checkAuthStatus() {
    return authDatasource.checkAuthStatus();
  }

  @override
  Future<bool> register(RequestData user) {
    return authDatasource.register(user);
  }

  @override
  Future<void> sendCode(String email) {
    return authDatasource.sendCode(email);
  }

  @override
  Future<void> validateCode(String email, String code) {
    return authDatasource.validateCode(email, code);
  }

  @override
  Future<void> resetPassword(String email, String token, String newPassword) {
    return authDatasource.resetPassword(email, token, newPassword);
  }

  @override
  Future<void> logout() {
    return authDatasource.logout();
  }
}
