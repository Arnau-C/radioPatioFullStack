import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/components/textfield.dart'; // Asegúrate que tu componente acepta errorMsg
import 'package:frontend/pages/login_page.dart';
import 'package:http/http.dart' as http;

class RegisterPage
    extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  // 1. CONTROLADORES
  final nombreController =
      TextEditingController();
  final apellidosController =
      TextEditingController();
  final emailController =
      TextEditingController();
  final usernameController =
      TextEditingController();
  final passwordController =
      TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  // 2. VARIABLES DE ERROR (Para mostrar texto rojo debajo de los inputs)
  String? _nombreError;
  String? _apellidosError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  final storage =
      const FlutterSecureStorage();

  // --- LÓGICA DE REGISTRO ---
  void signUserUp() async {
    // A. LIMPIEZA: Borramos errores previos para empezar de cero
    setState(() {
      _nombreError = null;
      _apellidosError = null;
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool hayErrores = false;

    // B. VALIDACIONES FRONTEND (Rápidas, antes de enviar nada)

    if (nombreController.text.isEmpty) {
      _nombreError =
          "El nombre es obligatorio";
      hayErrores = true;
    }

    if (apellidosController
        .text
        .isEmpty) {
      _apellidosError =
          "Los apellidos son obligatorios";
      hayErrores = true;
    }

    if (emailController.text.isEmpty) {
      _emailError =
          "El email es obligatorio";
      hayErrores = true;
    } else if (!emailController.text
        .contains('@')) {
      _emailError =
          "Introduce un email válido";
      hayErrores = true;
    }

    if (usernameController
        .text
        .isEmpty) {
      _usernameError =
          "El usuario es obligatorio";
      hayErrores = true;
    }

    // Regex: 8 chars, 1 Mayus, 1 Minus, 1 Num, 1 Especial (@$!%*?&)
    RegExp regexPassword = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (passwordController
        .text
        .isEmpty) {
      _passwordError =
          "La contraseña es obligatoria";
      hayErrores = true;
    } else if (!regexPassword.hasMatch(
      passwordController.text,
    )) {
      _passwordError =
          "Mín. 8 caracteres, 1 Mayúscula, 1 Minúscula, 1 Número y 1 Especial";
      hayErrores = true;
    }

    if (confirmPasswordController
        .text
        .isEmpty) {
      _confirmPasswordError =
          "Confirma tu contraseña";
      hayErrores = true;
    } else if (passwordController
            .text !=
        confirmPasswordController
            .text) {
      _confirmPasswordError =
          "Las contraseñas no coinciden";
      hayErrores = true;
    }

    // Si fallan validaciones locales, paramos aquí.
    if (hayErrores) {
      setState(() {});
      return;
    }

    // --- C. ENVÍO AL SERVIDOR ---

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child:
              CircularProgressIndicator(),
        );
      },
    );

    final url = Uri.parse(
      'http://127.0.0.1:8080/api/auth/registro',
    );

    try {
      final body = jsonEncode({
        'nombre': nombreController.text,
        'apellidos':
            apellidosController.text,
        'email': emailController.text,
        'username':
            usernameController.text,
        'password':
            passwordController.text,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json',
        },
        body: body,
      );

      if (mounted)
        Navigator.pop(
          context,
        ); // Cerrar loading

      if (response.statusCode == 200) {
        // --- ÉXITO ---
        final jsonResponse = jsonDecode(
          response.body,
        );
        String token =
            jsonResponse['token'];
        await storage.write(
          key: 'jwt_token',
          value: token,
        );

        mostrarMensaje(
          "¡Cuenta creada con éxito!",
          esError: false,
        );
        // Aquí podrías redirigir al Home
      } else {
        // --- ERROR DEL SERVIDOR (Lógica Nueva) ---
        String mensajeServidor =
            "Error al registrar";

        // 1. Intentamos leer el mensaje JSON limpio
        try {
          final errorJson = jsonDecode(
            response.body,
          );
          if (errorJson is Map &&
              errorJson.containsKey(
                'message',
              )) {
            mensajeServidor =
                errorJson['message'];
          }
        } catch (_) {
          // Si no es JSON, usamos el texto crudo si existe
          mensajeServidor =
              response.body.isNotEmpty
              ? response.body
              : "Error ${response.statusCode}";
        }

        // 2. Asignamos el error al campo correspondiente
        String msgLower =
            mensajeServidor
                .toLowerCase();
        bool errorAsignado = false;

        setState(() {
          // Si el mensaje dice "usuario" o "username", marcamos ese campo
          if (msgLower.contains(
                'usuario',
              ) ||
              msgLower.contains(
                'username',
              )) {
            _usernameError =
                mensajeServidor;
            errorAsignado = true;
          }

          // Si el mensaje dice "email" o "correo"
          if (msgLower.contains(
                'email',
              ) ||
              msgLower.contains(
                'correo',
              )) {
            _emailError =
                mensajeServidor;
            errorAsignado = true;
          }

          // Si el mensaje dice "password" o "contraseña"
          if (msgLower.contains(
                'password',
              ) ||
              msgLower.contains(
                'contraseña',
              )) {
            _passwordError =
                mensajeServidor;
            errorAsignado = true;
          }
        });

        // 3. Si no supimos a qué campo pertenece, mostramos el popup clásico
        if (!errorAsignado) {
          mostrarMensaje(
            mensajeServidor,
            esError: true,
          );
        }
      }
    } catch (e) {
      if (mounted)
        Navigator.pop(context);
      mostrarMensaje(
        "No se pudo conectar con el servidor",
        esError: true,
      );
    }
  }

  void mostrarMensaje(
    String mensaje, {
    bool esError = true,
  }) {
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // 1. FONDO CON DEGRADADO (Igual al Login)
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFDF9C88),
            Color(0xFFFDE8E1),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // LOGO (Tamaño moderado para que no desplace todo hacia abajo)
                Image.asset(
                  'lib/images/logo.png',
                  width: 150,
                  height: 150,
                ),

                const SizedBox(height: 20),

                // 2. TARJETA CENTRAL (Ancho controlado)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600, // Un poco más ancho para albergar los formularios
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 25.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              color: Color(0xFF001E35),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // CAMPOS EN GRUPOS PEQUEÑOS
                          MyTextField(
                            controller: nombreController,
                            hintText: 'Nombre',
                            obscureText: false,
                            errorMsg: _nombreError,
                          ),
                          const SizedBox(height: 12),

                          MyTextField(
                            controller: apellidosController,
                            hintText: 'Apellidos',
                            obscureText: false,
                            errorMsg: _apellidosError,
                          ),
                          const SizedBox(height: 12),

                          MyTextField(
                            controller: emailController,
                            hintText: 'Email',
                            obscureText: false,
                            errorMsg: _emailError,
                          ),
                          const SizedBox(height: 12),

                          MyTextField(
                            controller: usernameController,
                            hintText: 'Nombre de usuario',
                            obscureText: false,
                            errorMsg: _usernameError,
                          ),
                          const SizedBox(height: 12),

                          MyTextField(
                            controller: passwordController,
                            hintText: 'Contraseña',
                            obscureText: true,
                            errorMsg: _passwordError,
                          ),
                          const SizedBox(height: 12),

                          MyTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirmar Contraseña',
                            obscureText: true,
                            errorMsg: _confirmPasswordError,
                          ),

                          const SizedBox(height: 30),

                          // 3. BOTÓN ESTILIZADO (Igual al de Login)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: signUserUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF001E35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // LINK VOLVER AL LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Volver atrás al Login
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: Color(0xFF001E35),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}