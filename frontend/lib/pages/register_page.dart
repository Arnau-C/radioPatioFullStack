import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';
import 'package:frontend/ui/glass/glass_card.dart';
import 'package:frontend/ui/glass/glass_page_scaffold.dart';
import 'package:frontend/ui/inputs/radio_patio_text_field.dart';
import 'package:frontend/ui/buttons/radio_patio_button.dart';
import 'package:frontend/ui/feedback/radio_patio_dialog.dart';
import 'package:frontend/ui/feedback/radio_patio_snackbar.dart';

import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/validators.dart';

/// [RegisterPage]
///
/// Pantalla de registro de un nuevo usuario en la aplicación.
///
/// Es un `StatefulWidget` porque necesita gestionar la información introducida
/// en los campos de texto, la barra de fuerza de contraseña (reactiva con
/// ValueNotifier), y el estado de la llamada a la API de registro.
///
/// Utiliza los widgets del Design System:
/// - [GlassPageScaffold] para el fondo con imagen.
/// - [GlassCard] para la tarjeta de cristal del formulario.
/// - [RadioPatioTextField] para los campos de texto.
/// - [RadioPatioButton] para el botón de registro.
/// - [RadioPatioDialog] para el diálogo de éxito.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// [_RegisterPageState]
///
/// Gestiona el estado y la lógica de la [RegisterPage].
class _RegisterPageState extends State<RegisterPage> {
  // Clave global para gestionar la validación del formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo de texto del formulario.
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Notificador reactivo para la contraseña (actualiza la barra de fuerza en tiempo real).
  final ValueNotifier<String> _passwordNotifier = ValueNotifier<String>('');

  // Instancia del proveedor de autenticación para la lógica de registro.
  late AuthProvider _authProvider;

