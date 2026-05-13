class Recurso {
  final int id;
  final String nombre;
  final String? descripcion;
  final String tipoReserva;
  final int maxHorasReserva;

  Recurso({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoReserva,
    this.maxHorasReserva = 2,
  });

  factory Recurso.fromJson(Map<String, dynamic> json) {
    return Recurso(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      tipoReserva: json['tipoReserva'] ?? 'POR_HORAS',
      maxHorasReserva: json['maxHorasReserva'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipoReserva': tipoReserva,
      'maxHorasReserva': maxHorasReserva,
    };
  }

  @override
  bool operator ==(Object other) => other is Recurso && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
