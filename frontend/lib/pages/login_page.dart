import 'dart:convert'; // 1. Para convertir datos a JSON
import 'package:flutter/material.dart';
import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/register_page.dart';
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
    final String url = 'http://localhost:8080/api/auth/login'; // URL del backend (ajustada para emulador linux)
    
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

      // D) Quitamos el círculo de carga (si el widget sigue activo)
      if (mounted) Navigator.pop(context);

      // E) Comprobamos la respuesta
      if (response.statusCode == 200) {
        // --- ÉXITO ---
        final jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['token'];

        // F) Guardamos el Token en la caja fuerte
        await storage.write(key: 'jwt_token', value: token);
        print("Token guardado: $token");

        // Mensaje de éxito
        mostrarMensaje("¡Login Correcto!", esError: false);

        // AQUÍ IRÍA LA NAVEGACIÓN A LA HOME PAGE:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));

      } else {
        // --- ERROR (Credenciales malas) ---
        mostrarMensaje("Usuario o contraseña incorrectos", esError: true);
      }
    } catch (e) {
      // --- ERROR DE CONEXIÓN ---
      if (mounted) Navigator.pop(context);
      mostrarMensaje("No se pudo conectar con el servidor", esError: true);
      print("Error técnico: $e");
    }
  }
  void mostrarMensaje(String mensaje, {bool esError = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: esError ? Colors.red.shade400 : Colors.green.shade400,
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
      // Tu color de fondo original (Salmón)
      backgroundColor: const Color.fromARGB(255, 223, 156, 136),
      body: SafeArea(
        child: Center(
          // SingleChildScrollView evita error de píxeles si el teclado sube
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Logo
                Image.asset(
                  'lib/images/logo.png',
                  width:
                      200, // Ajusté un poco el tamaño para que quepa todo mejor
                  height: 200,
                ),

                const SizedBox(height: 30),

                // Texto de Bienvenida
                Text(
                  '¡Hola de nuevo!',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 30, 53), // Azul Marino
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // 3. CAMPO USUARIO (Ahora pasamos los parámetros correctamente)
                // Antes daba error porque MyTextField() estaba vacío
                MyTextField(
                  controller: usernameController,
                  hintText: 'Nombre de usuario',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // 4. CAMPO CONTRASEÑA
                MyTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true, // true para ocultar texto
                ),

                const SizedBox(height: 10),

                // Olvidaste contraseña (Opcional, decorativo por ahora)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors.grey,
                        ), // Gris oscuro para contraste
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // BOTÓN DE LOGIN
                MyButton(onTap: signUserIn),

                const SizedBox(height: 30),

                // 5. SECCIÓN DE REGISTRO (Navegación a RegisterPage)
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
                          // Navegar a la página de registro
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
                            color: Color.fromARGB(
                              255,
                              0,
                              30,
                              53,
                            ), // Azul Marino
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
