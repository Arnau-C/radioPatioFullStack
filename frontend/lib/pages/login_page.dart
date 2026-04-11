import 'package:flutter/material.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/utils/validators.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:frontend/pages/home_screen.dart';
import 'package:frontend/components/glass_background.dart';

import 'package:frontend/pages/super_admin_page.dart';
import 'package:frontend/pages/user_page.dart';

/// [LoginPage]
///
/// Pantalla de inicio de sesión para los usuarios de la aplicación.
///
/// Es un `StatefulWidget` para poder manejar el estado de los campos de texto
/// y la lógica de la autenticación (carga, éxito, error).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// [_LoginPageState]
///
/// Gestiona la lógica y el estado de la [LoginPage].
class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos de texto de usuario y contraseña.
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instancia del proveedor de autenticación para la lógica de login.
  late AuthProvider _authProvider;

  /// [initState]
  ///
  /// Se ejecuta al inicializar el estado del widget.
  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  /// [dispose]
  ///
  /// Libera los recursos de los controladores cuando el widget se destruye
  /// para evitar fugas de memoria.
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Gestiona el proceso de inicio de sesión.
  Future<void> _handleLogin() async {
    // Validar form local antes de enviar
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Llama al método de login del proveedor con los datos introducidos.
    final userData = await _authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    // Si el login es exitoso y el widget sigue montado...
    if (userData != null && mounted) {
      // Asegúrate de que esto pase el objeto 'userData' completo (que lleva el token dentro)
      Provider.of<UserProvider>(context, listen: false).setUser(userData);

      // 2. Redirige al usuario a la página correspondiente según su rol.
      //    Usamos `pushReplacement` para que no pueda volver a la pantalla de login.
      final String rol = userData['rol'];

      if (rol == 'SUPER_ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuperAdminPage()),
        );
      } else if (rol == 'USER') {
        // --- SI ES USUARIO NUEVO, AL PERFIL ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserPage()),
        );
      } else {
        // --- SI YA TIENE COMUNIDAD (VECINO/PRESIDENTE), AL HOME ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  /// [build]
  ///
  /// Construye la interfaz de usuario de la página de login.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              // Limitamos el ancho del formulario en pantallas grandes.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Logo de la aplicación.
                    Image.asset('lib/images/logo.png', width: 280, height: 280),
                    const SizedBox(height: 20),

                    // Tarjeta de cristal ultra pulido (Apple Glassmorphism).
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          padding: const EdgeInsets.all(35.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 30,
                                spreadRadius: -5,
                              )
                            ]
                          ),
                          // Consumer se suscribe a AuthProvider para redibujarse
                          // si hay cambios (ej: mostrar errores o un loader).
                        child: Consumer<AuthProvider>(
                          builder: (context, provider, child) {
                            return Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                // Título del formulario.
                                const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    color: Color(0xFF001E35),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Campos de texto para usuario y contraseña.
                                MyTextField(
                                  controller: _usernameController,
                                  hintText: 'Nombre de usuario',
                                  obscureText: false,
                                  prefixIcon: Icons.person_outline,
                                  validator: (val) => Validators.validateNotEmpty(val, 'usuario'),
                                ),
                                const SizedBox(height: 12),
                                MyTextField(
                                  controller: _passwordController,
                                  hintText: 'Contraseña',
                                  obscureText: true,
                                  prefixIcon: Icons.lock_outline,
                                  validator: (val) => Validators.validateNotEmpty(val, 'contraseña'),
                                ),
                                const SizedBox(height: 8),

                                // Enlace "Olvidaste tu contraseña".
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                if (provider.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      provider.errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: provider.isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF001E35), Color(0xFF00335A)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF001E35).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: provider.isLoading
                                            ? const CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              )
                                            : const Text(
                                                'Iniciar Sesión',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                    // Enlace para navegar a la página de registro.
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
