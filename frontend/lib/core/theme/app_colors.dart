import 'package:flutter/material.dart';

/// [AppColors]
///
/// Clase centralizada que define TODA la paleta de colores de RadioPatio.
///
/// La idea es que ningún archivo de la app use colores hardcodeados (ej: Color(0xFF1A365D)).
/// En su lugar, siempre se referencia esta clase: AppColors.primaryDark.
///
/// Esto garantiza coherencia visual en toda la aplicación y facilita
/// cambios globales de tema en el futuro (ej: modo oscuro).
class AppColors {
  // --- Constructor privado para evitar instanciación ---
  AppColors._();

  // =========================================================================
  // COLORES PRIMARIOS — Azul marino profundo (identidad principal de la app)
  // =========================================================================

  /// Azul marino profundo — color principal para AppBars, botones, textos destacados.
  static const Color primaryDark = Color(0xFF1A365D);

  /// Variante más clara del primario — para fondos sutiles, bordes, chips.
  static const Color primaryLight = Color(0xFFE2E8F0);

  /// Azul intermedio — usado en gradientes de botones y elementos interactivos.
  static const Color primaryMedium = Color(0xFF00335A);

  /// Azul del texto del Login — ligeramente más oscuro que primaryDark.
  static const Color primaryText = Color(0xFF001E35);

  // =========================================================================
  // COLORES DE ACENTO — Naranja/Teja (contraste cálido contra el azul)
  // =========================================================================

  /// Naranja teja — color de acento para badges, iconos destacados, CTAs secundarios.
  static const Color accent = Color(0xFFE27D60);

  // =========================================================================
  // COLORES SEMÁNTICOS — Feedback visual (éxito, error, advertencia, info)
  // =========================================================================

  /// Verde — confirmaciones, acciones exitosas, estados "resuelto".
  static const Color success = Color(0xFF38A169);

  /// Rojo — errores, acciones destructivas, alertas críticas.
  static const Color error = Color(0xFFE53E3E);

  /// Naranja/Ámbar — advertencias, estados pendientes.
  static const Color warning = Color(0xFFDD6B20);

  /// Azul claro — información neutra, tips, estados informativos.
  static const Color info = Color(0xFF3182CE);

  // =========================================================================
  // COLORES DE SUPERFICIE — Fondos, tarjetas, scaffolds
  // =========================================================================

  /// Fondo principal de la app (gris muy claro, casi blanco).
  static const Color background = Color(0xFFF8F9FA);

  /// Fondo de tarjetas y contenedores elevados.
  static const Color surface = Colors.white;

  /// Color del Drawer header, AppBars oscuras.
  static const Color surfaceDark = Color(0xFF1A365D);

  // =========================================================================
  // COLORES DE TEXTO — Jerarquía tipográfica
  // =========================================================================

  /// Texto principal (títulos, labels importantes) — negro suave.
  static const Color textPrimary = Color(0xFF1A202C);

  /// Texto secundario (subtítulos, descripciones) — gris medio.
  static const Color textSecondary = Color(0xFF718096);

  /// Texto deshabilitado o de baja prioridad — gris claro.
  static const Color textHint = Color(0xFFA0AEC0);

  /// Texto sobre fondos oscuros (AppBars, botones primarios).
  static const Color textOnDark = Colors.white;

  // =========================================================================
  // COLORES DE GLASSMORPHISM — Específicos para el efecto glass
  // =========================================================================

  /// Fondo del glass card (blanco semitransparente, parte superior del gradiente).
  static const Color glassWhiteHigh = Color(0x40FFFFFF); // 25% opacidad

  /// Fondo del glass card (blanco semitransparente, parte inferior del gradiente).
  static const Color glassWhiteLow = Color(0x0DFFFFFF); // 5% opacidad

  /// Borde sutil del glass card.
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% opacidad

  /// Sombra suave del glass card.
  static const Color glassShadow = Color(0x1A000000); // 10% opacidad

  /// Relleno de los text fields sobre glass.
  static const Color glassInputFill = Color(0x26FFFFFF); // 15% opacidad

  /// Borde de text fields sobre glass en estado normal.
  static const Color glassInputBorder = Color(0x80FFFFFF); // 50% opacidad

  // =========================================================================
  // COLORES ESPECÍFICOS POR FEATURE
  // =========================================================================

  /// Teal — usado en secciones de comunidad, perfil de usuario, documentos.
  static const Color community = Color(0xFF319795);

  /// Deep Purple — usado en "Crear Comunidad".
  static const Color createCommunity = Color(0xFF6B46C1);

  /// Gris oscuro — AppBar del panel de SuperAdmin (estilo corporativo diferenciado).
  static const Color adminDark = Color(0xFF2D3748);

  // =========================================================================
  // COLORES DE BARRA DE FUERZA DE CONTRASEÑA
  // =========================================================================

  /// Contraseña débil.
  static const Color passwordWeak = Color(0xFFE53E3E);

  /// Contraseña media.
  static const Color passwordMedium = Color(0xFFDD6B20);

  /// Contraseña fuerte.
  static const Color passwordStrong = Color(0xFF38A169);
}
