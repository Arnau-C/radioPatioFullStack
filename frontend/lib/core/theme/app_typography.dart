import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// [AppTypography]
///
/// Define todos los estilos tipográficos de RadioPatio en un solo lugar.
///
/// Usa Google Fonts (Inter) como fuente principal, reemplazando la fuente
/// por defecto del sistema operativo. Inter es una fuente moderna, legible
/// y muy usada en interfaces premium tipo Apple/Google.
///
/// Cada estilo tiene un nombre semántico (headlineLarge, bodyMedium, etc.)
/// para que el desarrollador elija el adecuado sin adivinar tamaños.
class AppTypography {
  // --- Constructor privado para evitar instanciación ---
  AppTypography._();

  // =========================================================================
  // FUENTE BASE — Inter de Google Fonts
  // =========================================================================

  /// Genera un TextTheme completo basado en la fuente Inter.
  /// Se usa directamente en ThemeData para que toda la app herede esta fuente.
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        // --- TITULARES (Display) — Muy grandes, para pantallas de bienvenida ---
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),

        // --- TITULARES (Headline) — Títulos de sección importantes ---
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),

        // --- TÍTULOS (Title) — AppBars, headers de tarjetas ---
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),

        // --- CUERPO (Body) — Textos de contenido, descripciones ---
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          height: 1.4,
        ),

        // --- LABELS — Botones, chips, badges, campos de formulario ---
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnDark,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // =========================================================================
  // ESTILOS ESPECÍFICOS — Para contextos que no encajan en el TextTheme
  // =========================================================================

  /// Título del formulario de Login/Register sobre fondo glass.
  static TextStyle get glassFormTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  /// Texto de los botones principales (sobre fondo oscuro).
  static TextStyle get buttonPrimary => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnDark,
        letterSpacing: 0.5,
      );

  /// Texto del enlace "Regístrate ahora" / "Inicia sesión".
  static TextStyle get linkText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  /// Texto del hint en los campos de texto sobre glass.
  static TextStyle get glassInputHint => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0x99000000), // Negro al 60%
      );

  /// Texto de entrada del usuario en los campos de texto.
  static TextStyle get glassInputText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );

  /// Texto de error en formularios.
  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.error,
      );

  /// Texto grande para el día en el navegador de fechas ("Hoy", "12 may").
  static TextStyle get dateNavigatorDay => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      );

  /// Texto pequeño para la fecha del navegador ("Lunes, 12 mayo").
  static TextStyle get dateNavigatorLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// Estilo para el código de invitación grande.
  static TextStyle get invitationCode => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        color: AppColors.textPrimary,
      );
}
