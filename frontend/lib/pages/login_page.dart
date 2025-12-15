import 'dart:convert'; // 1. Para convertir datos a JSON
import 'package:flutter/material.dart';
import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/user_page.dart'; // <--- IMPORTANTE: Importamos la UserPage
import 'package:http/http.dart' as http; // 2. Para hacer peticiones al Backend
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Controladores de texto para capturar los datos
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final storage = const FlutterSecureStorage();

  void signUserIn() async {
    // A) Mostramos círculo de carga
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Ajusta esta URL si usas Android Emulator a 'http://10.0.2.2:8080/api/auth/login'
    final String url = 'http://localhost:8080/api/auth/login';

    try {
      // C) Enviamos la petición POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      // D) Quitamos el círculo de carga
      if (mounted) Navigator.pop(context);

      // E) Comprobamos la respuesta
      if (response.statusCode == 200) {
        // --- ÉXITO: EL PUENTE ---
        final jsonResponse = jsonDecode(response.body);

        // 1. Guardamos el Token en la caja fuerte (persistencia)
        String token = jsonResponse['token'];
        await storage.write(key: 'jwt_token', value: token);
        print("Login exitoso. Token guardado.");

        // 2. Preparamos los datos para enviar a la siguiente pantalla
        // Ahora Java nos devuelve todo esto gracias al cambio que hicimos en AuthService
        Map<String, dynamic> datosUsuario = {
          'token': token,
          'username': jsonResponse['username'],
          'nombre': jsonResponse['nombre'],
          'apellidos': jsonResponse['apellidos'],
          'email': jsonResponse['email'],
          'rol': jsonResponse['rol'],
        };

        if (mounted) {
          // 3. NAVEGACIÓN (El Puente)
          // Usamos pushReplacement para que no puedan volver al login dando "atrás"
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(
                userData: datosUsuario,
              ), // <--- Pasamos la bandeja de datos
            ),
          );
        }
      } else {
        // --- ERROR (Credenciales malas) ---
        mostrarMensaje("Usuario o contraseña incorrectos", esError: true);
      }
    } catch (e) {
      // --- ERROR DE CONEXIÓN ---
      if (mounted) Navigator.pop(context); // Quitar carga si falla
      mostrarMensaje("No se pudo conectar con el servidor", esError: true);
      print("Error técnico: $e");
    }
  }

  void mostrarMensaje(String mensaje, {bool esError = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: esError
              ? Colors.red.shade400
              : Colors.green.shade400,
          title: Center(
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 156, 136),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                Image.asset('lib/images/logo.png', width: 200, height: 200),

                const SizedBox(height: 30),

                Text(
                  '¡Hola de nuevo!',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 30, 53),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // Campo Usuario
                MyTextField(
                  controller: usernameController,
                  hintText: 'Nombre de usuario',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Campo Contraseña
                MyTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Olvidaste contraseña
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // BOTÓN DE LOGIN
                MyButton(onTap: signUserIn),

                const SizedBox(height: 30),

                // Registro
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 53),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
