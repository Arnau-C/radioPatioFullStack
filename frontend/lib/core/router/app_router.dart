import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/responsive/responsive_scaffold.dart';

// --- Pantallas de autenticación ---
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/register_page.dart';

// --- Pantallas principales (tabs del shell) ---
import 'package:frontend/pages/home_screen.dart';
import 'package:frontend/pages/user_page.dart';

// --- Pantallas de funcionalidades específicas ---
import 'package:frontend/pages/super_admin_page.dart';
import 'package:frontend/pages/reserva_espacios_screen.dart';
import 'package:frontend/pages/lista_reservas_screen.dart';
import 'package:frontend/pages/tablon_incidencias_screen.dart';
import 'package:frontend/pages/create_incidence.dart';



import 'package:frontend/pages/documentos_screen.dart';
import 'package:frontend/pages/president_panel_screen.dart';
import 'package:frontend/pages/miembros_comunidad_screen.dart';
import 'package:frontend/pages/edit_user.dart';
import 'package:frontend/pages/create_community_page.dart';
import 'package:frontend/pages/votaciones_screen.dart';
import 'package:frontend/pages/votacion_detalle_screen.dart';

// --- Providers para obtener datos de contexto ---
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/community_provider.dart';

// --- CUSTOM TRANSITION BUILDER ---
CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context, 
  required GoRouterState state, 
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// [AppRouter]
///
/// Configuración centralizada de todas las rutas de la aplicación RadioPatio.
///
/// Usa GoRouter para navegación declarativa con:
/// - Rutas de autenticación (sin shell de navegación).
/// - Shell con 4 tabs principales (Home, Reservas, Incidencias, Perfil).
/// - Sub-rutas que se abren encima del shell (crear incidencia, documentos, etc.).
/// - Guards de navegación basados en el estado de autenticación.
///
/// Las llaves de navegación (_rootNavigatorKey, _shellNavigatorKey) aseguran
/// que las sub-rutas se abren a pantalla completa (por encima de las tabs)
/// en lugar de dentro de una tab específica.
class AppRouter {
  // --- Constructor privado ---
  AppRouter._();

  // =========================================================================
  // CLAVES DE NAVEGACIÓN
  // =========================================================================

