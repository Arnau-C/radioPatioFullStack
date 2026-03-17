import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/user_service.dart';

/// [UserProvider]
///
/// Este provider es una pieza central en la gestión del estado de la aplicación.
/// Su principal responsabilidad es mantener y proporcionar la información del
/// usuario que ha iniciado sesión.
///
/// Actúa como la "única fuente de verdad" para los datos del usuario. Cuando
/// un usuario inicia sesión o se registra, los datos se guardan aquí. El resto
/// de la aplicación (otras páginas y providers) puede acceder a esta información
/// para saber quién es el usuario actual, cuál es su rol, etc.
///
/// También gestiona operaciones directamente relacionadas con el usuario, como
/// la actualización de sus datos personales o la eliminación de su cuenta.
class UserProvider with ChangeNotifier {
  // Instancia del servicio para interactuar con la API de usuarios.
  final UserService _userService = UserService();

  // --- ESTADO INTERNO DEL PROVIDER ---

  // El objeto `AppUser` que contiene los datos del usuario en sesión. Es nulable.
  AppUser? _user;

  // Flag para indicar si hay una operación en curso (ej: actualizando datos).
  bool _isLoading = false;

  // Mensaje de error en caso de que una operación falle.
  String? _error;

  // --- GETTERS PÚBLICOS ---
  // Exponen el estado interno de forma segura (solo lectura).
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- MÉTODOS PÚBLICOS ---

  /// [setUser]
  ///
  /// Establece o actualiza el usuario en sesión.
  /// Este método es llamado típicamente por el `AuthProvider` después de un
  /// login o registro exitoso.
  ///
  /// Recibe un mapa de datos (generalmente desde una respuesta JSON de la API)
  /// y lo convierte en un objeto `AppUser`.
  void setUser(Map<String, dynamic> userData) {
    _user = AppUser.fromJson(userData);
    _error = null; // Limpia cualquier error anterior.
    notifyListeners(); // Notifica a los widgets que el usuario ha cambiado.
  }

  /// [clearUser]
  ///
  /// Limpia los datos del usuario, estableciéndolos a `null`.
  /// Esto se llama durante el proceso de logout para asegurar que la app
  /// refleje que ya no hay nadie en sesión.
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  /// [deleteAccount]
  ///
  /// Gestiona la eliminación de la cuenta del usuario actual.
  Future<bool> deleteAccount() async {
    // Guarda: no se puede eliminar una cuenta si no hay nadie en sesión.
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Llama al servicio para realizar la petición de borrado.
      await _userService.deleteAccount(_user!.username);
      _isLoading = false;
      // Si tiene éxito, limpia los datos del usuario de la app.
      clearUser();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// [updateUser]
  ///
  /// Actualiza los datos personales del usuario (nombre, apellidos, email).
  Future<bool> updateUser(Map<String, String> data) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Llama al servicio para enviar los datos actualizados al backend.
      await _userService.updateUser(_user!.username, data);

      // Si la llamada a la API tiene éxito, actualizamos los datos del usuario
      // localmente en el provider ("actualización optimista"). Esto evita tener que
      // hacer una nueva petición para obtener los datos actualizados.
      _user = AppUser(
        id: _user!.id,
        username: _user!.username,
        nombre: data['nombre'] ?? _user!.nombre,
        apellidos: data['apellidos'] ?? _user!.apellidos,
        email: data['email'] ?? _user!.email,
        rol: _user!.rol,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
