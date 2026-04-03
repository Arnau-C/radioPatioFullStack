import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:frontend/models/aviso.dart';
import 'package:frontend/utils/api_client.dart';

class AvisoService {
  final String _baseUrl = '${ApiClient.baseUrl}/avisos';

  // Obtiene los avisos de una fecha (Petición GET)
  Future<List<Aviso>> getAvisosPorFecha(DateTime fecha, String token) async {
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    final url = Uri.parse('$_baseUrl?fecha=$fechaStr');

    try {
      final response = await http.get(
        url,
        // 2. AÑADE LAS CABECERAS CON EL TOKEN:
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Aviso.fromJson(item)).toList();
      } else {
        throw Exception('Error 403: No tienes permiso o el token expiró');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener avisos: $e');
    }
  }

  // Crea un nuevo aviso (Petición POST - Solo Presidente)
  // Necesitamos el token JWT para la seguridad
  Future<Aviso> crearAviso(
    String titulo,
    String descripcion,
    DateTime fecha,
    String username,
    String token,
  ) async {
    final url = Uri.parse(_baseUrl);
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);

    final Map<String, dynamic> avisoData = {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fechaStr,
      'usernameCreador': username,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Vital para la seguridad
        },
        body: jsonEncode(avisoData),
      );

      if (response.statusCode == 200) {
        return Aviso.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Error al crear aviso: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al crear aviso: $e');
    }
  }
}
