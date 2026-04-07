import 'package:intl/intl.dart';

class Aviso {
  final int? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaAviso;
  final String?
  creadorUsername; // Opcional, por si queremos mostrar quién lo creó

  Aviso({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaAviso,
    this.creadorUsername,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      // El backend envía YYYY-MM-DD, lo convertimos a DateTime
      fechaAviso: DateTime.parse(json['fechaAviso']),
      // Asumimos que el backend envía el username del creador en el JSON
      creadorUsername: json['creador']?['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      // Convertimos DateTime a YYYY-MM-DD para el backend
      'fechaAviso': DateFormat('yyyy-MM-dd').format(fechaAviso),
    };
  }
}
