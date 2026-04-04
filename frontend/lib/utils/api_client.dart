import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiClient {
  static String get baseUrl {
    // Si estás con el móvil por cable, pon la IP de tu PC aquí directamente
    // Puedes comentarla cuando vuelvas al emulador o a Linux Desktop
    String host = '192.168.1.79';

    // Solo si quieres que detecte automáticamente el emulador:
    // if (!kIsWeb && Platform.isAndroid) {
    //   host = '10.0.2.2'; // Esto solo sirve para el emulador, no para el móvil real
    // }

    return 'http://$host:8080/api';
  }
}
