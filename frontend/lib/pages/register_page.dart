import 'dart:convert'; // [1] Necesario para convertir el mapa a JSON
import 'package:flutter/material.dart';
import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';
import 'package:http/http.dart' as http; // [2] Librería para peticiones HTTP

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de texto
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();

  // Método para registrar al usuario
  void registerUser() async {
    // 1. Mostrar círculo de carga para feedback visual
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // 2. Preparar la URL
    // NOTA PARA EL EQUIPO:
    // - Tú en Linux usa: 'http://localhost:8080/api/auth/registro'
    // - Tus compañeros en Emulador Android deben usar: 'http://10.0.2.2:8080/api/auth/registro'
    final url = Uri.parse('http://localhost:8080/api/auth/registro');

    // 3. Crear el Mapa de datos (JSON Object)
    // Las claves (izq) deben ser IDÉNTICAS a los atributos de tu clase Java 'Usuario' [3]
    final Map<String, dynamic> datosUsuario = {
      "username": usernameController.text,
      "password": passwordController.text,
      "nombre": nombreController.text,
      "apellidos": apellidosController.text,
      "email": emailController.text,
      "rol": "USER", // Asignamos un rol por defecto
      "intentosFallidos": 0,
      "cuentaBloqueada": false,
    };

    try {
      // 4. Enviar la petición POST
      final response = await http.post(
        url,
        // Es VITAL especificar que enviamos JSON, si no Spring Boot lo rechaza [4]
        headers: {"Content-Type": "application/json"},
        // Convertimos el mapa de Dart a un String JSON
        body: jsonEncode(datosUsuario),
      );

      // Cerrar el círculo de carga
      if (mounted) Navigator.pop(context);

      // 5. Manejar la respuesta del servidor [5]
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Éxito: 201 Created es lo ideal
        mostrarMensaje("¡Usuario creado con éxito!");
      } else {
        // Error: Puede ser 409 (Conflicto/Ya existe) o 400 (Bad Request)
        mostrarMensaje("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      // Error de conexión (aquí caeremos si falta CORS o el server está apagado)
      if (mounted) Navigator.pop(context);
      mostrarMensaje("Error de conexión: $e");
    }
  }

  // Método auxiliar para mostrar alertas
  void mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
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
                const SizedBox(height: 25),
                // Logo
                Image.asset('lib/images/logo.png', width: 100, height: 100),
                const SizedBox(height: 25),

                Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 30, 53),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                // Campos de texto (Usando tu componente MyTextField actualizado)
                MyTextField(
                  controller: nombreController,
                  hintText: 'Nombre',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: apellidosController,
                  hintText: 'Apellidos',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Usuario',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // Botón de registro
                MyButton(
                  onTap: registerUser, // Conectamos el botón a la función
                ),

                const SizedBox(height: 25),

                // Botón para volver al Login
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Volver al Login',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 30, 53),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
