import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:frontend/utils/api_client.dart';

class VisorPdfScreen extends StatelessWidget {
  final int docId;
  final String titulo;
  final String token;

  const VisorPdfScreen({
    super.key,
    required this.docId,
    required this.titulo,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    // Apuntamos a la ruta de descarga del backend que creamos antes
    final String pdfUrl = '${ApiClient.baseUrl}/documentos/descargar/$docId';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // El visor mágico que carga el PDF de internet y le pasa la llave (token)
      body: SfPdfViewer.network(
        pdfUrl,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}
