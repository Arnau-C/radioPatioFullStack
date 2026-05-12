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
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Usamos utf8.decode para evitar problemas con tildes o la 'ñ'
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Aviso.fromJson(item)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: No tienes permiso para ver los avisos');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener avisos: $e');
    }
  }

  // Crea un nuevo aviso (Ahora permite Presidente o Vecino con permiso)
  Future<Aviso> crearAviso(
    String titulo,
    String descripcion,
    String comunidadNombre, // <--- Necesario para el backend
    String username,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/crear'); // Asegúrate de que el endpoint sea /crear

    final Map<String, dynamic> avisoData = {
      'titulo': titulo,
      'descripcion': descripcion,
      'comunidadNombre': comunidadNombre,
      'username': username, // <--- Enviamos el autor para validar permisos en el Service
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(avisoData),
      );

      if (response.statusCode == 200) {
        return Aviso.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        // Si el backend lanza un 403, intentamos leer el mensaje de error de tu Map.of("error", ...)
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          throw Exception(errorData['error'] ?? 'Error al crear el aviso');
        } catch (_) {
          throw Exception('El servidor rechazó la publicación (Error ${response.statusCode})');
        }
      }
    } catch (e) {
      // Este catch evita el error de "Unexpected end of input" mostrando el mensaje real
      throw Exception('Error al crear aviso: $e');
    }
  }
}