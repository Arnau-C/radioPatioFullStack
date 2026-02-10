import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:http/http.dart' as http;

class SuperAdminPage
    extends StatefulWidget {
  const SuperAdminPage({super.key});

  @override
  State<SuperAdminPage> createState() =>
      _SuperAdminPageState();
}

class _SuperAdminPageState
    extends State<SuperAdminPage> {
  final storage =
      const FlutterSecureStorage();
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerUsuarios();
  }

  // --- 1. OBTENER USUARIOS ---
  // --- 1. OBTENER USUARIOS ---
  Future<void> obtenerUsuarios() async {
    setState(() => isLoading = true); // Reiniciamos el estado de carga al refrescar

    try {
      String? token = await storage.read(key: 'jwt_token');

      // TIP: Si usas emulador de Android, cambia 127.0.0.1 por 10.0.2.2
      final url = Uri.parse('http://127.0.0.1:8080/api/superadmin/users');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
        });
      } else {
        mostrarMensaje("Error al cargar usuarios: ${response.statusCode}");
      }
    } catch (e) {
      print("Error detallado: $e");
      mostrarMensaje("Error de conexión con el servidor");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> crearUsuario(String user, String email, String pass, String nom, String ape, String rol) async {
    String? token = await storage.read(key: 'jwt_token');
    final url = Uri.parse('http://127.0.0.1:8080/api/superadmin/users/create');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "username": user,
          "email": email,
          "password": pass,
          "nombre": nom,
          "apellidos": ape,
          "rol": rol
        }),
      );

      if (response.statusCode == 200) {
        mostrarMensaje("✅ Usuario creado con éxito");
        obtenerUsuarios(); // Recargamos la lista para ver al nuevo usuario
      } else {
        mostrarMensaje("❌ Error: ${response.body}");
      }
    } catch (e) {
      mostrarMensaje("❌ Error de conexión");
    }
  }
  // --- 2. BLOQUEAR / DESBLOQUEAR ---
  Future<void> alternarBloqueo(
    String username,
    bool estaBloqueadoActualmente,
  ) async {
    String? token = await storage.read(
      key: 'jwt_token',
    );
    final url = Uri.parse(
      'http://127.0.0.1:8080/api/superadmin/users/$username',
    );

    // LÓGICA: Invertimos el estado actual.
    // Si era true (bloqueado) -> enviamos false (desbloquear).
    // El backend se encarga de poner intentos a 0.
    final nuevoEstado =
        !estaBloqueadoActualmente;

    final body = jsonEncode({
      'cuentaBloqueada': nuevoEstado,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization':
              'Bearer $token',
          'Content-Type':
              'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        mostrarMensaje(
          nuevoEstado
              ? "Usuario bloqueado"
              : "Usuario desbloqueado",
        );
        obtenerUsuarios(); // Recargamos la lista para ver el cambio de color
      } else {
        mostrarMensaje(
          "Error al actualizar estado",
        );
      }
    } catch (e) {
      mostrarMensaje(
        "Error de conexión",
      );
    }
  }

  // --- 3. ELIMINAR USUARIO ---
  Future<void> eliminarUsuario(
    String username,
  ) async {
    String? token = await storage.read(
      key: 'jwt_token',
    );
    final url = Uri.parse(
      'http://127.0.0.1:8080/api/superadmin/users/$username',
    );

    try {
      final response = await http
          .delete(
            url,
            headers: {
              'Authorization':
                  'Bearer $token',
            },
          );

      if (response.statusCode == 200) {
        mostrarMensaje(
          "Usuario eliminado correctamente",
        );
        obtenerUsuarios(); // Refrescamos la lista
      } else {
        mostrarMensaje(
          "No se pudo eliminar al usuario",
        );
      }
    } catch (e) {
      mostrarMensaje(
        "Error al conectar",
      );
    }
  }

  // --- LOGOUT ---
  void logout() async {
    await storage.delete(
      key: 'jwt_token',
    );
    if (mounted) {
      // Volvemos al Login y borramos el historial de navegación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginPage(),
        ),
        (route) => false,
      );
    }
  }

  // Función auxiliar para mostrar notificaciones
  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  void mostrarFormularioCreacion() {
    final _formKey = GlobalKey<FormState>();
    final userCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    String rolSeleccionado = 'USER';

    final RegExp regexPassword = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Crear Nuevo Usuario"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username"), validator: (v) => v!.isEmpty ? "Obligatorio" : null),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email"), validator: (v) => v!.isEmpty ? "Obligatorio" : null),
                TextFormField(
                controller: passCtrl, 
                decoration: const InputDecoration(
                  labelText: "Password",
                  helperText: "Mín. 8 caracteres, Mayús, Min, Núm y Especial",
                  helperMaxLines: 2,
                ), 
                obscureText: true, 
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "La contraseña es obligatoria";
                  }
                  if (!regexPassword.hasMatch(v)) {
                    return "Formato: Mín. 8 caracteres, 1 Mayúscula, 1 Minúscula, 1 Número y 1 Especial";
                  }
                  return null;
                },
              ),
                TextFormField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
                TextFormField(controller: apellidosCtrl, decoration: const InputDecoration(labelText: "Apellidos")),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  items: const [
                    DropdownMenuItem(value: 'USER', child: Text("Usuario (USER)")),
                    DropdownMenuItem(value: 'PRESIDENTE', child: Text("Presidente")),
                  ],
                  onChanged: (val) => rolSeleccionado = val!,
                  decoration: const InputDecoration(labelText: "Rol"),
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                crearUsuario(userCtrl.text, emailCtrl.text, passCtrl.text, nombreCtrl.text, apellidosCtrl.text, rolSeleccionado);
              }
            },
            child: const Text("Crear"),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Panel Super Admin",
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: "Cerrar Sesión",
          ),
        ],
      ),
      backgroundColor: Colors
          .grey[200], // Fondo gris claro para resaltar las tarjetas

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(
                    10,
                  ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user =
                    users[index];

                // Mapeo de datos del JSON
                final username =
                    user['username'];
                final role =
                    user['rol'];
                final isBlocked =
                    user['cuentaBloqueada'] ==
                    true;
                final intentos =
                    user['intentosFallidos'] ??
                    0;

                // PROTECCIÓN: No mostramos al propio SuperAdmin en la lista
                // para evitar bloquearnos o borrarnos por error.
                if (role ==
                    'SUPER_ADMIN')
                  return const SizedBox.shrink();

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                  // Si está bloqueado, fondo rojizo. Si no, blanco.
                  color: isBlocked
                      ? Colors
                            .red
                            .shade50
                      : Colors.white,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical: 8,
                        ),

                    // ICONO INICIAL (Izquierda)
                    leading: CircleAvatar(
                      backgroundColor:
                          isBlocked
                          ? Colors.red
                          : Colors
                                .blueAccent,
                      child: Text(
                        username
                            .toString()
                            .substring(
                              0,
                              1,
                            )
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors
                              .white,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),

                    // INFO CENTRAL
                    title: Text(
                      username,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Rol: $role",
                        ),
                        Text(
                          "Intentos fallidos: $intentos",
                          style: TextStyle(
                            // Resaltamos en rojo si tiene intentos > 0
                            color:
                                intentos >
                                    0
                                ? Colors
                                      .red
                                : Colors
                                      .grey[600],
                            fontWeight:
                                intentos >
                                    0
                                ? FontWeight
                                      .bold
                                : FontWeight
                                      .normal,
                          ),
                        ),
                      ],
                    ),

                    // BOTONES DE ACCIÓN (Derecha)
                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        // --- BOTÓN CANDADO ---
                        IconButton(
                          icon: Icon(
                            isBlocked
                                ? Icons
                                      .lock_open
                                : Icons
                                      .lock, // Icono cambia
                            color:
                                isBlocked
                                ? Colors
                                      .green
                                : Colors
                                      .orange, // Color cambia
                          ),
                          onPressed: () =>
                              alternarBloqueo(
                                username,
                                isBlocked,
                              ),
                          tooltip:
                              isBlocked
                              ? "Desbloquear"
                              : "Bloquear",
                        ),

                        // --- BOTÓN PAPELERA ---
                        IconButton(
                          icon: const Icon(
                            Icons
                                .delete,
                            color: Colors
                                .redAccent,
                          ),
                          onPressed: () {
                            // Diálogo de Confirmación
                            showDialog(
                              context:
                                  context,
                              builder: (ctx) => AlertDialog(
                                title: const Text(
                                  "¿Eliminar usuario?",
                                ),
                                content:
                                    Text(
                                      "Vas a eliminar a '$username' permanentemente.",
                                    ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      ctx,
                                    ),
                                    child: const Text(
                                      "Cancelar",
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        ctx,
                                      );
                                      eliminarUsuario(
                                        username,
                                      );
                                    },
                                    child: const Text(
                                      "Eliminar",
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip:
                              "Eliminar Usuario",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      
      // Botón flotante para recargar la lista manualmente
      floatingActionButton:
          FloatingActionButton(
            onPressed: mostrarFormularioCreacion,
            backgroundColor:
                Colors.black87,
            child: const Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
    );
  }
}
