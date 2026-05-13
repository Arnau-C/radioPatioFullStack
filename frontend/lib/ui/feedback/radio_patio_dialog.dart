import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// [RadioPatioDialog]
///
/// Clase helper para mostrar diálogos con estilo unificado en toda la app.
///
/// Reemplaza los 8+ usos dispersos de `showDialog` con estilos diferentes
/// por un API consistente y visualmente coherente.
///
/// Ejemplo de uso:
/// ```dart
/// // Diálogo de confirmación
/// final confirmar = await RadioPatioDialog.confirm(
///   context,
///   title: '¿Eliminar cuenta?',
///   message: 'Perderás todos tus datos.',
///   confirmText: 'ELIMINAR',
///   isDanger: true,
/// );
///
/// // Diálogo de éxito
/// await RadioPatioDialog.success(
///   context,
///   title: '¡Registro completado!',
///   message: 'Ya puedes iniciar sesión.',
/// );
/// ```
class RadioPatioDialog {
  // --- Constructor privado para evitar instanciación ---
  RadioPatioDialog._();

  /// Muestra un diálogo de confirmación con dos botones (Cancelar + Confirmar).
  /// Retorna `true` si el usuario confirma, `false` si cancela.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'CONFIRMAR',
    String cancelText = 'Cancelar',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              cancelText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDanger ? AppColors.error : AppColors.primaryDark,
              foregroundColor: AppColors.textOnDark,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Muestra un diálogo de éxito con un solo botón de cierre.
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String buttonText = 'ENTENDIDO',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: content ??
            (message != null
                ? Text(
                    message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  )
                : null),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.textOnDark,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo informativo genérico.
  static Future<void> info(
    BuildContext context, {
    required String title,
    required Widget content,
    String buttonText = 'CERRAR',
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
