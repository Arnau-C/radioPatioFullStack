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

  // Mensajes de error específicos para cada campo del formulario.
  // El patrón private/public (ej. _nombreError/nombreError) asegura que
  // desde fuera de la clase solo se pueda leer el estado, no modificarlo.
  String? _nombreError;
  String? get nombreError => _nombreError;

  String? _apellidosError;
  String? get apellidosError => _apellidosError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _usernameError;
  String? get usernameError => _usernameError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  String? _confirmPasswordError;
  String? get confirmPasswordError => _confirmPasswordError;

  // Mensaje de éxito general para operaciones como un registro exitoso.
  String? _successMessage;
  String? get successMessage => _successMessage;

  // --- MÉTODOS PÚBLICOS ---

  /// Limpia todos los mensajes de error y éxito.
  ///
  /// Se llama típicamente antes de iniciar una nueva operación de login/registro
  /// o cuando el usuario empieza a escribir en un campo, para ofrecer una
  /// experiencia de usuario más limpia.
  void clearAllMessages() {
    _nombreError = null;
    _apellidosError = null;
    _emailError = null;
    _usernameError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _successMessage = null;
    notifyListeners(); // Notifica a los listeners para que la UI se actualice.
  }

  /// Gestiona el proceso de inicio de sesión.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    clearAllMessages();

    // 1. Validación en el cliente (rápida y síncrona).
    _usernameError = Validators.validateNotEmpty(username, 'usuario');
    _passwordError = Validators.validateNotEmpty(password, 'contraseña');

    if (_usernameError != null || _passwordError != null) {
      notifyListeners(); // Muestra los errores de validación en la UI.
      return null;
    }

    // 2. Inicia el estado de carga.
    _isLoading = true;
    notifyListeners();

    // 3. Llama al servicio de autenticación.
    try {
      final userData = await _authService.login(username, password);
      return userData; // Devuelve los datos del usuario en caso de éxito.
    } catch (e) {
      // 4. Manejo de errores desde el backend.
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      String msgLower = errorMessage.toLowerCase();

      // Intenta asignar el error al campo más apropiado.
      if (msgLower.contains('usuario') || msgLower.contains('user')) {
        _usernameError = errorMessage;
      } else {
        _passwordError = errorMessage;
      }
      return null; // Devuelve nulo en caso de error.
    } finally {
      // 5. Finaliza el estado de carga, tanto en éxito como en error.
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
    required String confirmPassword,
  }) async {
    clearAllMessages();

    // 1. Validación en el cliente para todos los campos.
    _nombreError = Validators.validateNotEmpty(nombre, 'nombre');
    _apellidosError = Validators.validateNotEmpty(apellidos, 'apellidos');
    _emailError = Validators.validateEmail(email);
    _usernameError = Validators.validateNotEmpty(username, 'usuario');
    _passwordError = Validators.validatePassword(password);
    _confirmPasswordError =
        Validators.validateConfirmPassword(password, confirmPassword);

    if (_nombreError != null ||
        _apellidosError != null ||
        _emailError != null ||
        _usernameError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      notifyListeners(); // Muestra los errores en la UI.
      return null;
    }

    // 2. Inicia el estado de carga.
    _isLoading = true;
    notifyListeners();

    // 3. Llama al servicio de registro.
    try {
      final user = AppUser(
        nombre: nombre,
        apellidos: apellidos,
        email: email,
        username: username,
        rol: 'USER', // Por defecto, los nuevos usuarios tienen rol 'USER'.
      );
      final userData = await _authService.register(user, password);
      _successMessage = "¡Cuenta creada con éxito!";
      return userData;
    } catch (e) {
      // 4. Manejo de errores del backend.
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      String msgLower = errorMessage.toLowerCase();

      if (msgLower.contains('usuario') || msgLower.contains('username')) {
        _usernameError = errorMessage;
      } else if (msgLower.contains('email') || msgLower.contains('correo')) {
        _emailError = errorMessage;
      } else if (msgLower.contains('password') || msgLower.contains('contraseña')) {
        _passwordError = errorMessage;
      } else {
        // Un error genérico que no se puede asignar a un campo específico.
        _confirmPasswordError = errorMessage;
      }
      return null;
    } finally {
      // 5. Finaliza el estado de carga.
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
