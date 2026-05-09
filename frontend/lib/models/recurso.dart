class Recurso {
  final int id;
  final String nombre;
  final String? descripcion;
  final String tipoReserva;

  Recurso({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoReserva,
  });

  factory Recurso.fromJson(Map<String, dynamic> json) {
    return Recurso(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      tipoReserva: json['tipoReserva'] ?? 'POR_HORAS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipoReserva': tipoReserva,
    };
  }
}
