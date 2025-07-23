

import 'package:paciente_citas_1/auth/domain/datasources/auth_datasource.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_entities.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_register.dart';
import 'package:paciente_citas_1/auth/domain/repositories/auth_repository.dart';
import 'package:paciente_citas_1/auth/infrastructure/datasources/auth_datasource_impl.dart';

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
  Future<User?> getCurrentUser() {
    return authDatasource.getCurrentUser();
  }

  @override
  Future<bool> register(RequestData user) {
    return authDatasource.register(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return authDatasource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> logout() {
    return authDatasource.logout();
  }

  @override
  Future<String> sendPhoneVerification(String phoneNumber) {
    return authDatasource.sendPhoneVerification(phoneNumber);
  }

  @override
  Future<bool> verifyPhoneCode(String verificationId, String code) {
    return authDatasource.verifyPhoneCode(verificationId, code);
  }

  @override
  Future<String> resendPhoneCode(String phoneNumber) {
    return authDatasource.resendPhoneCode(phoneNumber);
  }

  @override
  Future<bool> signOut() {
    return authDatasource.signOut();
  }
}
