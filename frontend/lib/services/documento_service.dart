import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:frontend/models/carpeta.dart';
import 'package:frontend/models/documento.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http_parser/http_parser.dart';

class DocumentoService {
  final String _baseUrl = '${ApiClient.baseUrl}/documentos';

  // --- CARPETAS ---
  Future<List<Carpeta>> getCarpetas(
    String comunidadNombre,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/carpetas/$comunidadNombre');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((e) => Carpeta.fromJson(e)).toList();
    }
    throw Exception('Error al obtener carpetas');
  }

  Future<void> crearCarpeta(
    String nombre,
    String comunidadNombre,
    String token,
    String username, // <--- Nuevo parámetro
  ) async {
    final url = Uri.parse('$_baseUrl/carpetas');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre, 
        'comunidadNombre': comunidadNombre,
        'username': username // <--- Enviado al backend
      }),
    );
    if (response.statusCode != 200) throw Exception('Error al crear carpeta');
  }

  Future<void> renombrarCarpeta(
    int id,
    String nuevoNombre,
    String token,
    String username, // <--- Nuevo parámetro
  ) async {
    final url = Uri.parse('$_baseUrl/carpetas/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nuevoNombre': nuevoNombre,
        'username': username // <--- Enviado al backend
      }),
    );
    if (response.statusCode != 200) throw Exception('Error al renombrar');
  }

  Future<void> borrarCarpeta(int id, String token, String username) async {
    // Para el DELETE, lo enviamos como Query Parameter (?username=...)
    final url = Uri.parse('$_baseUrl/carpetas/$id?username=$username');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Error al borrar la carpeta');
    }
  }

  // --- DOCUMENTOS ---
  Future<List<Documento>> getDocumentos(int carpetaId, String token) async {
    final url = Uri.parse('$_baseUrl/carpeta/$carpetaId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((e) => Documento.fromJson(e)).toList();
    }
    throw Exception('Error al obtener documentos');
  }

  Future<void> subirPDF(
    PlatformFile file,
    int carpetaId,
    String username,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/subir');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['carpetaId'] = carpetaId.toString();
    request.fields['username'] = username;

    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ),
      );
    } else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error desconocido');
      } catch (e) {
        throw Exception('Error del servidor (Código ${response.statusCode})');
      }
    }
  }

  Future<void> moverDocumento(
    int docId,
    int nuevaCarpetaId,
    String token,
    String username, // <--- Nuevo parámetro
  ) async {
    final url = Uri.parse('$_baseUrl/mover/$docId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nuevaCarpetaId': nuevaCarpetaId,
        'username': username // <--- Enviado al backend
      }),
    );
    if (response.statusCode != 200) throw Exception('Error al mover documento');
  }

  Future<void> borrarDocumento(int id, String token, String username) async {
    // Para el DELETE, lo enviamos como Query Parameter
    final url = Uri.parse('$_baseUrl/$id?username=$username');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Error al borrar el archivo');
    }
  }
}