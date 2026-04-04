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
      id: json['id'],
      titulo: json['titulo'],
      // El backend nos devuelve el objeto Usuario entero en 'subidoPor'
      creadorUsername: json['subidoPor'] != null
          ? json['subidoPor']['username']
          : 'Desconocido',
    );
  }
}
