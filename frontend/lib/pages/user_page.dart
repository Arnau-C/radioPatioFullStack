import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:frontend/pages/create_community_page.dart';
import 'package:frontend/pages/edit_user.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/utils/api_client.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? codigoInvitacionActual;
  String? nombreComunidadActual;
  int? comunidadIdActual;
  @override
  void initState() {
    super.initState();
    // Leemos el usuario del Provider de forma segura en initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null && (user.rol == 'PRESIDENTE' || user.rol == 'VECINO')) {
        obtenerCodigoComunidad(user.username);
      }
    });
  }

  // --- LÓGICA DE COMUNIDADES ---
  Future<void> obtenerCodigoComunidad(String username) async {
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/detalle/$username');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comunidadIdActual = data['id'];
          codigoInvitacionActual = data['codigoInvitacion'];
          nombreComunidadActual = data['nombre'];
        });
      }
    } catch (e) {
      debugPrint("Error al obtener código: $e");
    }
  }

  Future<void> unirseComunidad(String codigo, String username) async {
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/unirse');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String nombreComunidad = data['comunidadNombre'];

        // Actualizamos el rol localmente en el provider para que la UI cambie
        final provider = Provider.of<UserProvider>(context, listen: false);
        if (provider.user != null) {
          // Actualización de estado manual para forzar el repintado
          final userJson = provider.user!.toJson();
          userJson['rol'] = 'VECINO';
          provider.setUser(userJson);
          // Nota: Deberías idealmente tener un método en el provider para actualizar el rol
          // Como no veo un método setUser directo, simularemos el repintado
        }

        if (mounted) {
          Navigator.pop(context); // Cierra el diálogo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "¡Bienvenido! Ahora eres parte de $nombreComunidad 🎉",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Forzamos a recargar los datos del usuario para que se actualice el rol real
          obtenerCodigoComunidad(username);
          setState(() {});
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = errorData['error'] ?? "Error desconocido";

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de conexión: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LÓGICA DE BORRADO DE CUENTA ---
  Future<void> eliminarCuenta(String username) async {
    final url = Uri.parse('${ApiClient.baseUrl}/auth/borrar/$username');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cuenta eliminada correctamente. Hasta pronto."),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        throw Exception("Error al borrar: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DIÁLOGOS ---
  void mostrarDialogoUnirse(String username) {
    final TextEditingController _codigoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unirse a una Comunidad"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Introduce el código de invitación que te ha dado tu presidente (Ej: RDO-8392)",
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Código de Invitación",
                hintText: "XXX-XXXX",
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_codigoController.text.isNotEmpty) {
                unirseComunidad(_codigoController.text.trim(), username);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text("UNIRSE"),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE ADMIN (Manteniendo tu versión) ---
  Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('${ApiClient.baseUrl}/superadmin/users');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al cargar usuarios');
  }

  Future<void> borrarUsuarioComoAdmin(String usernameObjetivo) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/superadmin/users/$usernameObjetivo',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context); // Cierra diálogo
        Navigator.pop(context); // Cierra lista
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Usuario $usernameObjetivo eliminado"),
            backgroundColor: Colors.grey,
          ),
        );
        mostrarListaUsuarios(
          Provider.of<UserProvider>(context, listen: false).user!.username,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void mostrarListaUsuarios(String adminUsername) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Usuarios Registrados"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<List<dynamic>>(
            future: fetchUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(child: Text("Error: ${snapshot.error}"));
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text("No hay usuarios"));

              final users = snapshot.data!;
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final u = users[index];
                  final String username = u['username'];
                  final String rol = u['rol'] ?? 'USER';
                  final bool esMismoAdmin = username == adminUsername;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (rol == 'ADMIN' || rol == 'SUPER_ADMIN')
                          ? Colors.indigo
                          : Colors.teal,
                      child: Text(
                        username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(rol),
                    trailing: esMismoAdmin
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarBorradoAdmin(username),
                          ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _confirmarBorradoAdmin(String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("¿Borrar a $username?"),
        content: const Text("Esta acción es irreversible."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
            onPressed: () => borrarUsuarioComoAdmin(username),
          ),
        ],
      ),
    );
  }

  // --- BUILD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isAdmin = (user.rol == 'ADMIN' || user.rol == 'SUPER_ADMIN');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? "Panel Admin" : "Mi Perfil",
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isAdmin ? _buildAdminView(user) : _buildUserView(user),
    );
  }

  // --- VISTA ADMIN ---
  Widget _buildAdminView(user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.indigo,
            ),
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
              onPressed: () => mostrarListaUsuarios(user.username),
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

  // --- VISTA USUARIO ---
  Widget _buildUserView(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            "Hola, ${user.nombre ?? user.username}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email ?? 'Sin email',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // --- SECCIÓN COMUNIDAD (Dinámica según el rol real) ---
          if (user.rol == 'USER') ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No perteneces a ninguna comunidad",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.add_circle_outline,
                          label: "Crear\nComunidad",
                          color: Colors.deepPurple,
                          onTap: () async {
                            final resultado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateCommunityPage(
                                  username: user.username,
                                ),
                              ),
                            );
                            if (resultado != null &&
                                resultado is Map &&
                                resultado['exito'] == true) {
                              // Si creó con éxito, obtenemos el código nuevo y simulamos repintado
                              setState(() {
                                codigoInvitacionActual =
                                    resultado['nuevoCodigo'];
                              });
                              // Nota: Al volver, el usuario debería volver a hacer login para refrescar el rol en el backend localmente
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Por favor, vuelve a iniciar sesión para actualizar tus permisos",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.qr_code,
                          label: "Unirme con\nCódigo",
                          color: Colors.orange,
                          onTap: () => mostrarDialogoUnirse(user.username),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Card(
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      user.rol == 'PRESIDENTE'
                          ? Icons.security
                          : Icons.apartment,
                      size: 50,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Ya eres miembro de una comunidad",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.rol,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (user.rol == 'PRESIDENTE' && codigoInvitacionActual != null) ...[
              const Divider(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40.0),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "CÓDIGO DE INVITACIÓN",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      codigoInvitacionActual!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Comparte este código con tus vecinos",
                style: TextStyle(fontSize: 11, color: Colors.teal),
              ),
            ],
          ],

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditUser()),
            ),
            icon: const Icon(Icons.edit),
            label: const Text("EDITAR MIS DATOS"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("¿Eliminar cuenta?"),
                  content: const Text("Perderás todos tus datos."),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text(
                        "ELIMINAR",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        eliminarCuenta(user.username);
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text("ELIMINAR MI CUENTA"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR ---
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