  /// Clave del navigator raíz (para rutas que se abren A PANTALLA COMPLETA,
  /// cubriendo las tabs de navegación).
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Claves para los navigators de cada rama/tab del shell.
  /// Esto permite que cada tab tenga su propia pila de navegación independiente.
  static final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'home');
  static final GlobalKey<NavigatorState> _reservasNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'reservas');
  static final GlobalKey<NavigatorState> _incidenciasNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'incidencias');
  static final GlobalKey<NavigatorState> _votacionesNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'votaciones');
  static final GlobalKey<NavigatorState> _perfilNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'perfil');

  // =========================================================================
  // CONFIGURACIÓN DEL ROUTER
  // =========================================================================

  /// Instancia singleton del router para toda la aplicación.
  /// Se expone como getter para usarlo en MaterialApp.router(routerConfig: ...).
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true, // Logs de navegación en consola (útil para debug).

    routes: [
      // =====================================================================
      // RUTAS DE AUTENTICACIÓN — Sin shell de navegación
      // =====================================================================

      /// Pantalla de Login — Ruta inicial de la app.
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      /// Pantalla de Registro — Accesible desde el Login.
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // =====================================================================
      // RUTA SUPER ADMIN — Layout propio, sin shell
      // =====================================================================

      /// Panel de Super Administrador.
      /// Excluido del shell porque tiene un diseño y flujo completamente diferente.
      GoRoute(
        path: '/super-admin',
        builder: (context, state) => const SuperAdminPage(),
      ),

      // =====================================================================
      // RUTA DE ONBOARDING — Usuario sin comunidad
      // =====================================================================

      /// Página de perfil/onboarding para usuarios que aún no tienen comunidad.
      /// Se muestra fuera del shell porque el usuario necesita crear/unirse
      /// a una comunidad antes de acceder a las funcionalidades principales.
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const UserPage(),
      ),

      // =====================================================================
      // SUB-RUTAS A PANTALLA COMPLETA — Se abren SOBRE las tabs
      // =====================================================================

      /// Pantalla de reservar un espacio.
      /// Se abre a pantalla completa porque es un flujo con múltiples pasos.
      GoRoute(
        path: '/reservas/nueva',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // Obtenemos el comunidadId del provider de comunidad.
          final communityProv =
              Provider.of<CommunityProvider>(context, listen: false);
          return ReservaEspaciosScreen(
            comunidadId: communityProv.communityId ?? 0,
          );
        },
      ),

      /// Pantalla de crear una nueva incidencia/avería.
      GoRoute(
        path: '/incidencias/nueva',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final communityProv =
              Provider.of<CommunityProvider>(context, listen: false);
          return CrearIncidenciaPage(
            comunidadId: communityProv.communityId ?? 0,
          );
        },
      ),

      /// Pantalla de documentos/PDFs de la comunidad.
      GoRoute(
        path: '/documentos',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const DocumentosScreen(),
        ),
      ),

      /// Panel del Presidente — Gestión de espacios comunitarios.
      GoRoute(
        path: '/presidente',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const PresidentPanelScreen(),
        ),
      ),

      /// Pantalla de miembros de la comunidad.
      GoRoute(
        path: '/comunidad/miembros',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final communityProv =
              Provider.of<CommunityProvider>(context, listen: false);
          final userProv =
              Provider.of<UserProvider>(context, listen: false);
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: MiembrosComunidadScreen(
              comunidadId: communityProv.communityId ?? 0,
              tokenJwt: userProv.token ?? '',
              isPresidente: userProv.user?.rol == 'PRESIDENTE',
            ),
          );
        },
      ),

      /// Pantalla de crear comunidad.
      GoRoute(
        path: '/comunidad/crear',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userProv =
              Provider.of<UserProvider>(context, listen: false);
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: CreateCommunityPage(
              username: userProv.user?.username ?? '',
            ),
          );
        },
      ),

      /// Pantalla de editar perfil del usuario.
      GoRoute(
        path: '/perfil/editar',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const EditUser(),
        ),
      ),

      /// Detalle de una votación (pantalla completa con polling).
      GoRoute(
        path: '/votaciones/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final votacionId = int.parse(state.pathParameters['id']!);
          final userProv = Provider.of<UserProvider>(context, listen: false);
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: VotacionDetalleScreen(
              votacionId: votacionId,
              token: userProv.token ?? '',
              isPresidente: userProv.user?.rol == 'PRESIDENTE',
            ),
          );
        },
      ),

      // =====================================================================
      // SHELL PRINCIPAL — Las 4 tabs con navegación responsiva
      // =====================================================================

      /// Shell que envuelve las 4 secciones principales con BottomNavigationBar
      /// (móvil) o NavigationRail (escritorio).
      ///
      /// Cada rama (branch) tiene su propia pila de navegación, así que al
      /// cambiar de tab, el estado de la tab anterior se conserva.
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return ResponsiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // --- Tab 0: Inicio (Calendario + Avisos) ---
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // --- Tab 1: Reservas ---
          StatefulShellBranch(
            navigatorKey: _reservasNavigatorKey,
            routes: [
              GoRoute(
                path: '/reservas',
                builder: (context, state) {
                  // Wrapper que obtiene comunidadId del provider.
                  final communityProv =
                      Provider.of<CommunityProvider>(context, listen: false);
                  return ListaReservasScreen(
                    comunidadId: communityProv.communityId ?? 0,
                  );
                },
              ),
            ],
          ),

          // --- Tab 2: Incidencias ---
          StatefulShellBranch(
            navigatorKey: _incidenciasNavigatorKey,
            routes: [
              GoRoute(
                path: '/incidencias',
                builder: (context, state) {
                  // Wrapper que obtiene los parámetros de los providers.
                  final communityProv =
                      Provider.of<CommunityProvider>(context, listen: false);
                  final userProv =
                      Provider.of<UserProvider>(context, listen: false);
                  final String rol = userProv.user?.rol ?? 'USER';
                  return TablonIncidenciasScreen(
                    comunidadId: communityProv.communityId ?? 0,
                    tokenJwt: userProv.token ?? '',
                    isPresidenteOrAdmin:
                        rol == 'PRESIDENTE' || rol == 'SUPER_ADMIN',
                  );
                },
              ),
            ],
          ),

          // --- Tab 3: Votaciones ---
          StatefulShellBranch(
            navigatorKey: _votacionesNavigatorKey,
            routes: [
              GoRoute(
                path: '/votaciones',
                builder: (context, state) {
                  final communityProv =
                      Provider.of<CommunityProvider>(context, listen: false);
                  final userProv =
                      Provider.of<UserProvider>(context, listen: false);
                  return VotacionesScreen(
                    comunidadId: communityProv.communityId ?? 0,
                    token: userProv.token ?? '',
                    isPresidente: userProv.user?.rol == 'PRESIDENTE',
                  );
                },
              ),
            ],
          ),

          // --- Tab 4: Perfil ---
          StatefulShellBranch(
            navigatorKey: _perfilNavigatorKey,
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const UserPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
