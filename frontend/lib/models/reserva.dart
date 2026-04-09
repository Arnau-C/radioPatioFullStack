class Reserva {
  final int? id;
  final int recursoId;
  final String usuarioUsername;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;

  Reserva({
    this.id,
    required this.recursoId,
    required this.usuarioUsername,
    required this.fechaInicio,
    required this.fechaFin,
    this.estado = 'ACTIVA',
  });

  // Para enviar a Spring Boot (convirtiendo DateTime a String ISO-8601)
  Map<String, dynamic> toJson() {
    return {
      'recurso': {
        'id': recursoId,
      }, // Spring Boot espera un objeto Recurso
      'usuario': {
        'username': usuarioUsername,
      }, // Spring Boot espera un objeto Usuario
      'fechaInicio': fechaInicio
          .toIso8601String(),
      'fechaFin': fechaFin
          .toIso8601String(),
      'estado': estado,
    };
  }
}
