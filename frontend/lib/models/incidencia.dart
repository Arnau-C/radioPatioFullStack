class Incidencia {
  final int? id;
  final String titulo;
  final String descripcion;
  final String estado; // PENDIENTE, EN_PROCESO, RESUELTA
  final String? fechaCreacion;
  final String? creadorUsername;

  Incidencia({
    this.id,
    required this.titulo,
    required this.descripcion,
    this.estado = 'PENDIENTE',
    this.fechaCreacion,
    this.creadorUsername,
  });

  // Para enviar los datos de Flutter al Backend de Java
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      // No enviamos estado, fecha ni creador al crear, porque el backend los pone solos o los saca del token
    };
  }

  // Para recibir los datos de Java a Flutter
  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'PENDIENTE',
      fechaCreacion: json['fechaCreacion'],
      creadorUsername: json['creador'] != null ? json['creador']['username'] : null,
    );
  }
}