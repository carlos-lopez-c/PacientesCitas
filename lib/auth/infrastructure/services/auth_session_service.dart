import 'package:paciente_citas_1/shared/infrastructure/services/key_value_storage_service.dart';

class AuthSessionService {
  final KeyValueStorageService _storage;
  
  AuthSessionService(this._storage);
  
  static const String _twoFactorCompletedKey = 'two_factor_completed';
  static const String _userIdKey = 'authenticated_user_id';
  static const String _sessionValidKey = 'session_valid';
  
  /// Marca que el usuario completó exitosamente el 2FA
  Future<void> setTwoFactorCompleted(String userId) async {
    await _storage.setKeyValue(_twoFactorCompletedKey, userId);
    await _storage.setKeyValue(_sessionValidKey, 'true');
  }
  
  /// Verifica si el usuario actual ya completó el 2FA
  Future<bool> hasTwoFactorCompleted(String userId) async {
    final completedUserId = await _storage.getValue<String>(_twoFactorCompletedKey);
    final sessionValid = await _storage.getValue<String>(_sessionValidKey);
    
    return completedUserId == userId && sessionValid == 'true';
  }
  
  /// Limpia el estado de sesión
  Future<void> clearSession() async {
    await _storage.removeKey(_twoFactorCompletedKey);
    await _storage.removeKey(_userIdKey);
    await _storage.removeKey(_sessionValidKey);
  }
  
  /// Verifica si hay una sesión válida
  Future<bool> hasValidSession() async {
    final sessionValid = await _storage.getValue<String>(_sessionValidKey);
    return sessionValid == 'true';
  }
  
  /// Invalida la sesión actual
  Future<void> invalidateSession() async {
    await _storage.setKeyValue(_sessionValidKey, 'false');
  }
}