import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthService {
  final _storage =
      const FlutterSecureStorage();
  final _deviceInfo =
      DeviceInfoPlugin();

  Future<String>
  _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo =
            await _deviceInfo
                .androidInfo;
        return "${androidInfo.model} (${androidInfo.brand} Android)";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo =
            await _deviceInfo.iosInfo;
        return "${iosInfo.utsname.machine} (iOS)";
      } else {
        return "App Flutter (Desktop/Web)";
      }
    } catch (e) {
      return "Dispositivo Desconocido";
    }
  }

  Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    String deviceName =
        await _getDeviceName();
    final url = Uri.parse(
      '${ApiClient.baseUrl}/auth/login',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'sistema': deviceName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await _storage.write(key: 'jwt_token', value: data['token']);
      return data;
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<Map<String, dynamic>> register(
    AppUser user,
    String password,
  ) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/auth/registro/nuevo',
    );

    late http.Response response;
    try {
      response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': user.nombre,
              'apellidos': user.apellidos,
              'email': user.email,
              'username': user.username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception(
        'La conexión tardó demasiado. El servidor puede estar iniciando. Inténtalo de nuevo.',
      );
    } on SocketException {
      throw Exception(
        'Sin conexión. Comprueba tu red e inténtalo de nuevo.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await _storage.write(key: 'jwt_token', value: data['token']);
      return data;
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  /// Extrae el mensaje de error del cuerpo de respuesta del backend.
  /// Soporta {"error":}, {"message":} y {"detail":}. Si no puede parsear,
  /// devuelve el body crudo para que el Snackbar muestre el error real.
  String _extractError(String body) {
    // Siempre imprimimos el body crudo en consola para debugging.
    debugPrint('[AuthService] Error body: $body');
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        if (data.containsKey('error') && data['error'] is String) {
          return data['error'] as String;
        }
        if (data.containsKey('message') && data['message'] is String) {
          return data['message'] as String;
        }
        if (data.containsKey('detail') && data['detail'] is String) {
          return data['detail'] as String;
        }
      }
    } catch (_) {}
    // Fallback: body crudo (truncado a 200 chars para que quepa en un Snackbar)
    return body.length > 200 ? body.substring(0, 200) : body;
  }

  Future<void> logout() async {
    await _storage.delete(
      key: 'jwt_token',
    );
  }
}
