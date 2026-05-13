import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// [GlassCard]
///
/// Widget reutilizable que implementa el efecto "glassmorphism" (cristal esmerilado)
/// usado como identidad visual de RadioPatio.
///
/// Combina un [BackdropFilter] con blur, un gradiente semitransparente blanco,
/// un borde sutil y una sombra suave para crear la apariencia de cristal.
///
/// Se usa como contenedor principal en formularios (Login, Register) y puede
/// usarse en cualquier parte de la app donde se quiera mantener la estética glass.
///
/// Ejemplo de uso:
/// ```dart
/// GlassCard(
///   padding: EdgeInsets.all(35),
///   child: Column(children: [...]),
/// )
/// ```
class GlassCard extends StatelessWidget {
  /// El contenido que se renderiza dentro de la tarjeta glass.
  final Widget child;

  /// Padding interno de la tarjeta. Por defecto: 30px horizontal, 25px vertical.
  final EdgeInsetsGeometry padding;

  /// Radio de las esquinas redondeadas. Por defecto: 30px (estilo Apple).
  final double borderRadius;

  /// Intensidad del blur del efecto glass. Por defecto: 25.0.
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
    this.borderRadius = AppTheme.radiusLarge,
    this.blurSigma = AppTheme.glassBlurSigma,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        // Efecto de desenfoque (blur) que se aplica a lo que hay DETRÁS del widget.
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Gradiente semitransparente blanco que simula el reflejo del cristal.
            gradient: const LinearGradient(
              colors: [
                AppColors.glassWhiteHigh, // Blanco 25% opacidad (parte superior)
                AppColors.glassWhiteLow,  // Blanco 5% opacidad (parte inferior)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            // Borde sutil que refuerza el efecto de cristal.
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            ),
            // Sombra suave para dar profundidad.
            boxShadow: const [
              BoxShadow(
                color: AppColors.glassShadow,
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
