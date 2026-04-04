class Carpeta {
  final int id;
  final String nombre;
  final bool esPrincipal;

  Carpeta({required this.id, required this.nombre, required this.esPrincipal});

  factory Carpeta.fromJson(Map<String, dynamic> json) {
    return Carpeta(
      id: json['id'],
      nombre: json['nombre'],
      esPrincipal: json['esPrincipal'] ?? false,
    );
  }
}
