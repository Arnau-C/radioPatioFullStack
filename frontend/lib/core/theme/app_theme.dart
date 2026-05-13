import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// [AppTheme]
///
/// Define el ThemeData global de la aplicación RadioPatio.
///
/// Este archivo es el "cerebro visual" de la app: configura colores, tipografía,
/// formas, y estilos de componentes Material (AppBar, botones, inputs, etc.)
/// para que toda la interfaz sea coherente sin necesidad de estilos inline.
///
/// Se aplica en MaterialApp(theme: AppTheme.light) en main.dart.
class AppTheme {
  // --- Constructor privado para evitar instanciación ---
  AppTheme._();

  // =========================================================================
  // CONSTANTES DE DISEÑO — Radios de borde, elevaciones, duraciones
  // =========================================================================

  /// Radio de borde estándar para tarjetas y contenedores.
  static const double radiusMedium = 15.0;

  /// Radio de borde para tarjetas glass y elementos grandes.
  static const double radiusLarge = 30.0;

  /// Radio de borde para inputs y botones.
  static const double radiusSmall = 12.0;

  /// Duración estándar para animaciones de UI (hover, press, transiciones cortas).
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Duración para transiciones de página y animaciones más largas.
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Intensidad del blur para el efecto glassmorphism en tarjetas.
  static const double glassBlurSigma = 25.0;

  /// Intensidad del blur para el fondo general glass.
  static const double backgroundBlurSigma = 80.0;

  // =========================================================================
  // TEMA CLARO (Light Theme) — El tema principal y único por ahora
  // =========================================================================

  /// Tema claro completo para MaterialApp.
  static ThemeData get light {
    return ThemeData(
      // --- Configuración base ---
      useMaterial3: true,
      brightness: Brightness.light,

      // --- Esquema de colores (ColorScheme) ---
      // Este es el sistema de colores que Material 3 usa internamente.
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.textOnDark,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnDark,
        error: AppColors.error,
        onError: AppColors.textOnDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),

      // --- Colores de scaffold ---
      scaffoldBackgroundColor: AppColors.background,

      // --- Tipografía global ---
      textTheme: AppTypography.textTheme,

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.primaryDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        shape: const Border(
          bottom: BorderSide(color: Colors.black12, width: 1.0),
        ),
      ),

      // --- Tarjetas (Card) ---
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      // --- Botones elevados (ElevatedButton) ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textOnDark,
          elevation: 2,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // --- Botones de texto (TextButton) ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: AppTypography.textTheme.labelMedium,
        ),
      ),

      // --- Botón flotante (FAB) ---
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textOnDark,
        elevation: 6,
      ),

      // --- Campos de texto (InputDecoration) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.error, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: AppTypography.errorText,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textHint,
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // --- Diálogos ---
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.textTheme.titleLarge,
      ),

      // --- SnackBar ---
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textOnDark,
        ),
      ),

      // --- BottomNavigationBar (para la fase de navegación responsiva) ---
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),

      // --- NavigationRail (para la versión desktop) ---
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.primaryDark),
        unselectedIconTheme: IconThemeData(color: AppColors.textHint),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        indicatorColor: AppColors.primaryLight,
      ),

      // --- Chips ---
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLight,
        selectedColor: AppColors.primaryDark.withValues(alpha: 0.15),
        labelStyle: AppTypography.textTheme.labelMedium!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // --- Dividers ---
      dividerTheme: const DividerThemeData(
        color: AppColors.primaryLight,
        thickness: 0.5,
        space: 20,
      ),

      // --- Iconos ---
      iconTheme: const IconThemeData(
        color: AppColors.primaryDark,
        size: 24,
      ),
    );
  }
}
