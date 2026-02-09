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
      'http://10.0.2.2:8080/api/auth/login',
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
      backgroundColor:
          const Color.fromARGB(
            255,
            223,
            156,
            136,
          ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                const SizedBox(
                  height: 50,
                ),

                Image.asset(
                  'lib/images/logo.png',
                  width: 220,
                  height: 220,
                ),

                const SizedBox(
                  height: 50,
                ),

                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(
                    color:
                        Color.fromARGB(
                          255,
                          0,
                          30,
                          53,
                        ),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                MyTextField(
                  controller:
                      usernameController,
                  hintText:
                      'Nombre de usuario',
                  obscureText: false,
                  errorMsg:
                      _usernameError,
                ),

                const SizedBox(
                  height: 10,
                ),

                MyTextField(
                  controller:
                      passwordController,
                  hintText:
                      'Contraseña',
                  obscureText: true,
                  errorMsg:
                      _passwordError,
                ),

                const SizedBox(
                  height: 10,
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal:
                            25.0,
                      ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .end,
                    children: [
                      Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors
                              .grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                MyButton(
                  onTap: signUserIn,
                ),

                const SizedBox(
                  height: 50,
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(
                        bottom: 20.0,
                      ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(
                          color: Colors
                              .grey[700],
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) =>
                                      const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Regístrate ahora',
                          style: TextStyle(
                            color:
                                Color.fromARGB(
                                  255,
                                  0,
                                  30,
                                  53,
                                ),
                            fontWeight:
                                FontWeight
                                    .bold,
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
