import 'dart:convert';
import 'dart:io'; // <--- 1. NECESARIO PARA DETECTAR LA PLATAFORMA (Android/iOS)
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart'; // <--- 2. IMPORTAR EL PAQUETE NUEVO

// TUS PÁGINAS
import 'package:frontend/pages/super_admin_page.dart';
import 'package:frontend/pages/user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final usernameController =
      TextEditingController();
  final passwordController =
      TextEditingController();

  String? _usernameError;
  String? _passwordError;

  final storage =
      const FlutterSecureStorage();

  // Instancia para obtener info del dispositivo
  final DeviceInfoPlugin deviceInfo =
      DeviceInfoPlugin();

  // --- NUEVA FUNCIÓN MÁGICA PARA OBTENER EL NOMBRE ---
  Future<String>
  obtenerNombreDispositivo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo =
            await deviceInfo
                .androidInfo;
        // Devuelve ej: "Samsung S21 (Android)" o "Pixel 6 (Android)"
        return "${androidInfo.model} (${androidInfo.brand} Android)";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo =
            await deviceInfo.iosInfo;
        // Devuelve ej: "iPhone 13 (iOS)"
        return "${iosInfo.utsname.machine} (iOS)";
      } else {
        return "App Flutter (Escritorio/Web)";
      }
    } catch (e) {
      return "Dispositivo Desconocido";
    }
  }

  // --- LÓGICA DE INICIO DE SESIÓN ---
  void signUserIn() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    bool hayErrores = false;
    if (usernameController
        .text
        .isEmpty) {
      _usernameError =
          "Ingresa tu usuario";
      hayErrores = true;
    }
    if (passwordController
        .text
        .isEmpty) {
      _passwordError =
          "Ingresa tu contraseña";
      hayErrores = true;
    }

    if (hayErrores) {
      setState(() {});
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child:
              CircularProgressIndicator(),
        );
      },
    );

    // 1. OBTENEMOS EL NOMBRE REAL DEL MÓVIL ANTES DE ENVIAR NADA
    String nombreDispositivo =
        await obtenerNombreDispositivo();

    final url = Uri.parse(
      'http://127.0.0.1:8080/api/auth/login',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'username':
              usernameController.text,
          'password':
              passwordController.text,
          // 2. ENVIAMOS EL NOMBRE REAL (Ej: "Pixel 4 (google Android)")
          'sistema': nombreDispositivo,
        }),
      );

      if (mounted)
        Navigator.pop(context);

      if (response.statusCode == 200) {
        // --- ÉXITO ---
        final jsonResponse = jsonDecode(
          response.body,
        );
        String token =
            jsonResponse['token'];
        String rol =
            jsonResponse['rol'];

        await storage.write(
          key: 'jwt_token',
          value: token,
        );

        if (mounted) {
          if (rol == 'SUPER_ADMIN') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SuperAdminPage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserPage(
                      userData:
                          jsonResponse,
                    ),
              ),
            );
          }
        }
      } else {
        // --- ERROR ---
        String mensajeServidor =
            "Error al iniciar sesión";
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
          mensajeServidor =
              response.body;
        }

        setState(() {
          String msgLower =
              mensajeServidor
                  .toLowerCase();
          if (msgLower.contains(
                'usuario',
              ) ||
              msgLower.contains(
                'user',
              )) {
            _usernameError =
                mensajeServidor;
          } else if (msgLower.contains(
                'contraseña',
              ) ||
              msgLower.contains(
                'password',
              ) ||
              msgLower.contains(
                'credenciales',
              ) ||
              msgLower.contains(
                'bloqueada',
              ) ||
              msgLower.contains(
                'intentos',
              )) {
            _passwordError =
                mensajeServidor;
          } else {
            mostrarAlerta(
              mensajeServidor,
            );
          }
        });
      }
    } catch (e) {
      if (mounted)
        Navigator.pop(context);
      mostrarAlerta(
        "Error de conexión con el servidor",
      );
    }
  }

  void mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.red.shade400,
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
            // El padding horizontal ayuda a que la Card no pegue a los bordes
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                
                // 1. LOGO MÁS GRANDE Y SIN SOMBRA ALREDEDOR
                Image.asset(
                  'lib/images/logo.png',
                  width: 280,  // Aumentado de 180 a 280
                  height: 280, // Aumentado de 180 a 280
                ),

                const SizedBox(height: 20),

                // 2. RECUADRO (CARD) MÁS PEQUEÑO EN ANCHO
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 550,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          const Text(
                            'Bienvenido de nuevo',
                            style: TextStyle(
                              color: Color(0xFF001E35),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

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

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signUserIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF001E35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 5),
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
                        'Regístrate ahora',
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
