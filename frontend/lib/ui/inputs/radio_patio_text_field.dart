import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// [RadioPatioTextField]
///
/// Campo de texto personalizado del Design System de RadioPatio.
///
/// Evolución del antiguo `MyTextField`. Soporta dos variantes visuales:
/// - **glass** (por defecto): Para formularios sobre fondos glassmorphism (Login, Register).
///   Usa relleno semitransparente y bordes blancos.
/// - **standard**: Para formularios dentro de la app (Crear Incidencia, Editar Usuario).
///   Usa los estilos del InputDecorationTheme global.
///
/// Incluye lógica de validación con autovalidación tras la primera interacción
/// del usuario (al perder el foco por primera vez).
///
/// Ejemplo de uso:
/// ```dart
/// RadioPatioTextField(
///   controller: _emailController,
///   hintText: 'Email',
///   prefixIcon: Icons.email_outlined,
///   validator: (val) => Validators.validateEmail(val),
/// )
/// ```
class RadioPatioTextField extends StatefulWidget {
  /// Controlador del campo de texto.
  final TextEditingController controller;

  /// Texto de placeholder cuando el campo está vacío.
  final String hintText;

  /// Si es true, oculta el texto (para contraseñas).
  final bool obscureText;

  /// Función de validación para el formulario.
  final String? Function(String?)? validator;

  /// Si es true, valida mientras el usuario escribe (no solo al perder foco).
  final bool validateOnChange;

  /// Icono que aparece a la izquierda del campo.
  final IconData? prefixIcon;

  /// Variante visual del campo: 'glass' para sobre fondos glass, 'standard' para la app.
  final RadioPatioTextFieldVariant variant;

  /// Texto de la etiqueta (para variant standard).
  final String? labelText;

  /// Tipo de teclado a mostrar.
  final TextInputType? keyboardType;

  /// Número máximo de líneas (para campos multiline).
  final int maxLines;

  /// Si el campo es de solo lectura.
  final bool readOnly;

  const RadioPatioTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.validateOnChange = false,
    this.prefixIcon,
    this.variant = RadioPatioTextFieldVariant.glass,
    this.labelText,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  State<RadioPatioTextField> createState() => _RadioPatioTextFieldState();
}

/// Variantes visuales del campo de texto.
enum RadioPatioTextFieldVariant {
  /// Estilo semitransparente para formularios sobre fondos glass.
  glass,

  /// Estilo estándar que usa el InputDecorationTheme global.
  standard,
}

class _RadioPatioTextFieldState extends State<RadioPatioTextField> {
  late FocusNode _focusNode;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Activamos la auto-validación después de la primera interacción (pierde foco).
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_hasInteracted) {
        setState(() {
          _hasInteracted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isGlass = widget.variant == RadioPatioTextFieldVariant.glass;

    return Padding(
      // El padding horizontal solo se aplica en la variante glass (como el diseño original).
      padding: EdgeInsets.symmetric(horizontal: isGlass ? 25.0 : 0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        validator: widget.validator,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        // La auto-validación se activa tras la primera interacción o si se fuerza.
        autovalidateMode: (widget.validateOnChange || _hasInteracted)
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        decoration: isGlass ? _buildGlassDecoration() : _buildStandardDecoration(),
        style: isGlass
            ? const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )
            : null, // En modo standard, hereda del tema global.
      ),
    );
  }

  /// Decoración para la variante glass (Login, Register).
  InputDecoration _buildGlassDecoration() {
    return InputDecoration(
      // Bordes con esquinas redondeadas y color semitransparente.
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.glassInputBorder,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      fillColor: AppColors.glassInputFill,
      filled: true,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: Colors.black87, size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      hintStyle: TextStyle(
        color: Colors.black87.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Decoración para la variante standard (dentro de la app).
  /// Usa los estilos globales del tema, añadiendo solo el icono y hint.
  InputDecoration _buildStandardDecoration() {
    return InputDecoration(
      labelText: widget.labelText ?? widget.hintText,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: AppColors.primaryDark)
          : null,
    );
  }
}
