import 'package:formz/formz.dart';

enum CedulaError {
  empty,
  format,
  invalid
} // ✅ Nuevo error para cédula inválida

class Cedula extends FormzInput<String, CedulaError> {
  static final RegExp cedulaRegExp = RegExp(r'^\d{10}$');

  const Cedula.pure() : super.pure('');
  const Cedula.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == CedulaError.empty) return 'El campo es requerido';
    if (displayError == CedulaError.format) return 'No tiene formato de cédula';
    if (displayError == CedulaError.invalid) return 'Cédula inválida';

    return null;
  }

  @override
  CedulaError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return CedulaError.empty;
    if (!cedulaRegExp.hasMatch(value)) return CedulaError.format;
    if (!_validarCedulaEcuatoriana(value)) {
      return CedulaError.invalid; // ✅ Validación final
    }

    return null;
  }

  /// 🔹 Validación completa de la cédula ecuatoriana
  bool _validarCedulaEcuatoriana(String cedula) {
    if (cedula.length != 10) return false;

    final int provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    final int tercerDigito = int.parse(cedula[2]);
    if (tercerDigito < 0 || tercerDigito > 6) return false;

    final List<int> coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int valor = int.parse(cedula[i]) * coeficientes[i];
      if (valor >= 10) valor -= 9;
      suma += valor;
    }

    final int digitoVerificadorCalculado = (10 - (suma % 10)) % 10;
    final int digitoVerificadorReal = int.parse(cedula[9]);

    return digitoVerificadorCalculado == digitoVerificadorReal;
  }
}
