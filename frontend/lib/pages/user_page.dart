import 'package:flutter/material.dart';
import 'package:frontend/pages/create_community_page.dart';
import 'package:http/http.dart' as http;
import 'edit_user.dart';
import 'login_page.dart';
import 'dart:convert';
class UserPage extends StatefulWidget {
  final Map<String, dynamic>
  userData; // Informacion del usuario despues del login

  const UserPage({
    super.key,
    required this.userData,
  });

  @override
  State<UserPage> createState() =>
      _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isAdmin = false;
  String? codigoInvitacionActual;
  String? nombreComunidadActual;

  @override
  void initState() {
    super.initState();
    if (widget.userData['rol'] == 'ADMIN') {
      isAdmin = true;
    }
    if (widget.userData['rol'] == 'PRESIDENTE') {
      obtenerCodigoComunidad();
    }
  }

  Future<void> obtenerCodigoComunidad() async {
    String username = widget.userData['username'];
    // Usamos 127.0.0.1 para Linux
    final url = Uri.parse('http://127.0.0.1:8080/api/comunidades/detalle/$username');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          codigoInvitacionActual = data['codigoInvitacion'];
          nombreComunidadActual = data['nombre'];
        });
      }
    } catch (e) {
      print("Error al obtener código: $e");
    }
  }
  // --- BORRADO Y REDIRECCIÓN ---
  Future<void> eliminarCuenta() async {
    String username = widget.userData['username'].toString().trim();
    // Si usas Android Emulator usa 'http://10.0.2.2:8080/...'
    final url = Uri.parse(
      'http://127.0.0.1:8080/api/auth/borrar/$username',
    );

    try {
      final response = await http
          .delete(url);

      if (response.statusCode == 200) {
        if (mounted) {
          // A) Feedback visual inmediato
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                "Cuenta eliminada correctamente. Hasta pronto.",
              ),
              backgroundColor:
                  Colors.grey,
              duration: Duration(
                seconds: 2,
              ),
            ),
          );

          // Esto mata todas las pantallas anteriores y pone el Login como la primera y única.
          // (route) => false significa: "Borra todo lo que haya antes".
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const LoginPage(),
            ),
            (Route<dynamic> route) =>
                false,
          );
        }
      } else {
        throw Exception(
          "Error al borrar: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> unirseComunidad(String codigo) async {

    final url = Uri.parse('http://127.0.0.1:8080/api/comunidades/unirse');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.userData['username'],
          'codigo': codigo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String nombreComunidad = data['comunidadNombre'];

        setState(() {
          widget.userData['rol'] = 'VECINO'; 
        });

        if (mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("¡Bienvenido! Ahora eres parte de $nombreComunidad 🎉"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = errorData['error'] ?? "Error desconocido"; // Leemos 'error' del Map

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
          SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  void mostrarDialogoUnirse() {
    final TextEditingController _codigoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unirse a una Comunidad"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Introduce el código de invitación que te ha dado tu presidente (Ej: RDO-8392)"),
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
                unirseComunidad(_codigoController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text("UNIRSE"),
          ),
        ],
      ),
    );
  }
  Future<List<dynamic>> fetchUsers() async {

    final url = Uri.parse('http://127.0.0.1:8080/api/superadmin/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }
  Future<void> borrarUsuarioComoAdmin(String usernameObjetivo) async {
    final url = Uri.parse('http://127.0.0.1:8080/api/superadmin/users/$usernameObjetivo');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuario $usernameObjetivo eliminado"), backgroundColor: Colors.grey));
            mostrarListaUsuarios();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void mostrarListaUsuarios() {
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
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No hay usuarios"));

              final users = snapshot.data!;
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final u = users[index];
                  final String username = u['username'];
                  final String rol = u['rol'] ?? 'USER';
                  final bool esMismoAdmin = username == widget.userData['username'];

                  return ListTile(
                    leading: CircleAvatar(
                        backgroundColor: (rol == 'ADMIN') ? Colors.indigo : Colors.teal,
                        child: Text(username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(rol),
                    trailing: esMismoAdmin ? null : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarBorradoAdmin(username),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [TextButton(child: const Text("Cerrar"), onPressed: () => Navigator.pop(context))],
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
                TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(ctx)),
                TextButton(
                    child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)), 
                    onPressed: () => borrarUsuarioComoAdmin(username)
                )
            ],
        )
      );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "Panel Admin" : "Mi Perfil", style: const TextStyle(color: Colors.black87)),
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
          )
        ],
      ),
      // IMPORTANTE: Aquí recuperamos la lógica para mostrar una pantalla u otra
      body: isAdmin ? _buildAdminView() : _buildUserView(),
    );
  }

  // --- VISTA ADMIN---
  Widget _buildAdminView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text("PANEL DE ADMINISTRADOR", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Sesión: ${widget.userData['username']}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 50),
            
            // Botón VER LISTA (Ahora funciona)
            ElevatedButton.icon(
              onPressed: () => mostrarListaUsuarios(),
              icon: const Icon(Icons.visibility),
              label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("GESTIONAR USUARIOS")),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildUserView() {
    final userData = widget.userData;
    // Leemos el rol dinámicamente
    String rolActual = userData['rol'] ?? 'USER';
    
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
          Text("Hola, ${userData['nombre'] ?? userData['username']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(userData['email'], style: const TextStyle(color: Colors.grey)),
          
          const SizedBox(height: 40),

          // --- SECCIÓN COMUNIDAD ---
          if (rolActual == 'USER') ...[
            // BLOQUE 1: SI ES USUARIO (NO TIENE COMUNIDAD)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,5))]
              ),
              child: Column(
                children: [
                  const Icon(Icons.home_work_outlined, size: 60, color: Colors.orange),
                  const SizedBox(height: 10),
                  const Text("No perteneces a ninguna comunidad", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                                   username: widget.userData['username'] 
                                 )
                               )
                             );
                             
                             // Verificamos si volvió un Mapa y si tuvo éxito
                             if (resultado != null && resultado is Map && resultado['exito'] == true) {
                               setState(() {
                                 widget.userData['rol'] = 'PRESIDENTE';
                                 codigoInvitacionActual = resultado['nuevoCodigo'];
                               });
                             }
                          }
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.qr_code, 
                          label: "Unirme con\nCódigo", 
                          color: Colors.orange,
                          onTap: () => mostrarDialogoUnirse(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ] else ...[
            // BLOQUE 2: SI YA ES MIEMBRO (VECINO O PRESIDENTE)
             Card(
               color: Colors.teal.shade50,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
               child: Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Column(
                   children: [
                     Icon(
                       rolActual == 'PRESIDENTE' ? Icons.security : Icons.apartment, 
                       size: 50, color: Colors.teal
                     ),
                     const SizedBox(height: 10),
                     const Text("Ya eres miembro de una comunidad", style: TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 5),
                     Text(rolActual, style: const TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold)),
                   ],
                 ),
               ),
             ),
                     // Mostrar el código si es Presidente
                     if (rolActual == 'PRESIDENTE' && codigoInvitacionActual != null) ...[
                        const Divider(height: 20),
                        Container(
                          // MARGEN HORIZONTAL: Esto es lo que lo hace "fino de los lados"
                          margin: const EdgeInsets.symmetric(horizontal: 40.0), 
                          
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white, // Fondo blanco para que resalte como una caja
                            borderRadius: BorderRadius.circular(15), // Borde fino verde
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                            ]
                          ),
                          child: Column(
                            children: [
                              const Text("CÓDIGO DE INVITACIÓN", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              
                              codigoInvitacionActual == null 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : SelectableText(
                                    codigoInvitacionActual!,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  ),
                              
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        const Text("Comparte este código con tus vecinos", style: TextStyle(fontSize: 11, color: Colors.teal)),
                     ]
                   ],
          
          const SizedBox(height: 30),
          
          // BOTÓN EDITAR
          ElevatedButton.icon(
            onPressed: () async {
               final resultado = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditUser(userData: widget.userData)));
               if (resultado != null) {
                 setState(() {
                   widget.userData['nombre'] = resultado['nombre'];
                   widget.userData['apellidos'] = resultado['apellidos'];
                   widget.userData['email'] = resultado['email'];
                 });
               }
            },
            icon: const Icon(Icons.edit),
            label: const Text("EDITAR MIS DATOS"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
          ),
          
          const SizedBox(height: 15),

          // BOTÓN ELIMINAR
          ElevatedButton.icon(
             onPressed: () {
               showDialog(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: const Text("¿Eliminar cuenta?"),
                   content: const Text("Perderás todos tus datos."),
                   actions: [
                     TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context)),
                     TextButton(child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)), onPressed: () { Navigator.pop(context); eliminarCuenta(); }),
                   ],
                 )
               );
             },
             icon: const Icon(Icons.delete_forever),
             label: const Text("ELIMINAR MI CUENTA"),
             style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold))
        ],
      ),
    ),
  );
}

  

  // --- VISTA USUARIO---
  

  Widget _crearFilaInfo(
    IconData icon,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.teal[300],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
