class Documento {
  final int id;
  final String titulo;
  final String creadorUsername;

  Documento({
    required this.id,
    required this.titulo,
    required this.creadorUsername,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      // IMPORTANTE: Accedemos al username de forma segura
      creadorUsername:
          (json['subidoPor'] != null && json['subidoPor']['username'] != null)
          ? json['subidoPor']['username']
          : 'Usuario desconocido',
    );
  }
}
