import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/votacion.dart';
import 'package:frontend/utils/api_client.dart';

/// Excepción tipada para errores de votaciones.
/// Permite distinguir errores de negocio (ya votaste, votación cerrada)
/// de errores genéricos de red.
class VotacionException implements Exception {
  final String message;
  final int? statusCode;

  VotacionException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class VotacionService {
  final String _base = '${ApiClient.baseUrl}/votaciones';

  // ---------------------------------------------------------------------------
  // LISTAR VOTACIONES DE UNA COMUNIDAD
  // GET /api/votaciones/comunidad/{comunidadId}
  // ---------------------------------------------------------------------------

  Future<List<VotacionDetalle>> listarVotaciones(
      int comunidadId, String token) async {
    final url = Uri.parse('$_base/comunidad/$comunidadId');

    final response = await http.get(url, headers: _headers(token));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => VotacionDetalle.fromJson(json)).toList();
    } else {
      throw VotacionException(
        _parseError(response, 'Error al cargar las votaciones.'),
        statusCode: response.statusCode,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // OBTENER DETALLE — polling (llamado cada ~4s mientras el usuario está en pantalla)
  // GET /api/votaciones/{votacionId}
  // ---------------------------------------------------------------------------

  Future<VotacionDetalle> obtenerDetalle(int votacionId, String token) async {
    final url = Uri.parse('$_base/$votacionId');

    final response = await http.get(url, headers: _headers(token));

    if (response.statusCode == 200) {
      return VotacionDetalle.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw VotacionException(
        _parseError(response, 'Error al obtener la votación.'),
        statusCode: response.statusCode,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // CREAR VOTACIÓN (solo PRESIDENTE)
  // POST /api/votaciones/comunidad/{comunidadId}
  // ---------------------------------------------------------------------------

  Future<VotacionDetalle> crearVotacion({
    required int comunidadId,
    required String titulo,
    String? descripcion,
    required List<String> opciones,
    DateTime? fechaLimite,
    required String token,
  }) async {
    final url = Uri.parse('$_base/comunidad/$comunidadId');

    final body = <String, dynamic>{
      'titulo': titulo,
      'opciones': opciones,
      if (descripcion != null && descripcion.isNotEmpty)
        'descripcion': descripcion,
      if (fechaLimite != null) 'fechaLimite': fechaLimite.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return VotacionDetalle.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw VotacionException(
        _parseError(response, 'Error al crear la votación.'),
        statusCode: response.statusCode,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // EMITIR VOTO
  // POST /api/votaciones/{votacionId}/votar
  // ---------------------------------------------------------------------------

  Future<VotacionDetalle> emitirVoto(
      int votacionId, int opcionId, String token) async {
    final url = Uri.parse('$_base/$votacionId/votar');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({'opcionId': opcionId}),
    );

    if (response.statusCode == 201) {
      return VotacionDetalle.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw VotacionException(
        _parseError(response, 'Error al registrar el voto.'),
        statusCode: response.statusCode,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // CERRAR VOTACIÓN (solo PRESIDENTE)
  // PUT /api/votaciones/{votacionId}/cerrar
  // ---------------------------------------------------------------------------

  Future<VotacionDetalle> cerrarVotacion(int votacionId, String token) async {
    final url = Uri.parse('$_base/$votacionId/cerrar');

    final response = await http.put(url, headers: _headers(token));

    if (response.statusCode == 200) {
      return VotacionDetalle.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw VotacionException(
        _parseError(response, 'Error al cerrar la votación.'),
        statusCode: response.statusCode,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS PRIVADOS
  // ---------------------------------------------------------------------------

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Intenta extraer el mensaje de error del cuerpo JSON del backend.
  /// Si no es JSON o el campo no existe, devuelve [fallback].
  String _parseError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return (body['error'] ?? body['message'] ?? fallback) as String;
    } catch (_) {
      return fallback;
    }
  }
}
