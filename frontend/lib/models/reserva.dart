class Reserva {
  final int? id;
  final int recursoId;
  final String? recursoNombre;
  final String usuarioUsername;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;

  Reserva({
    this.id,
    required this.recursoId,
    this.recursoNombre,
    required this.usuarioUsername,
    required this.fechaInicio,
    required this.fechaFin,
    this.estado = 'ACTIVA',
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      recursoId: json['recurso'] != null ? json['recurso']['id'] : 0,
      recursoNombre: json['recurso'] != null ? json['recurso']['nombre'] : 'Desconocido',
      usuarioUsername: json['usuario'] != null ? json['usuario']['username'] : '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      estado: json['estado'] ?? 'ACTIVA',
    );
  }

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
