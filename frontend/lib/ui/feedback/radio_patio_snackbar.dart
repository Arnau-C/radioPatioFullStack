import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// [RadioPatioSnackbar]
///
/// Clase helper para mostrar snackbars con estilo unificado en toda la app.
///
/// Reemplaza los 15+ usos dispersos de `ScaffoldMessenger.of(context).showSnackBar`
/// con estilos inconsistentes. Ahora hay un solo punto de entrada con 3 variantes:
/// success (verde), error (rojo), info (azul).
///
/// Ejemplo de uso:
/// ```dart
/// RadioPatioSnackbar.success(context, '¡Reserva confirmada!');
/// RadioPatioSnackbar.error(context, 'Error al crear aviso');
/// RadioPatioSnackbar.info(context, 'Cargando datos de comunidad...');
/// ```
class RadioPatioSnackbar {
  // --- Constructor privado para evitar instanciación ---
  RadioPatioSnackbar._();

  /// Muestra un snackbar de éxito (fondo verde).
  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle_outline);
  }

  /// Muestra un snackbar de error (fondo rojo).
  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error_outline);
  }

  /// Muestra un snackbar informativo (fondo azul).
  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.info, Icons.info_outline);
  }

  /// Muestra un snackbar de advertencia (fondo naranja).
  static void warning(BuildContext context, String message) {
    _show(context, message, AppColors.warning, Icons.warning_amber_rounded);
  }

  /// Método interno que construye y muestra el snackbar.
  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    // Limpiamos cualquier snackbar anterior para evitar acumulación.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.textOnDark, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
