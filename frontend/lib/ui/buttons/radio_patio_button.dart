import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// [RadioPatioButton]
///
/// Botón principal del Design System de RadioPatio con animaciones premium.
///
/// Evolución del antiguo `AnimatedButton`. Incluye:
/// - Efecto de hover (escala 1.03) para escritorio/Linux.
/// - Efecto de press (escala 0.95) para feedback táctil en móvil.
/// - Sombra dinámica que cambia con hover.
/// - Estado de carga con CircularProgressIndicator.
/// - Tres variantes: primary (azul), secondary (outline), danger (rojo).
///
/// Ejemplo de uso:
/// ```dart
/// RadioPatioButton(
///   text: 'Iniciar Sesión',
///   isLoading: provider.isLoading,
///   onTap: provider.isLoading ? null : _handleLogin,
/// )
/// ```
class RadioPatioButton extends StatefulWidget {
  /// Texto del botón.
  final String text;

  /// Callback al pulsar. Si es null, el botón se muestra deshabilitado.
  final VoidCallback? onTap;

  /// Si es true, muestra un spinner en lugar del texto.
  final bool isLoading;

  /// Variante visual del botón.
  final RadioPatioButtonVariant variant;

  /// Icono opcional a la izquierda del texto.
  final IconData? icon;

  const RadioPatioButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.variant = RadioPatioButtonVariant.primary,
    this.icon,
  });

  @override
  State<RadioPatioButton> createState() => _RadioPatioButtonState();
}

/// Variantes visuales del botón.
enum RadioPatioButtonVariant {
  /// Fondo oscuro con gradiente azul (acción principal).
  primary,

  /// Fondo transparente con borde (acción secundaria).
  secondary,

  /// Fondo rojo (acciones destructivas: eliminar cuenta, etc.).
  danger,
}

class _RadioPatioButtonState extends State<RadioPatioButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Controlador para la animación de escala al pulsar.
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
      reverseDuration: AppTheme.animationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onTap == null;
    final colors = _getVariantColors(isDisabled);

    return MouseRegion(
      // Hover para escritorio (Linux): escala sutil al pasar el ratón.
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isHovered && !isDisabled ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: colors.gradient,
                color: colors.gradient == null ? colors.backgroundColor : null,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: colors.border,
                boxShadow: [
                  BoxShadow(
                    color: isDisabled
                        ? Colors.transparent
                        : colors.shadowColor.withValues(
                            alpha: 0.3 + (_isHovered ? 0.2 : 0.0)),
                    blurRadius: _isHovered ? 12 : 8,
                    spreadRadius: _isHovered ? 2 : 0,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _buildContent(colors),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el contenido interior del botón (spinner, texto, o icono+texto).
  Widget _buildContent(_VariantColors colors) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
          strokeWidth: 2.5,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: colors.textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              color: colors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        color: colors.textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Devuelve los colores según la variante y el estado (disabled/enabled).
  _VariantColors _getVariantColors(bool isDisabled) {
    if (isDisabled) {
      return _VariantColors(
        gradient: LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade500],
        ),
        textColor: Colors.white,
        shadowColor: Colors.transparent,
      );
    }

    switch (widget.variant) {
      case RadioPatioButtonVariant.primary:
        return const _VariantColors(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primaryMedium],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          textColor: AppColors.textOnDark,
          shadowColor: AppColors.primaryDark,
        );

      case RadioPatioButtonVariant.secondary:
        return _VariantColors(
          backgroundColor: Colors.transparent,
          textColor: AppColors.primaryDark,
          shadowColor: Colors.transparent,
          border: Border.all(color: AppColors.primaryDark, width: 1.5),
        );

      case RadioPatioButtonVariant.danger:
        return _VariantColors(
          gradient: LinearGradient(
            colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
          ),
          textColor: AppColors.textOnDark,
          shadowColor: AppColors.error,
        );
    }
  }
}

/// Clase interna que agrupa los colores de una variante del botón.
class _VariantColors {
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final Color shadowColor;
  final Border? border;

  const _VariantColors({
    this.gradient,
    this.backgroundColor,
    required this.textColor,
    required this.shadowColor,
    this.border,
  });
}
