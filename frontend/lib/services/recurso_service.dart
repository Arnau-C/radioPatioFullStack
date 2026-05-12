import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/recurso.dart';
import 'package:frontend/utils/api_client.dart';

class RecursoService {
  Future<List<Recurso>> obtenerRecursos(int comunidadId, String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/recursos/comunidad/$comunidadId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Recurso.fromJson(item)).toList();
    } else {
      throw Exception("Error al cargar recursos");
    }
  }

  Future<Recurso> crearRecurso(int comunidadId, String nombre, String descripcion, int maxHorasReserva, String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/recursos/$comunidadId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'maxHorasReserva': maxHorasReserva,
      }),
    );

    if (response.statusCode == 201) {
      return Recurso.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final errorMap = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorMap['error'] ?? "Error al crear recurso");
    }
  }

  Future<void> eliminarRecurso(int recursoId, String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/recursos/$recursoId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar recurso");
    }
  }
}
