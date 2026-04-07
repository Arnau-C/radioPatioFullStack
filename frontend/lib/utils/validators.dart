/// [Validators]
///
/// Clase de utilidad que agrupa métodos estáticos para la validación de
/// campos de formularios.
///
/// Al tener los validadores en una clase separada y estática, se promueve la
/// reutilización de código y se mantiene la lógica de validación centralizada,
/// facilitando su mantenimiento y consistencia a través de la aplicación.
class Validators {
  // Expresión regular para validar el formato de un correo electrónico.
  // Busca un patrón como "texto@texto.texto", siendo razonablemente permisivo.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$',
  );

  // Expresión regular para validar la fortaleza de una contraseña.
  // Requisitos:
  // - Al menos 8 caracteres de longitud (`{8,}`).
  // - Al menos una letra minúscula (`(?=.*[a-z])`).
  // - Al menos una letra mayúscula (`(?=.*[A-Z])`).
  // - Al menos un número (`(?=.*\d)`).
  // - Al menos un carácter especial de la lista `@$!%*?&` (`(?=.*[@$!%*?&])`).
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// [validateEmail]
  ///
  /// Valida que un `String` no sea nulo, no esté vacío y tenga un formato
  /// de email válido según la expresión regular `_emailRegex`.
  ///
  /// Devuelve un `String` con el mensaje de error si la validación falla,
  /// o `null` si el valor es válido.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Introduce un email válido';
    }
    return null;
  }

  /// [validatePassword]
  ///
  /// Valida la fortaleza de una contraseña.
  /// Comprueba que no sea nula/vacía y que cumpla con los requisitos
  /// de la expresión regular `_passwordRegex`.
  ///
  /// Devuelve un `String` con el mensaje de error detallado o `null` si es válida.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Mín. 8 caracteres, 1 Mayúscula, 1 Minúscula, 1 Número y 1 Especial (@\$!%*?&)';
    }
    return null;
  }

  /// [validateConfirmPassword]
  ///
  /// Comprueba que el campo de confirmación de contraseña coincida con la
  /// contraseña original. Esencial para evitar errores de tipeo en el registro.
  ///
  /// Devuelve un `String` con el mensaje de error o `null` si ambas contraseñas coinciden.
  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// [validateNotEmpty]
  ///
  /// Un validador genérico que comprueba que un `String` no sea nulo ni esté vacío.
  /// Es muy útil para campos de texto simples como "nombre" o "usuario".
  ///
  /// `fieldName` se usa para construir un mensaje de error dinámico (ej: "El nombre es obligatorio").
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El $fieldName es obligatorio';
    }
    return null;
  }

  /// [validateNotNull]
  ///
  /// Similar a `validateNotEmpty`, pero permite pasar un mensaje de error completamente
  /// personalizado en lugar de generarlo a partir del nombre del campo.
  static String? validateNotNull(String? value, String message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }
}
