// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/pages/user_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// [RegisterPage]
///
/// Esta página representa la pantalla de registro de un nuevo usuario en la aplicación.
///
/// Es un `StatefulWidget` porque necesita gestionar la información introducida en los
/// campos de texto y el estado de la llamada a la API de registro (cargando, éxito, error).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// [_RegisterPageState]
///
/// Gestiona el estado y la lógica de la [RegisterPage].
class _RegisterPageState extends State<RegisterPage> {
  // Controladores para cada campo de texto del formulario.
  // Permiten acceder y gestionar el texto que el usuario introduce.
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Instancia del proveedor de autenticación para gestionar la lógica de registro.
  late AuthProvider _authProvider;

  /// [initState]
  ///
  /// Se ejecuta una vez cuando el widget se inserta en el árbol de widgets.
  /// Ideal para inicializaciones.
  @override
  void initState() {
    super.initState();
    // Obtenemos la instancia de AuthProvider usando Provider.
    // listen: false porque solo necesitamos la instancia para llamar a sus métodos,
    // no para redibujar este widget cuando el proveedor cambie.
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Añadimos listeners a los controladores.
    // Cuando el usuario escriba en cualquier campo, se llamará a `clearAllMessages`.
    // Esto hace que los mensajes de error o éxito desaparezcan en cuanto el usuario
    // empieza a corregir los datos, mejorando la experiencia de usuario.
    _nombreController.addListener(_authProvider.clearAllMessages);
    _apellidosController.addListener(_authProvider.clearAllMessages);
    _emailController.addListener(_authProvider.clearAllMessages);
    _usernameController.addListener(_authProvider.clearAllMessages);
    _passwordController.addListener(_authProvider.clearAllMessages);
    _confirmPasswordController.addListener(_authProvider.clearAllMessages);
  }

  /// [dispose]
  ///
  /// Se ejecuta cuando el widget se elimina permanentemente del árbol de widgets.
  /// Es fundamental para liberar recursos y evitar fugas de memoria.
  @override
  void dispose() {
    // Liberamos los recursos de cada controlador de texto.
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// [_handleRegister]
  ///
  /// Gestiona el proceso de registro cuando el usuario pulsa el botón.
  Future<void> _handleRegister() async {
    // Llama al método de registro del AuthProvider con los datos de los controladores.
    final userData = await _authProvider.register(
      nombre: _nombreController.text,
      apellidos: _apellidosController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    // Si el registro fue exitoso (userData no es nulo) y el widget sigue "montado"
    // (visible en pantalla), procedemos.
    if (userData != null && mounted) {
      // 1. Guardamos los datos del usuario recién registrado en UserProvider.
      //    Esto permite que otras partes de la app accedan a la información del usuario.
      Provider.of<UserProvider>(context, listen: false).setUser(userData);

      // 2. Mostramos un diálogo de éxito para confirmar al usuario que todo ha ido bien.
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.green.shade400,
          title: Center(
            child: Text(
              _authProvider.successMessage ?? "¡Registro completado!",
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      // 3. Navegamos a la página principal del usuario y eliminamos todas las
      //    rutas anteriores. Esto evita que el usuario pueda volver a la pantalla
      //    de registro o login usando el botón de "atrás".
      if (mounted) {
        _authProvider.clearAllMessages();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  /// [build]
  ///
  /// Construye la interfaz de usuario de la página de registro.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un Container con un degradado para el fondo de la pantalla.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDF9C88), Color(0xFFFDE8E1)],
          ),
        ),
        child: SafeArea(
          // Centramos el contenido y usamos SingleChildScrollView para
          // evitar problemas de overflow si el teclado aparece.
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              // Limitamos el ancho máximo del formulario en pantallas grandes.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Logo de la aplicación.
                    Image.asset('lib/images/logo.png', width: 150, height: 150),
                    const SizedBox(height: 20),

                    // Tarjeta principal que contiene el formulario.
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 25.0),
                        // Consumer<AuthProvider> se suscribe a los cambios de AuthProvider.
                        // Se redibujará solo esta parte del widget cuando AuthProvider notifique cambios.
                        // Es útil para mostrar mensajes de error o el estado de carga.
                        child: Consumer<AuthProvider>(
                          builder: (context, provider, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Título del formulario.
                                const Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    color: Color(0xFF001E35),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 25),

                                // Campos de texto personalizados para cada dato.
                                // El parámetro `errorMsg` se obtiene del AuthProvider.
                                MyTextField(
                                    controller: _nombreController,
                                    hintText: 'Nombre',
                                    obscureText: false,
                                    errorMsg: provider.nombreError),
                                const SizedBox(height: 12),
                                MyTextField(
                                    controller: _apellidosController,
                                    hintText: 'Apellidos',
                                    obscureText: false,
                                    errorMsg: provider.apellidosError),
                                const SizedBox(height: 12),
                                MyTextField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    obscureText: false,
                                    errorMsg: provider.emailError),
                                const SizedBox(height: 12),
                                MyTextField(
                                    controller: _usernameController,
                                    hintText: 'Nombre de usuario',
                                    obscureText: false,
                                    errorMsg: provider.usernameError),
                                const SizedBox(height: 12),
                                MyTextField(
                                    controller: _passwordController,
                                    hintText: 'Contraseña',
                                    obscureText: true,
                                    errorMsg: provider.passwordError),
                                const SizedBox(height: 12),
                                MyTextField(
                                    controller: _confirmPasswordController,
                                    hintText: 'Confirmar Contraseña',
                                    obscureText: true,
                                    errorMsg: provider.confirmPasswordError),
                                const SizedBox(height: 30),

                                // Botón de registro.
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    // Deshabilitamos el botón si está cargando.
                                    onPressed:
                                        provider.isLoading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF001E35),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    // Mostramos un indicador de carga o el texto del botón.
                                    child: provider.isLoading
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white))
                                        : const Text(
                                            'Registrarse',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Enlace para ir a la página de inicio de sesión.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿Ya tienes cuenta?',
                            style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
      ),
    );
  }
}
