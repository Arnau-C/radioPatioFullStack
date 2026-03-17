import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiClient {
  static String get baseUrl {
    String host = 'localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = '10.0.2.2';
    }
    return 'http://$host:8080/api';
  }
}
