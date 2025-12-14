import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. CONTROLADORES (Ajustados a tu modelo Usuario.java)
  final nombreController = TextEditingController();    // Antes firstname
  final apellidosController = TextEditingController(); // Antes lastname
  final emailController = TextEditingController();     // ¡ESTE ES EL IMPORTANTE!
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final storage = const FlutterSecureStorage();
  
  void signUserUp() async {
    // Validar contraseñas
    if (passwordController.text != confirmPasswordController.text) {
      mostrarMensaje("Las contraseñas no coinciden", esError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // URL (Recuerda: 10.0.2.2 para emulador, localhost para web)
    final url = Uri.parse('http://localhost:8080/api/auth/registro'); 

    try {
      // 2. EL JSON EXACTO (Coincidiendo con tus campos Java)
      final body = jsonEncode({
        'nombre': nombreController.text,       // Java: private String nombre;
        'apellidos': apellidosController.text, // Java: private String apellidos;
        'email': emailController.text,         // Java: private String email;
        'username': usernameController.text,   // Java: private String username;
        'password': passwordController.text,   // Java: private String password;
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        // ÉXITO
        final jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['token'];
        await storage.write(key: 'jwt_token', value: token);
        mostrarMensaje("¡Cuenta creada con éxito!", esError: false);
        
        // Opcional: Ir al Home
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        // ERROR
        debugPrint("CÓDIGO DE ERROR: ${response.statusCode}"); // <--- Esto saldrá en la consola
        print("CUERPO DEL ERROR: ${response.body}");       // <--- Esto saldrá en la consola
        mostrarMensaje("Error ${response.statusCode}: ${response.body}", esError: true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      mostrarMensaje("Error de conexión", esError: true);
      print("Error: $e");
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
              style: const TextStyle(color: Colors.white, fontSize: 14),
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
                const SizedBox(height: 25),
                Image.asset('lib/images/logo.png', width: 100, height: 100),
                const SizedBox(height: 25),

                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 30, 53),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                // --- FORMULARIO AJUSTADO ---
                
                // 1. Nombre
                MyTextField(controller: nombreController, hintText: 'Nombre', obscureText: false),
                const SizedBox(height: 10),
                
                // 2. Apellidos
                MyTextField(controller: apellidosController, hintText: 'Apellidos', obscureText: false),
                const SizedBox(height: 10),
                
                // 3. Email (Fundamental según tu Usuario.java)
                MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                const SizedBox(height: 10),
                
                // 4. Username (ID)
                MyTextField(controller: usernameController, hintText: 'Nombre de usuario', obscureText: false),
                const SizedBox(height: 10),
                
                // 5. Password
                MyTextField(controller: passwordController, hintText: 'Contraseña', obscureText: true),
                const SizedBox(height: 10),

                // 6. Confirmar Password
                MyTextField(controller: confirmPasswordController, hintText: 'Confirmar Contraseña', obscureText: true),

                const SizedBox(height: 25),

                // Botón
                GestureDetector(
                    onTap: signUserUp,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text("Registrarse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                ),

                const SizedBox(height: 30),

                // Volver al Login
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                        child: const Text('Inicia sesión', style: TextStyle(color: Color.fromARGB(255, 0, 30, 53), fontWeight: FontWeight.bold)),
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