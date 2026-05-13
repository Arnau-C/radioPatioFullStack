import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';
import 'package:frontend/ui/glass/glass_card.dart';
import 'package:frontend/ui/glass/glass_page_scaffold.dart';
import 'package:frontend/ui/inputs/radio_patio_text_field.dart';
import 'package:frontend/ui/buttons/radio_patio_button.dart';

import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/utils/validators.dart';

/// [LoginPage]
///
/// Pantalla de inicio de sesión para los usuarios de la aplicación.
///
/// Es un `StatefulWidget` para poder manejar el estado de los campos de texto
/// y la lógica de la autenticación (carga, éxito, error).
///
/// Utiliza los widgets del Design System:
/// - [GlassPageScaffold] para el fondo con imagen.
/// - [GlassCard] para la tarjeta de cristal del formulario.
/// - [RadioPatioTextField] para los campos de texto.
/// - [RadioPatioButton] para el botón de login.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// [_LoginPageState]
///
/// Gestiona la lógica y el estado de la [LoginPage].
class _LoginPageState extends State<LoginPage> {
  // Clave global para gestionar la validación del formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto de usuario y contraseña.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instancia del proveedor de autenticación para la lógica de login.
  late AuthProvider _authProvider;

  /// [initState]
  ///
  /// Se ejecuta al inicializar el estado del widget.
  /// Obtiene la referencia al AuthProvider sin suscribirse a cambios.
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
  ///
  /// 1. Valida el formulario localmente.
  /// 2. Llama al AuthProvider para autenticar.
  /// 3. Redirige al usuario según su rol (SUPER_ADMIN, USER, VECINO/PRESIDENTE).
  Future<void> _handleLogin() async {
    // Validar formulario local antes de enviar.
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
      // Guardamos los datos del usuario en el provider global.
      Provider.of<UserProvider>(context, listen: false).setUser(userData);

      // Redirigimos al usuario según su rol usando GoRouter.
      final String rol = userData['rol'];

      if (rol == 'SUPER_ADMIN') {
        // Super Admin tiene su propio panel, fuera del shell.
        context.go('/super-admin');
      } else if (rol == 'USER') {
        // Usuario nuevo sin comunidad → pantalla de onboarding.
        context.go('/onboarding');
      } else {
        // VECINO o PRESIDENTE → cargar datos de comunidad y entrar al Home.
        final communityProv =
            Provider.of<CommunityProvider>(context, listen: false);
        await communityProv.getCommunityDetails();
        if (mounted) context.go('/home');
      }
    }
  }

  /// [build]
  ///
  /// Construye la interfaz de usuario de la página de login
  /// usando los componentes del Design System.
  @override
  Widget build(BuildContext context) {
    return GlassPageScaffold(
      // Ancho máximo del contenido para pantallas grandes (Linux).
      maxWidth: 550,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          // --- Logo de la aplicación con Hero para animación entre pantallas ---
          Hero(
            tag: 'app_logo',
            child: Image.asset('lib/images/logo.png', width: 280, height: 280),
          ),
          const SizedBox(height: 20),

          // --- Tarjeta de cristal (glassmorphism) con el formulario ---
          GlassCard(
            padding: const EdgeInsets.all(35.0),
            child: Consumer<AuthProvider>(
              // Consumer se suscribe a AuthProvider para redibujarse
              // si hay cambios (ej: mostrar errores o un loader).
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Título del formulario.
                      Text('Iniciar Sesión', style: AppTypography.glassFormTitle),
                      const SizedBox(height: 20),

                      // Campo de usuario.
                      RadioPatioTextField(
                        controller: _usernameController,
                        hintText: 'Nombre de usuario',
                        obscureText: false,
                        prefixIcon: Icons.person_outline,
                        validator: (val) =>
                            Validators.validateNotEmpty(val, 'usuario'),
                      ),
                      const SizedBox(height: 12),

                      // Campo de contraseña.
                      RadioPatioTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (val) =>
                            Validators.validateNotEmpty(val, 'contraseña'),
                      ),
                      const SizedBox(height: 8),

                      // Enlace "¿Olvidaste tu contraseña?".
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Mensaje de error del servidor (si lo hay).
                      if (provider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            provider.errorMessage!,
                            style: AppTypography.errorText,
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Botón principal de login con animaciones de hover/press.
                      RadioPatioButton(
                        text: 'Iniciar Sesión',
                        isLoading: provider.isLoading,
                        onTap: provider.isLoading ? null : _handleLogin,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),

          // --- Enlace para navegar a la página de registro ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text('Regístrate ahora', style: AppTypography.linkText),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
