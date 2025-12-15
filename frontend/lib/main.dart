import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart'; // <--- Tu login real

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // <--- Que arranque aquí
    );
  }
}
