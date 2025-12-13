import 'package:flutter/material.dart';
import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/register_page.dart'; // Asegúrate de importar tu página de registro

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // 1. Controladores de texto para capturar los datos
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // 2. Método de inicio de sesión (lo conectaremos a Spring Boot luego)
  void signUserIn() {
    print("Iniciando sesión con: ${usernameController.text}");
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
