import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiClient {
  static String get baseUrl {
    // Si estás con el móvil por cable, pon la IP de tu PC aquí directamente
    // Puedes comentarla cuando vuelvas al emulador o a Linux Desktop
    // Solo si quieres que detecte automáticamente el emulador:
    // if (!kIsWeb && Platform.isAndroid) {
    //   host = '10.0.2.2'; // Esto solo sirve para el emulador, no para el móvil real
    // }
    // http://127.0.0.1:8080/api
    //return 'http://192.120.239.57:8080/api';
    //return 'https://radiopatiofullstackbackend.onrender.com/api';

    return 'http://127.0.0.1:8080/api';
  }
}
