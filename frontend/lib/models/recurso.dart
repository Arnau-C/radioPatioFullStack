class Recurso {
  final int id;
  final String nombre;
  final String? descripcion;
  
  // En Dart usamos 'int' o 'int?' en lugar del 'private Integer' de Java
  final int maxHorasReserva; 

  Recurso({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.maxHorasReserva = 2, // Le damos 2 horas por defecto por si el backend no manda nada
  });

  factory Recurso.fromJson(Map<String, dynamic> json) {
    return Recurso(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      // Recogemos el nuevo campo de la base de datos
      maxHorasReserva: json['maxHorasReserva'] ?? 2, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      // Enviamos el nuevo campo al backend al crear
      'maxHorasReserva': maxHorasReserva, 
    };
  }
}