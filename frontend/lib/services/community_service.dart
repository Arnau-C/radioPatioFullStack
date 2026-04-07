import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

/// [CommunityService]
///
/// Este servicio encapsula toda la lógica de comunicación con la API del backend
/// para las operaciones relacionadas con las comunidades de vecinos.
///
/// Su responsabilidad es construir las peticiones HTTP (POST, GET, etc.),
/// añadir las cabeceras necesarias (como el token de autenticación),
/// enviar la petición y procesar la respuesta.
///
/// Cada método de este servicio corresponde a un endpoint específico de la API.
class CommunityService {
  // Instancia para el almacenamiento seguro del token JWT.
  final _storage = const FlutterSecureStorage();

  // URL base de la API, obtenida del cliente centralizado para adaptarse a cada plataforma.
  final String _baseUrl = '${ApiClient.baseUrl}/comunidades';

  /// [_getToken]
  ///
  /// Método privado para obtener el token de autenticación del almacenamiento seguro.
  /// Lanza una excepción si el token no se encuentra, ya que es necesario para
  /// todas las operaciones de este servicio.
  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }
    return token;
  }

  /// [createCommunity]
  ///
  /// Envía una petición al backend para crear una nueva comunidad.
  ///
  /// Requiere el nombre de la comunidad, su dirección y el nombre de usuario
  /// de quien será el presidente.
  Future<Map<String, dynamic>> createCommunity({
    required String nombre,
    required String direccion,
    required String presidenteUsername,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/crear');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // El token es crucial para la autorización.
      },
      body: jsonEncode({
        'nombre': nombre,
        'direccion': direccion,
        'presidenteUsername': presidenteUsername,
      }),
    );

    if (response.statusCode == 200) {
      // Si el servidor responde con 200 OK, decodifica el cuerpo JSON y lo devuelve.
      return jsonDecode(response.body);
    } else {
      // Si hay un error, lanza una excepción con el mensaje del servidor.
      throw Exception('Error al crear la comunidad: ${response.body}');
    }
  }

  /// [joinCommunity]
  ///
  /// Envía una petición para que un usuario se una a una comunidad existente
  /// mediante un código de invitación.
  Future<Map<String, dynamic>> joinCommunity({
    required String codigo,
    required String username,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/unirse');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'codigo': codigo,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al unirse a la comunidad: ${response.body}');
    }
  }

  /// [getCommunityDetails]
  ///
  /// Obtiene los detalles de la comunidad a la que pertenece un usuario.
  Future<Map<String, dynamic>> getCommunityDetails(String username) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/detalle/$username');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Error al obtener detalles de la comunidad: ${response.body}');
    }
  }
}