  /// Se ejecuta al inicializar el estado del widget.
  /// Conecta el controlador de contraseña al notificador reactivo.
  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Cada vez que el usuario escriba en el campo de contraseña,
    // el ValueNotifier se actualiza y la barra de fuerza se redibuja.
    _passwordController.addListener(
      () => _passwordNotifier.value = _passwordController.text,
    );
  }

  /// Libera los recursos de cada controlador y el notificador.
  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordNotifier.dispose();
    super.dispose();
  }

  /// Calcula el nivel de fuerza de la contraseña.
  ///
  /// Retorna un mapa con:
  /// - 'color': Color de la barra (rojo, naranja, verde).
  /// - 'value': Progreso de la barra (0.0 a 1.0).
  /// - 'text': Label descriptivo ('Débil', 'Media', 'Fuerte').
  Map<String, dynamic> _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return {'color': Colors.transparent, 'value': 0.0, 'text': ''};
    }

    // Si cumple TODOS los requisitos del validador, es "Fuerte".
    if (Validators.validatePassword(password) == null) {
      return {
        'color': AppColors.passwordStrong,
        'value': 1.0,
        'text': 'Fuerte',
      };
    }

    // Cálculo incremental basado en requisitos parciales.
    double strength = 0.0;
    if (password.length >= 6) strength += 0.3;
    if (password.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;

    if (strength <= 0.4) {
      return {
        'color': AppColors.passwordWeak,
        'value': 0.3,
        'text': 'Débil',
      };
    } else {
      return {
        'color': AppColors.passwordMedium,
        'value': 0.6,
        'text': 'Media',
      };
    }
  }

  /// Gestiona el proceso de registro cuando el usuario pulsa el botón.
  ///
  /// 1. Valida el formulario localmente.
  /// 2. Llama al AuthProvider para registrar.
  /// 3. Si falla → Snackbar rojo con el mensaje de error.
  /// 4. Si funciona → diálogo de éxito y vuelta al Login.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userData = await _authProvider.register(
      nombre: _nombreController.text,
      apellidos: _apellidosController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (userData == null) {
      // El AuthProvider ya capturó la excepción y guardó el mensaje.
      final errorMsg =
          _authProvider.errorMessage ?? 'Error desconocido al registrar';
      _authProvider.clearMessages();
      RadioPatioSnackbar.error(context, errorMsg);
      return;
    }

    // Éxito — mostramos diálogo y volvemos al Login.
    await RadioPatioDialog.success(
      context,
      title: '¡Registro completado!',
      message: '¡Ya puedes iniciar sesión!',
    );

    if (mounted) {
      _authProvider.clearMessages();
      context.pop();
    }
  }

  /// Construye la interfaz de usuario de la página de registro
  /// usando los componentes del Design System.
  @override
  Widget build(BuildContext context) {
    return GlassPageScaffold(
      // Ancho máximo más amplio que el login por tener más campos.
      maxWidth: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // --- Logo con Hero para animación desde/hacia Login ---
          Hero(
            tag: 'app_logo',
            child: Image.asset('lib/images/logo.png', width: 150, height: 150),
          ),
          const SizedBox(height: 20),

          // --- Tarjeta de cristal con el formulario ---
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
            child: Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título del formulario.
                      Text('Crear Cuenta', style: AppTypography.glassFormTitle),
                      const SizedBox(height: 25),

                      // --- Campos de texto del formulario ---

                      // Campo: Nombre
                      RadioPatioTextField(
                        controller: _nombreController,
                        hintText: 'Nombre',
                        prefixIcon: Icons.person_outline,
                        validator: (val) =>
                            Validators.validateNotEmpty(val, 'nombre'),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Apellidos
                      RadioPatioTextField(
                        controller: _apellidosController,
                        hintText: 'Apellidos',
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) =>
                            Validators.validateNotEmpty(val, 'apellidos'),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Email
                      RadioPatioTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        validator: (val) => Validators.validateEmail(val),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Nombre de usuario
                      RadioPatioTextField(
                        controller: _usernameController,
                        hintText: 'Nombre de usuario',
                        prefixIcon: Icons.account_circle_outlined,
                        validator: (val) =>
                            Validators.validateNotEmpty(val, 'usuario'),
                      ),
                      const SizedBox(height: 12),

                      // --- Barra de fuerza de contraseña (reactiva) ---
                      // Usa ValueListenableBuilder para actualizarse en tiempo real
                      // cada vez que el usuario escribe, sin reconstruir todo el formulario.
                      _buildPasswordStrengthBar(),
                      const SizedBox(height: 6),

                      // Campo: Contraseña (con validación en tiempo real).
                      RadioPatioTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        obscureText: true,
                        validateOnChange: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (val) => Validators.validatePassword(val),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Confirmar contraseña.
                      RadioPatioTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmar Contraseña',
                        obscureText: true,
                        prefixIcon: Icons.lock_reset_outlined,
                        validator: (val) =>
                            Validators.validateConfirmPassword(
                          _passwordController.text,
                          val,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Botón principal de registro ---
                      RadioPatioButton(
                        text: 'Registrarse',
                        isLoading: provider.isLoading,
                        onTap: provider.isLoading ? null : _handleRegister,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),

          // --- Enlace para navegar de vuelta al Login ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes cuenta?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text('Inicia sesión', style: AppTypography.linkText),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Construye la barra animada de fuerza de contraseña.
  ///
  /// Usa [ValueListenableBuilder] para escuchar cambios en el texto de la
  /// contraseña y actualizar la barra visualmente sin reconstruir todo el form.
  Widget _buildPasswordStrengthBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ValueListenableBuilder<String>(
        valueListenable: _passwordNotifier,
        builder: (context, password, child) {
          final strengthData = _calculatePasswordStrength(password);
          final double value = strengthData['value'];
          final Color color = strengthData['color'];
          final String text = strengthData['text'];

          // No mostrar nada si la contraseña está vacía.
          if (password.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Barra de progreso dividida en 3 segmentos.
              Row(
                children: List.generate(3, (index) {
                  final isFilled = value > (index * 0.3);
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0),
                      height: 5,
                      decoration: BoxDecoration(
                        color: isFilled ? color : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              // Label animado con la fuerza actual.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  text,
                  key: ValueKey<String>(text),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: color,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
