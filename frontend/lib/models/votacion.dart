/// Resultado de una opción dentro de una votación.
/// Equivale al backend DTO OpcionDetalleDTO.
class OpcionDetalle {
  final int id;
  final String texto;
  final int votos;
  final double porcentaje; // 0.0 – 100.0

  OpcionDetalle({
    required this.id,
    required this.texto,
    required this.votos,
    required this.porcentaje,
  });

  factory OpcionDetalle.fromJson(Map<String, dynamic> json) {
    return OpcionDetalle(
      id: json['id'],
      texto: json['texto'],
      votos: (json['votos'] as num).toInt(),
      porcentaje: (json['porcentaje'] as num).toDouble(),
    );
  }
}

/// Vista completa de una votación con conteos actuales.
/// Equivale al backend DTO VotacionDetalleDTO.
class VotacionDetalle {
  final int id;
  final String titulo;
  final String? descripcion;
  final String estado; // "ABIERTA" | "CERRADA"
  final String creadorUsername;
  final DateTime fechaCreacion;
  final DateTime? fechaLimite;

  /// ¿El usuario autenticado ya ha votado en esta votación?
  final bool yaVotado;

  /// Id de la opción que eligió el usuario (null si no ha votado).
  final int? opcionVotadaId;

  final int totalVotos;
  final List<OpcionDetalle> opciones;

  VotacionDetalle({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.estado,
    required this.creadorUsername,
    required this.fechaCreacion,
    this.fechaLimite,
    required this.yaVotado,
    this.opcionVotadaId,
    required this.totalVotos,
    required this.opciones,
  });

  bool get estaAbierta => estado == 'ABIERTA';

  factory VotacionDetalle.fromJson(Map<String, dynamic> json) {
    return VotacionDetalle(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'ABIERTA',
      creadorUsername: json['creadorUsername'] ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaLimite: json['fechaLimite'] != null
          ? DateTime.parse(json['fechaLimite'])
          : null,
      yaVotado: json['yaVotado'] ?? false,
      opcionVotadaId: json['opcionVotadaId'],
      totalVotos: (json['totalVotos'] as num?)?.toInt() ?? 0,
      opciones: (json['opciones'] as List<dynamic>? ?? [])
          .map((o) => OpcionDetalle.fromJson(o))
          .toList(),
    );
  }
}
