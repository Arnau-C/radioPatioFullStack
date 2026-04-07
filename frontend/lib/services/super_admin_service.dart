import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

/// [SuperAdminService]
///
/// Este servicio se encarga de la comunicación con los endpoints de la API
/// que están restringidos al rol de SUPER_ADMIN.
///
/// Sus responsabilidades incluyen la gestión completa de usuarios: obtener la
/// lista de todos los usuarios, crear nuevos, actualizarlos (por ejemplo,
/// para bloquearlos) y eliminarlos. Cada método corresponde a una llamada a la API.
class SuperAdminService {
  // Almacenamiento seguro para el token JWT.
  final _storage = const FlutterSecureStorage();

  // URL base para los endpoints de superadmin, construida a partir del ApiClient.
  final String _baseUrl = '${ApiClient.baseUrl}/superadmin';

  /// [_getToken]
  ///
  /// Método privado y reutilizable para obtener el token de autenticación.
  /// Esencial para autorizar las peticiones a endpoints protegidos.
  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception(
          'No se encontró el token de autenticación. Inicie sesión de nuevo.');
    }
    return token;
  }

  /// [getUsers]
  ///
  /// Obtiene una lista de todos los usuarios registrados en la aplicación.
  Future<List<AppUser>> getUsers() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/users');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodifica la lista de JSONs
      // y la convierte en una lista de objetos `AppUser`.
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => AppUser.fromJson(json)).toList();
    } else {
      // Si el servidor devuelve un error, lanza una excepción.
      throw Exception('Error al cargar usuarios: ${response.body}');
    }
  }

  /// [createUser]
  ///
  /// Envía una petición para crear un nuevo usuario con los datos y contraseña proporcionados.
  Future<AppUser> createUser(AppUser user, String password) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/users/create');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        // Combina los datos del usuario (convertidos a JSON) con la contraseña.
        ...user.toJson(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Devuelve el usuario recién creado, ahora con el ID asignado por el backend.
      return AppUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el usuario: ${response.body}');
    }
  }

  /// [updateUser]
  ///
  /// Actualiza uno o más campos de un usuario específico, identificado por su `username`.
  /// `data` es un mapa que contiene solo los campos a modificar.
  /// Por ejemplo: `{'cuentaBloqueada': true}`.
  Future<void> updateUser(String username, Map<String, dynamic> data) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/users/$username');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el usuario: ${response.body}');
    }
  }

  /// [deleteUser]
  ///
  /// Elimina un usuario del sistema de forma permanente.
  Future<void> deleteUser(String username) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/users/$username');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el usuario: ${response.body}');
    }
  }
}
