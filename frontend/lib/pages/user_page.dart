import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/edit_user.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// [UserPage]
///
/// Muestra el perfil del usuario o un panel de administración dependiendo del rol.
///
/// Es un `StatelessWidget` que actúa como un "despachador": lee el usuario
/// del `UserProvider` y decide qué vista mostrar (`_AdminView` o `_UserView`).
/// También gestiona el caso en que no haya ningún usuario en sesión,
/// redirigiendo a la [LoginPage].
class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene el usuario actual desde el UserProvider.
    // `Provider.of` con `listen: true` (por defecto) hace que el widget se
    // reconstruya si el usuario cambia.
    final user = Provider.of<UserProvider>(context).user;

    // --- Lógica de Guarda de Ruta ---
    // Si no hay usuario en sesión, no se debe mostrar esta página.
    if (user == null) {
      // Usamos `WidgetsBinding.instance.addPostFrameCallback` para programar una
      // acción a ejecutar justo después de que el frame actual se haya construido.
      // Esto es para evitar errores al intentar navegar durante una fase de build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // Elimina todas las rutas anteriores.
        );
      });
      // Mientras se redirige, muestra un indicador de carga.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determina si el usuario tiene un rol de administrador.
    bool isAdmin = user.rol == 'ADMIN' || user.rol == 'SUPER_ADMIN';

    // Construcción de la página principal.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? "Panel Admin" : "Mi Perfil",
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent, // Fondo transparente.
        elevation: 0, // Sin sombra.
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Botón para cerrar sesión.
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              // Llama al método de logout del AuthProvider.
              Provider.of<AuthProvider>(context, listen: false).logout(
                Provider.of<UserProvider>(context, listen: false),
              );
              // Redirige al usuario a la página de login.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      // El cuerpo del Scaffold es la vista de admin o de usuario según el rol.
      body: isAdmin ? _AdminView(user: user) : _UserView(user: user),
    );
  }
}

/// [_AdminView]
///
/// Widget privado que muestra la vista para un usuario con rol de administrador.
class _AdminView extends StatelessWidget {
  final AppUser user;
  const _AdminView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.admin_panel_settings,
                size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              "PANEL DE ADMINISTRADOR",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Sesión: ${user.username}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: La lógica para gestionar usuarios irá aquí.
                // Actualmente pendiente de refactorización.
              },
              icon: const Icon(Icons.visibility),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("GESTIONAR USUARIOS"),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [_UserView]
///
/// Widget privado que muestra la vista para un usuario estándar.
class _UserView extends StatelessWidget {
  final AppUser user;
  const _UserView({required this.user});

  /// [_handleDeleteAccount]
  ///
  /// Gestiona la lógica para eliminar la cuenta de un usuario.
  Future<void> _handleDeleteAccount(BuildContext context) async {
    // Pide confirmación al usuario antes de proceder.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar cuenta?"),
        content: const Text(
            "Perderás todos tus datos. Esta acción es irreversible."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    // Si el usuario confirma y el widget sigue montado...
    if (confirmed == true && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteAccount();

      // Muestra un mensaje de éxito o error.
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cuenta eliminada correctamente. Hasta pronto."),
            backgroundColor: Colors.grey,
          ),
        );
        // NOTA: Aquí podría ser una buena idea redirigir al login.
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                userProvider.error ?? "Error al eliminar la cuenta."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar del usuario.
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 15),
          // Nombre y email del usuario.
          Text(
            "Hola, ${user.nombre ?? user.username}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email ?? 'Sin email',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          // Sección de la comunidad.
          _buildCommunitySection(context, user),
          const SizedBox(height: 30),
          // Botón para editar datos del usuario.
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditUser()),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text("EDITAR MIS DATOS"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 15),
          // Botón para eliminar la cuenta.
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => _handleDeleteAccount(context),
                icon: provider.isLoading
                    ? const SizedBox.shrink() // No muestra icono si está cargando
                    : const Icon(Icons.delete_forever),
                label: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("ELIMINAR MI CUENTA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// [_buildCommunitySection]
  ///
  /// Widget que construye la sección de la comunidad (actualmente un placeholder).
  Widget _buildCommunitySection(BuildContext context, AppUser user) {
    // A futuro, este widget podría ser más complejo y tener su propio
    // fichero para mayor claridad.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.home_work_outlined, size: 60, color: Colors.orange),
          SizedBox(height: 10),
          Text(
            "La sección de comunidad se refactorizará pronto",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
