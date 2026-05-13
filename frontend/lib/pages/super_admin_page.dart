import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/super_admin_provider.dart';
import 'package:frontend/utils/validators.dart';
import 'package:provider/provider.dart';

/// [SuperAdminPage]
///
/// Panel de control principal para el Super Administrador.
///
/// Esta página permite visualizar una lista de todos los usuarios del sistema
/// (excepto el propio Super Admin), y realizar acciones sobre ellos como
/// bloquear/desbloquear y eliminar. También permite crear nuevos usuarios
/// a través de un formulario en un diálogo.
///
/// Usa su propio `ChangeNotifierProvider` para crear y gestionar una instancia
/// de `SuperAdminProvider`, que encapsula toda la lógica de negocio de esta sección.
class SuperAdminPage extends StatelessWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Se crea un provider específico para esta pantalla.
    // Al entrar, se llama inmediatamente a `getUsers()` para cargar los datos.
    return ChangeNotifierProvider(
      create: (context) => SuperAdminProvider()..getUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Panel Super Admin"),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          actions: [
            // Botón para cerrar sesión.
            IconButton(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              tooltip: "Cerrar Sesión",
            ),
          ],
        ),
        backgroundColor: Colors.grey[200],
        body: Consumer<SuperAdminProvider>(
          builder: (context, provider, child) {
            // Muestra un indicador de carga mientras se obtienen los datos.
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Muestra un mensaje de error si la carga falla.
            if (provider.error != null) {
              return Center(child: Text("Error: ${provider.error}"));
            }

            // Construye la lista de usuarios.
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];

                // El Super Admin no debe poder gestionarse a sí mismo.
                if (user.rol == 'SUPER_ADMIN') {
                  return const SizedBox.shrink(); // No muestra nada.
                }

                // Tarjeta individual para cada usuario.
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  color:
                      user.cuentaBloqueada ? Colors.red.shade50 : Colors.white,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: user.cuentaBloqueada
                          ? Colors.red
                          : Colors.blueAccent,
                      child: Text(
                        user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Rol: ${user.rol}"),
                        Text(
                          "Intentos fallidos: ${user.intentosFallidos}",
                          style: TextStyle(
                            color: user.intentosFallidos > 0
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight: user.intentosFallidos > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para bloquear/desbloquear.
                        IconButton(
                          icon: Icon(
                            user.cuentaBloqueada
                                ? Icons.lock_open
                                : Icons.lock,
                            color: user.cuentaBloqueada
                                ? Colors.green
                                : Colors.orange,
                          ),
                          onPressed: () => provider.toggleBlockUser(
                              user.username, user.cuentaBloqueada),
                          tooltip:
                              user.cuentaBloqueada ? "Desbloquear" : "Bloquear",
                        ),
                        // Botón para eliminar.
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          onPressed: () =>
                              _showDeleteConfirmation(context, user.username),
                          tooltip: "Eliminar Usuario",
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        // Botón flotante para añadir un nuevo usuario.
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            heroTag: null,
            onPressed: () => _showCreateUserForm(context),
            backgroundColor: Colors.black87,
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar a un usuario.
  void _showDeleteConfirmation(BuildContext context, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: Text("Vas a eliminar a '$username' permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<SuperAdminProvider>(context, listen: false)
                  .deleteUser(username);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Muestra el formulario para crear un nuevo usuario en un diálogo.
  void _showCreateUserForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Crear Nuevo Usuario"),
        content: _CreateUserForm(
          // Callback que se ejecuta si el usuario se crea con éxito.
          onSuccess: () {
            Navigator.pop(ctx); // Cierra el diálogo de creación.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Usuario creado con éxito")),
            );
          },
        ),
      ),
    );
  }
}

/// [_CreateUserForm]
///
/// Un `StatefulWidget` que representa el formulario de creación de usuario.
///
/// Se encapsula en su propia clase para gestionar su estado interno de forma
/// independiente (controladores de texto, validación, rol seleccionado).
class _CreateUserForm extends StatefulWidget {
  final VoidCallback onSuccess; // Callback para notificar el éxito.
  const _CreateUserForm({required this.onSuccess});

  @override
  State<_CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<_CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  String _rolSeleccionado = 'USER';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: "Username"),
              validator: (v) => Validators.validateNotEmpty(v, 'Username'),
            ),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (v) => Validators.validateEmail(v),
            ),
            TextFormField(
              controller: _passCtrl,
              decoration: const InputDecoration(
                labelText: "Password",
                helperText: "Mín. 8 caracteres, Mayús, Min, Núm y Especial",
                helperMaxLines: 2,
              ),
              obscureText: true,
              validator: (v) => Validators.validatePassword(v),
            ),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextFormField(
              controller: _apellidosCtrl,
              decoration: const InputDecoration(labelText: "Apellidos"),
            ),
            const SizedBox(height: 10),
            // Dropdown para seleccionar el rol del nuevo usuario.
            DropdownButtonFormField<String>(
              initialValue: _rolSeleccionado,
              items: const [
                DropdownMenuItem(value: 'USER', child: Text("Usuario (USER)")),
                DropdownMenuItem(
                    value: 'PRESIDENTE', child: Text("Presidente")),
              ],
              onChanged: (val) => setState(() => _rolSeleccionado = val!),
              decoration: const InputDecoration(labelText: "Rol"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Si el formulario es válido, procede con la creación.
                    if (_formKey.currentState!.validate()) {
                      final provider = Provider.of<SuperAdminProvider>(context,
                          listen: false);
                      final user = AppUser(
                        username: _userCtrl.text,
                        email: _emailCtrl.text,
                        nombre: _nombreCtrl.text,
                        apellidos: _apellidosCtrl.text,
                        rol: _rolSeleccionado,
                      );
                      // Llama al provider y gestiona la respuesta.
                      provider
                          .createUser(user, _passCtrl.text)
                          .then((success) {
                        if (success) {
                          widget.onSuccess(); // Llama al callback de éxito.
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("❌ Error: ${provider.error}")),
                          );
                        }
                      });
                    }
                  },
                  child: const Text("Crear"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
