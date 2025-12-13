import 'package:flutter/material.dart';
// Asegúrate de que el import coincida con el nombre de tu proyecto (en tu caso parece ser 'frontend')
import 'package:frontend/pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN: Quitamos el 'const' aquí porque LoginPage ya tiene controladores y no es constante [1]
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
