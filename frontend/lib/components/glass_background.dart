import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base coral claro
        Container(
          color: const Color(0xFFFDE8E1),
        ),
        // Circulos difuminados al fondo
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFFDF9C88).withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -50,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              color: const Color(0xFFE5A898).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: 100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFDE9581).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Superposición masiva de Blur (Efecto difuminado general sobre el fondo)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: const SizedBox(),
          ),
        ),
        // Contenido superior encima del fondo (El Scaffold/Body con fondo transparente)
        SafeArea(child: child),
      ],
    );
  }
}
