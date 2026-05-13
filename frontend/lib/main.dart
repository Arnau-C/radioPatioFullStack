import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/providers/super_admin_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Punto de entrada principal de la aplicación RadioPatio.
///
/// Configura el árbol de Providers (inyección de dependencias) y lanza
/// el widget raíz [MainApp].
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, CommunityProvider>(
          create: (context) => CommunityProvider(
            Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, communityProvider) =>
              communityProvider!..update(userProvider),
        ),
        ChangeNotifierProvider(create: (context) => SuperAdminProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

/// [MainApp]
///
/// Widget raíz de la aplicación. Configura:
/// - El tema visual global mediante [AppTheme.light] (Design System centralizado).
/// - El sistema de rutas declarativo mediante [AppRouter] (GoRouter).
/// - La localización en español para el calendario y widgets de Material.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // --- DESIGN SYSTEM: Tema global centralizado ---
      // Todos los colores, tipografía, formas y estilos de componentes
      // se heredan automáticamente de AppTheme.light.
      theme: AppTheme.light,

      // --- NAVEGACIÓN: GoRouter declarativo ---
      // Todas las rutas están centralizadas en AppRouter.
      // Incluye: auth flow, shell con 4 tabs, sub-rutas, y guards.
      routerConfig: AppRouter.router,

      // --- LOCALIZACIÓN: Español para el calendario y widgets de Material ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Idioma español
      ],
    );
  }
}
