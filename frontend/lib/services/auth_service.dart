import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _deviceInfo = DeviceInfoPlugin();

  Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return "${androidInfo.model} (${androidInfo.brand} Android)";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return "${iosInfo.utsname.machine} (iOS)";
      } else {
        return "App Flutter (Desktop/Web)";
      }
    } catch (e) {
      return "Dispositivo Desconocido";
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    String deviceName = await _getDeviceName();
    final url = Uri.parse('${ApiClient.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'sistema': deviceName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token']);
      return data;
    } else {
      // Lanza un error con el mensaje del servidor o uno genérico.
      String errorMessage = "Error al iniciar sesión";
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else {
          errorMessage = response.body;
        }
      } catch (_) {
         errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> register(AppUser user, String password) async {
    final url = Uri.parse('${ApiClient.baseUrl}/auth/registro');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': user.nombre,
        'apellidos': user.apellidos,
        'email': user.email,
        'username': user.username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token']);
      return data;
    } else {
      String errorMessage = "Error durante el registro";
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else {
          errorMessage = response.body;
        }
      } catch (_) {
        errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
