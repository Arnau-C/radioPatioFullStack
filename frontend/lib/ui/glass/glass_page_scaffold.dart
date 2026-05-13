import 'package:flutter/material.dart';

/// [GlassPageScaffold]
///
/// Scaffold completo con fondo de imagen y overlay para las pantallas
/// de autenticación (Login, Register) y cualquier pantalla que necesite
/// el estilo visual "glass page" de RadioPatio.
///
/// Proporciona:
/// - Una imagen de fondo a pantalla completa (por defecto: login_bg.png).
/// - Un área segura (SafeArea) para evitar notches y barras del sistema.
/// - Scroll automático para adaptarse al teclado virtual.
/// - Ancho máximo limitado para pantallas grandes (responsive).
///
/// Ejemplo de uso:
/// ```dart
/// GlassPageScaffold(
///   maxWidth: 550,
///   child: Column(children: [logo, GlassCard(...)]),
/// )
/// ```
class GlassPageScaffold extends StatelessWidget {
  /// El contenido que se renderiza dentro del scaffold.
  final Widget child;

  /// Ruta de la imagen de fondo. Por defecto: la imagen de mármol del login.
  final String backgroundImage;

  /// Ancho máximo del contenido (para que no se estire en escritorio).
  final double maxWidth;

  /// Padding horizontal del contenido.
  final double horizontalPadding;

  const GlassPageScaffold({
    super.key,
    required this.child,
    this.backgroundImage = 'assets/images/login_bg.png',
    this.maxWidth = 550,
    this.horizontalPadding = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo de imagen que ocupa toda la pantalla.
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // Padding lateral para que el contenido no toque los bordes.
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              // Limitamos el ancho del contenido en pantallas grandes (Linux).
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
