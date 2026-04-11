import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/validators.dart';

/// [AuthProvider]
///
/// Gestiona el estado y la lógica de negocio relacionados con la autenticación
/// (login, registro y logout).
///
/// Utiliza `ChangeNotifier` para notificar a los widgets que lo escuchan
/// (los `Consumer`) cuando su estado cambia, permitiendo que la UI se actualice
/// de forma reactiva (por ejemplo, para mostrar un `CircularProgressIndicator`
/// o un mensaje de error).
class AuthProvider with ChangeNotifier {
  // Instancia del servicio que realiza las llamadas a la API.
  final AuthService _authService = AuthService();

  // --- ESTADO INTERNO DEL PROVIDER ---

  // Controla si hay una operación de autenticación en curso (ej. cargando).
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Mensaje de error general para mostrar en snackbars si el backend falla.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Mensaje de éxito general para operaciones como un registro exitoso.
  String? _successMessage;
  String? get successMessage => _successMessage;

  // --- MÉTODOS PÚBLICOS ---

  /// Limpia los mensajes.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Gestiona el proceso de inicio de sesión.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.login(username, password);
      return userData; 
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gestiona el proceso de registro de un nuevo usuario.
  Future<Map<String, dynamic>?> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String username,
    required String password,
  }) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    try {
      final user = AppUser(
        nombre: nombre,
        apellidos: apellidos,
        email: email,
        username: username,
        rol: 'USER',
      );
      final userData = await _authService.register(user, password);
      _successMessage = "¡Cuenta creada con éxito!";
      return userData;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gestiona el cierre de sesión.
  Future<void> logout(UserProvider userProvider) async {
    await _authService.logout(); // Llama al servicio para limpiar el token local.
    userProvider.clearUser(); // Limpia los datos del usuario en el UserProvider.
    notifyListeners(); // Notifica por si algún widget depende de este estado.
  }
}
