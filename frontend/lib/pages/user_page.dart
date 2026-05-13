import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:frontend/ui/feedback/radio_patio_snackbar.dart';

import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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

        if (!mounted) return;
        final provider = Provider.of<UserProvider>(context, listen: false);
        if (provider.user != null) {
          // Actualización de estado manual para forzar el repintado
          final userJson = provider.user!.toJson();
          userJson['rol'] = 'VECINO';
          userJson['token'] = provider.token; // Preservamos el token para no desloguear
          provider.setUser(userJson);
        }

        if (mounted) {
          Navigator.pop(context); // Cierra el diálogo
          RadioPatioSnackbar.success(
            context,
            "¡Bienvenido! Ahora eres parte de $nombreComunidad 🎉",
          );
          
          // Cargamos detalles de comunidad y vamos al Home.
          final communityProv =
              Provider.of<CommunityProvider>(context, listen: false);
          await communityProv.getCommunityDetails();
          if (mounted) context.go('/home');
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = errorData['error'] ?? "Error desconocido";

        if (mounted) {
          Navigator.pop(context);
          RadioPatioSnackbar.error(context, errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        RadioPatioSnackbar.error(context, "Error de conexión: $e");
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
          RadioPatioSnackbar.info(
            context,
            "Cuenta eliminada correctamente. Hasta pronto.",
          );

          context.go('/login');
        }
      } else {
        throw Exception("Error al borrar: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        RadioPatioSnackbar.error(context, "Error: $e");
      }
    }
  }

  // --- DIÁLOGOS ---
  void mostrarDialogoUnirse(String username) {
    final TextEditingController codigoController = TextEditingController();

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
              controller: codigoController,
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
              if (codigoController.text.isNotEmpty) {
                unirseComunidad(codigoController.text.trim(), username);
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No hay usuarios"));
              }

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
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              context.go('/login');
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
                            context.push('/comunidad/crear');
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
              const Divider(height: 30),
              // Contenedor bonito y visual para el código de invitación
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)], // Tonos cyan/teal claros y modernos
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  children: [
                    // Icono decorativo superior
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 45,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 10),
                    // Título llamativo
                    const Text(
                      "¡Únete a nuestra comunidad de vecinos!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Texto explicativo
                    const Text(
                      "Comparte este código para que otros vecinos puedan unirse a la app y estar al tanto de todo.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 25),
                    // Caja para mostrar y copiar el código
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // El código en sí
                          Text(
                            codigoInvitacionActual!,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Botón para copiar al portapapeles
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: codigoInvitacionActual!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Código copiado al portapapeles'),
                                  backgroundColor: Colors.teal,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.copy_rounded,
                                color: Colors.teal,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Botón para compartir usando share_plus
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Mensaje formateado para WhatsApp u otras apps
                          final String mensaje = "¡Hola vecino! 👋\n\nÚnete a nuestra comunidad en la app de vecinos.\n\nDescarga la app e introduce el código de invitación: *${codigoInvitacionActual!}* 🏢";
                          // ignore: deprecated_member_use
                          Share.share(mensaje);
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text(
                          "COMPARTIR CÓDIGO",
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.teal.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
          
          // --- SECCIÓN: GESTIÓN DE LA COMUNIDAD (Solo si es miembro) ---
          if (user.rol != 'USER') ...[
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
                    child: Text(
                      "Gestión de la Comunidad",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder_shared, color: Colors.orange),
                    ),
                    title: const Text("Documentos y Archivos", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Estatutos, actas, normativas...", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/documentos'),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people, color: Colors.blue),
                    ),
                    title: const Text("Directorio de Vecinos", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Lista de miembros de la comunidad", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/comunidad/miembros'),
                  ),
                  if (user.rol == 'PRESIDENTE' || user.rol == 'SUPER_ADMIN') ...[
                    const Divider(height: 1, indent: 60),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                      ),
                      title: const Text("Panel del Presidente", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text("Gestión de espacios y zonas comunes", style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/presidente'),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () => context.push('/perfil/editar'),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
