import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/reserva.dart';
import 'package:frontend/utils/api_client.dart';

class ReservaException
    implements Exception {
  final String message;
  ReservaException(this.message);
}

class ReservaService {
  Future<void> crearReserva(
    Reserva reserva,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/api/reservas',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json',
          'Authorization':
              'Bearer $token',
        },
        body: jsonEncode(
          reserva.toJson(),
        ),
      );

      if (response.statusCode == 201) {
        // Todo fue bien, reserva creada
        return;
      } else if (response.statusCode ==
          409) {
        // Conflicto de solapamiento capturado desde Spring Boot
        final errorData = jsonDecode(
          utf8.decode(
            response.bodyBytes,
          ),
        );
        throw ReservaException(
          errorData['error'] ??
              "El recurso ya está reservado en ese horario.",
        );
      } else if (response.statusCode ==
          400) {
        // Fechas mal introducidas (inicio después de fin, etc)
        final errorData = jsonDecode(
          utf8.decode(
            response.bodyBytes,
          ),
        );
        throw ReservaException(
          errorData['error'] ??
              "Error en las fechas de la reserva.",
        );
      } else {
        throw ReservaException(
          "Error del servidor: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (e is ReservaException)
        rethrow;
      throw ReservaException(
        "No se pudo conectar con el servidor.",
      );
    }
  }
}
