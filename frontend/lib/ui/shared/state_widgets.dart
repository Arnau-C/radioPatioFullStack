import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// [EmptyStateWidget]
///
/// Widget reutilizable para mostrar un estado vacío con icono, título y subtítulo.
///
/// Se usa cuando una lista no tiene datos (ej: "No hay avisos", "No hay reservas").
/// Reemplaza los estados vacíos inline dispersos por la app con un diseño unificado.
///
/// Ejemplo de uso:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.task_alt,
///   iconColor: Colors.green,
///   title: '¡Todo al día!',
///   subtitle: 'No hay avisos para hoy.',
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Icono grande que representa el estado vacío.
  final IconData icon;

  /// Color del icono. Por defecto: verde (positivo/todo bien).
  final Color iconColor;

  /// Título principal del estado vacío.
  final String title;

  /// Texto secundario explicativo.
  final String subtitle;

  /// Acción opcional (ej: botón "Crear nuevo").
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.success,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: iconColor),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: 15),
            action!,
          ],
        ],
      ),
    );
  }
}

/// [ErrorStateWidget]
///
/// Widget reutilizable para mostrar un estado de error con opción de reintentar.
///
/// Se usa cuando una petición falla (ej: "Error al cargar avisos").
/// Incluye un botón de "Reintentar" para que el usuario vuelva a intentarlo.
///
/// Ejemplo de uso:
/// ```dart
/// ErrorStateWidget(
///   message: 'Error al cargar avisos',
///   onRetry: () => setState(() {}),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  /// Mensaje de error a mostrar.
  final String message;

  /// Callback para reintentar la acción.
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 10),
          const Text(
            'Error al cargar datos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.error.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}
