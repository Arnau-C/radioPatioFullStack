import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

/// [UserService]
///
/// Este servicio maneja las operaciones de la API relacionadas con la gestión
/// de la cuenta de un usuario por sí mismo. Esto incluye la eliminación de
/// su propia cuenta y la modificación de sus datos personales.
class UserService {
  // Almacenamiento seguro para el token JWT.
  final _storage = const FlutterSecureStorage();

  // URL base para los endpoints de autenticación/usuario.
  final String _baseUrl = '${ApiClient.baseUrl}/auth';

  /// [_getToken]
  ///
  /// Método privado para obtener el token de autenticación del almacenamiento seguro.
  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception(
          'No se encontró el token de autenticación. Inicie sesión de nuevo.');
    }
    return token;
  }

  /// [deleteAccount]
  ///
  /// Envía una petición al backend para eliminar la cuenta del usuario especificado.
  /// Esta es una acción destructiva y permanente.
  Future<void> deleteAccount(String username) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/borrar/$username');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la cuenta: ${response.body}');
    }
  }

  /// [updateUser]
  ///
  /// Envía una petición para actualizar los datos de un usuario.
  /// `data` es un mapa que contiene los campos a modificar, por ejemplo:
  /// `{'nombre': 'Nuevo Nombre', 'email': 'nuevo@email.com'}`.
  Future<void> updateUser(String username, Map<String, String> data) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/modificar/$username');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al modificar el usuario: ${response.body}');
    }
  }
}
