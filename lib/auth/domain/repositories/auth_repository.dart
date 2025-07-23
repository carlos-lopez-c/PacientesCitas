import 'package:paciente_citas_1/auth/domain/entities/user_entities.dart';
import 'package:paciente_citas_1/auth/domain/entities/user_register.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<bool> register(RequestData user);
  Future<User> checkAuthStatus();
  Future<User?> getCurrentUser();
  Future<void> logout();
  //forgot password
  Future<void> sendPasswordResetEmail(String email);
  // 2FA methods
  Future<String> sendPhoneVerification(String phoneNumber);
  Future<bool> verifyPhoneCode(String verificationId, String code);
  Future<String> resendPhoneCode(String phoneNumber);
  Future<bool> signOut();
}
