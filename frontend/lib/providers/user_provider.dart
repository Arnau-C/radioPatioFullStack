import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  AppUser? _user;
  String? _token; // <--- 1. AÑADE ESTA VARIABLE PARA EL TOKEN

  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  String? get token => _token; // <--- 2. AÑADE ESTE GETTER PARA PODER USARLO
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(Map<String, dynamic> userData) {
    _user = AppUser.fromJson(userData);

    // 3. EXTRAE EL TOKEN DEL MAPA (Asegúrate de que la clave sea 'token')
    _token = userData['token'];

    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = null; // <--- 4. LIMPIA EL TOKEN AL CERRAR SESIÓN
    notifyListeners();
  }

  // ... (El resto de métodos deleteAccount y updateUser se quedan igual)

  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _userService.deleteAccount(_user!.username);
      _isLoading = false;
      clearUser();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(Map<String, String> data) async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _userService.updateUser(_user!.username, data);
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
