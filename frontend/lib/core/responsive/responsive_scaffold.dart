import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// [ResponsiveScaffold]
///
/// Widget "shell" principal de RadioPatio que adapta la navegación al tamaño
/// de pantalla del dispositivo:
///
/// - **Móvil (< 600px)**: Muestra un [BottomNavigationBar] en la parte inferior
///   con las 4 secciones principales.
/// - **Escritorio (≥ 600px)**: Muestra un [NavigationRail] vertical a la
///   izquierda, dejando más espacio al contenido.
///
/// Funciona como el "contenedor" de la navegación principal de la app.
/// Recibe un [StatefulNavigationShell] de GoRouter que gestiona qué rama
/// (tab) está activa y conserva el estado de cada una.
///
/// Este widget NO añade su propio AppBar — cada pantalla hija gestiona
/// el suyo. Esto permite transicionar gradualmente las pantallas existentes.
class ResponsiveScaffold extends StatelessWidget {
  /// El shell de navegación de GoRouter que controla las ramas/tabs.
  final StatefulNavigationShell navigationShell;

  const ResponsiveScaffold({
    super.key,
    required this.navigationShell,
  });

  // =========================================================================
  // DEFINICIÓN DE LOS TABS — Los 4 destinos principales de la app
  // =========================================================================

  /// Lista de destinos de navegación compartida entre BottomNavigationBar
  /// y NavigationRail para mantener coherencia.
  static const List<_NavigationDestination> _destinations = [
    _NavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Inicio',
    ),
    _NavigationDestination(
      icon: Icons.event_available_outlined,
      selectedIcon: Icons.event_available,
      label: 'Reservas',
    ),
    _NavigationDestination(
      icon: Icons.warning_amber_outlined,
      selectedIcon: Icons.warning_amber,
      label: 'Incidencias',
    ),
    _NavigationDestination(
      icon: Icons.how_to_vote_outlined,
      selectedIcon: Icons.how_to_vote,
      label: 'Votaciones',
    ),
    _NavigationDestination(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Determinamos el ancho de la pantalla para elegir el modo de navegación.
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 600;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  // =========================================================================
  // LAYOUT MÓVIL — BottomNavigationBar en la parte inferior
  // =========================================================================

  /// Construye el layout para pantallas pequeñas (Android, etc.).
  /// Usa un Scaffold con BottomNavigationBar clásico.
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      // El body muestra la pantalla de la rama activa.
      body: navigationShell,

      // Barra de navegación inferior con los 4 destinos.
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(index),
        destinations: _destinations
            .map(
              (dest) => NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: dest.label,
              ),
            )
            .toList(),
      ),
    );
  }

  // =========================================================================
  // LAYOUT ESCRITORIO — NavigationRail a la izquierda
  // =========================================================================

  /// Construye el layout para pantallas grandes (Linux, etc.).
  /// Usa un Row con NavigationRail a la izquierda y el contenido a la derecha.
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Rail de navegación lateral con los 4 destinos.
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(index),
            // Mostramos los labels siempre para facilitar la navegación.
            labelType: NavigationRailLabelType.all,
            // Padding superior para dar aire visual.
            leading: const SizedBox(height: 20),
            destinations: _destinations
                .map(
                  (dest) => NavigationRailDestination(
                    icon: Icon(dest.icon),
                    selectedIcon: Icon(dest.selectedIcon),
                    label: Text(dest.label),
                  ),
                )
                .toList(),
          ),
          // Separador visual entre el rail y el contenido.
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal expandido al máximo.
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  // =========================================================================
  // NAVEGACIÓN — Cambio de rama/tab
  // =========================================================================

  /// Cambia a la rama del índice seleccionado.
  /// Usa `goBranch` de GoRouter para navegar entre las ramas del shell
  /// preservando el estado de cada una (ej: scroll, formularios).
  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Si el usuario toca el tab que ya está activo,
      // vuelve a la ruta inicial de esa rama (ej: scroll al top).
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Clase interna para definir los destinos de navegación de forma limpia.
/// Evita repetir la definición en BottomNavigationBar y NavigationRail.
class _NavigationDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
