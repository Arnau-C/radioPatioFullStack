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
  Future<void> obtenerUsuarios() async {
    // Leemos el token del SuperAdmin
    String? token = await storage.read(
      key: 'jwt_token',
    );

    // URL del Backend
    final url = Uri.parse(
      'http://10.0.2.2:8080/api/superadmin/users',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer $token', // Fundamental para entrar al @PreAuthorize
          'Content-Type':
              'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          // Decodificamos la lista que viene de Java
          users = jsonDecode(
            response.body,
          );
          isLoading = false;
        });
      } else {
        mostrarMensaje(
          "Error al cargar usuarios: ${response.statusCode}",
        );
      }
    } catch (e) {
      mostrarMensaje(
        "Error de conexión con el servidor",
      );
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
      'http://10.0.2.2:8080/api/superadmin/users/$username',
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
      'http://10.0.2.2:8080/api/superadmin/users/$username',
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
            onPressed: obtenerUsuarios,
            backgroundColor:
                Colors.black87,
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
    );
  }
}
