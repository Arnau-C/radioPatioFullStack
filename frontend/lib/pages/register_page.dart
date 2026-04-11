// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:frontend/components/textfield.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/validators.dart';
import 'package:provider/provider.dart';

/// [RegisterPage]
///
/// Esta página representa la pantalla de registro de un nuevo usuario en la aplicación.
///
/// Es un `StatefulWidget` porque necesita gestionar la información introducida en los
/// campos de texto y el estado de la llamada a la API de registro (cargando, éxito, error).
class RegisterPage
    extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

/// [_RegisterPageState]
///
/// Gestiona el estado y la lógica de la [RegisterPage].
class _RegisterPageState
    extends State<RegisterPage> {
  // Controladores para cada campo de texto del formulario.
  final _formKey = GlobalKey<FormState>();
  final _nombreController =
      TextEditingController();
  final _apellidosController =
      TextEditingController();
  final _emailController =
      TextEditingController();
  final _usernameController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  // Notificador reactivo para la contraseña
  final ValueNotifier<String> _passwordNotifier = ValueNotifier<String>('');

  // Instancia del proveedor de autenticación para gestionar la lógica de registro.
  late AuthProvider _authProvider;

  /// [initState]
  ///
  /// Se ejecuta una vez cuando el widget se inserta en el árbol de widgets.
  /// Ideal para inicializaciones.
  @override
  void initState() {
    super.initState();
    _authProvider =
        Provider.of<AuthProvider>(
          context,
          listen: false,
        );

    _passwordController.addListener(
      () => _passwordNotifier.value = _passwordController.text,
    );
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
    _passwordNotifier.dispose();
    super.dispose();
  }

  /// Calcula el nivel de fuerza de la contraseña y retorna el color y el progreso
  Map<String, dynamic> _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return {'color': Colors.transparent, 'value': 0.0, 'text': ''};
    }
    
    // Si cumple los mínimos requeridos (no devuelve error), es Fuerte por defecto.
    if (Validators.validatePassword(password) == null) {
      return {'color': Colors.green, 'value': 1.0, 'text': 'Fuerte'};
    }
    
    double strength = 0.0;
    
    if (password.length >= 6) strength += 0.3;
    if (password.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;

    if (strength <= 0.4) {
      return {'color': Colors.red, 'value': 0.3, 'text': 'Débil'};
    } else {
      return {'color': Colors.orange, 'value': 0.6, 'text': 'Media'};
    }
  }

  /// Gestiona el proceso de registro cuando el usuario pulsa el botón.
  Future<void> _handleRegister() async {
    // Autenticacion Reactiva Local
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Llama al método de registro del AuthProvider con los datos de los controladores.
    final userData = await _authProvider
        .register(
          nombre:
              _nombreController.text,
          apellidos:
              _apellidosController.text,
          email: _emailController.text,
          username:
              _usernameController.text,
          password:
              _passwordController.text,
        );

    // Si el registro fue exitoso (userData no es nulo) y el widget sigue "montado"
    // (visible en pantalla), procedemos.
    if (userData != null && mounted) {
      // 1. Mostramos un diálogo de éxito para confirmar al usuario que todo ha ido bien.
      // Se ha modificado para que no inicie sesión automáticamente, obligando al usuario
      // a iniciar sesión manualmente en la pantalla anterior.
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor:
              Colors.green.shade400,
          title: Center(
            child: Text(
              _authProvider
                      .successMessage ??
                  "¡Registro completado!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ),
        ),
      );

      // 2. Navegamos de vuelta a la página de inicio de sesión.
      // Utilizamos pop para volver a la ruta anterior de navegación.
      if (mounted) {
        _authProvider.clearMessages();
        Navigator.pop(context);
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
            colors: [
              Color(0xFFDF9C88),
              Color(0xFFFDE8E1),
            ],
          ),
        ),
        child: SafeArea(
          // Centramos el contenido y usamos SingleChildScrollView para
          // evitar problemas de overflow si el teclado aparece.
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 25.0,
                  ),
              // Limitamos el ancho máximo del formulario en pantallas grandes.
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                      maxWidth: 600,
                    ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),

                    // Logo de la aplicación.
                    Image.asset(
                      'lib/images/logo.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    // Tarjeta principal que contiene el formulario.
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal:
                                  30.0,
                              vertical:
                                  25.0,
                            ),
                        // Consumer<AuthProvider> se suscribe a los cambios de AuthProvider.
                        // Se redibujará solo esta parte del widget cuando AuthProvider notifique cambios.
                        // Es útil para mostrar mensajes de error o el estado de carga.
                        child: Consumer<AuthProvider>(
                          builder:
                              (
                                context,
                                provider,
                                child,
                              ) {
                                return Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                    // Título del formulario.
                                    const Text(
                                      'Crear Cuenta',
                                      style: TextStyle(
                                        color: Color(
                                          0xFF001E35,
                                        ),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),

                                    // Campos de texto personalizados para cada dato.
                                    // El parámetro `errorMsg` se obtiene del AuthProvider.
                                    MyTextField(
                                      controller: _nombreController,
                                      hintText: 'Nombre',
                                      obscureText: false,
                                      validator: (val) => Validators.validateNotEmpty(val, 'nombre'),
                                    ),
                                    const SizedBox(height: 12),
                                    MyTextField(
                                      controller: _apellidosController,
                                      hintText: 'Apellidos',
                                      obscureText: false,
                                      validator: (val) => Validators.validateNotEmpty(val, 'apellidos'),
                                    ),
                                    const SizedBox(height: 12),
                                    MyTextField(
                                      controller: _emailController,
                                      hintText: 'Email',
                                      obscureText: false,
                                      validator: (val) => Validators.validateEmail(val),
                                    ),
                                    const SizedBox(height: 12),
                                    MyTextField(
                                      controller: _usernameController,
                                      hintText: 'Nombre de usuario',
                                      obscureText: false,
                                      validator: (val) => Validators.validateNotEmpty(val, 'usuario'),
                                    ),
                                    const SizedBox(height: 12),

                                    // Widget reactivo para mostrar la fuerza de la contraseña
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                      child: ValueListenableBuilder<String>(
                                        valueListenable: _passwordNotifier,
                                        builder: (context, password, child) {
                                          final strengthData = _calculatePasswordStrength(password);
                                          final double value = strengthData['value'];
                                          final Color color = strengthData['color'];
                                          final String text = strengthData['text'];
                                          
                                          if (password.isEmpty) return const SizedBox.shrink();

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                height: 4,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                                child: FractionallySizedBox(
                                                  alignment: Alignment.centerLeft,
                                                  widthFactor: value,
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 300),
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                text,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: color,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    MyTextField(
                                      controller: _passwordController,
                                      hintText: 'Contraseña',
                                      obscureText: true,
                                      validateOnChange: true,
                                      validator: (val) => Validators.validatePassword(val),
                                    ),
                                    const SizedBox(height: 12),
                                    MyTextField(
                                      controller: _confirmPasswordController,
                                      hintText: 'Confirmar Contraseña',
                                      obscureText: true,
                                      validator: (val) => Validators.validateConfirmPassword(_passwordController.text, val),
                                    ),
                                    const SizedBox(height: 20),

                                    // Display de errores globales asíncronos devueltos por Spring Boot
                                    if (provider.errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 15),
                                        child: Text(
                                          provider.errorMessage!,
                                          style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                    // Botón de registro.
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        // Deshabilitamos el botón si está cargando.
                                        onPressed: provider.isLoading
                                            ? null
                                            : _handleRegister,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF001E35,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          elevation: 5,
                                        ),
                                        // Mostramos un indicador de carga o el texto del botón.
                                        child: provider.isLoading
                                            ? const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Colors.white,
                                                    ),
                                              )
                                            : const Text(
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
                                );
                              },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),

                    // Enlace para ir a la página de inicio de sesión.
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta?',
                          style: TextStyle(
                            color: Colors
                                .grey[700],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pop(
                                context,
                              ),
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: Color(
                                0xFF001E35,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
