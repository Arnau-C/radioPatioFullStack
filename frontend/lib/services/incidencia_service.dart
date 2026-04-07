import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_client.dart';
import '../models/incidencia.dart';

class IncidenciaService {
  // OJO: Esta URL dependerá de cómo hagas el Controller en Java
  final String _baseUrl = '${ApiClient.baseUrl}/comunidades'; 

  Future<bool> crearIncidencia(int comunidadId, String titulo, String descripcion, String token) async {
    final url = Uri.parse('$_baseUrl/$comunidadId/incidencias');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'titulo': titulo,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; // Creada con éxito
      } else {
        print('Error al crear: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de red: $e');
      return false;
    }
  }
}