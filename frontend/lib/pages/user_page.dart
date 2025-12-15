import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_user.dart';

class UserPage extends StatefulWidget {
  final Map<String, dynamic>
  userData; // Informacion del usuario despues del login

  const UserPage({super.key, required this.userData});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    if (widget.userData['rol'] == 'ADMIN') {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
  }

  Future<void> eliminarCuenta() async {
    // En tu UserPage.dart dentro de eliminarCuenta()

    // Añade .trim() para evitar errores de espacios invisibles "pepe " vs "pepe"
    String username = widget.userData['username'].toString().trim();

    // Asegúrate que pone 'usuarios'
    final url = Uri.parse('http://localhost:8080/api/auth/borrar/$username');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Si se borró bien, sacamos al usuario a la pantalla de inicio (Login)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tu cuenta ha sido eliminada.")),
          );
          // Esto borra todo el historial de navegación y te manda al principio
          Navigator.of(context).popUntil((route) => route.isFirst);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "Panel de Administrador" : "Bienvenido"),
        backgroundColor: isAdmin ? Colors.indigo : Colors.teal,
      ),
      body: isAdmin ? _buildAdminView() : _buildUserView(),
    );
  }

  // --- VISTA 1: LO QUE VE EL ADMIN (Actualizada) ---
  Widget _buildAdminView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Estira los botones a lo ancho
          children: [
            // 1. Icono y Bienvenida
            const SizedBox(height: 20),
            const Text(
              "PANEL DE ADMINISTRADOR",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              "Sesión activa: ${widget.userData['username']}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                print("Lista de usuarios");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cargando lista para VER...")),
                );
              },
              icon: const Icon(Icons.visibility, size: 28),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("LISTA USUARIOS", style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                print("Modificar usuarios");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Abriendo los usuarios")),
                );
              },
              icon: const Icon(Icons.edit_document, size: 28),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "MODIFICAR USUARIOS",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.orange[800], // Naranja de acción/cuidado
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserView() {
    return SingleChildScrollView(
      // Permite hacer scroll si la pantalla es pequeña
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. FOTO Y CABECERA
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Mi Información Personal",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 20),

          // 2. TARJETA DE INFORMACIÓN (Sin contraseña)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  _crearFilaInfo(
                    Icons.account_circle,
                    "Usuario",
                    widget.userData['username'],
                  ),
                  const Divider(),
                  _crearFilaInfo(
                    Icons.badge,
                    "Nombre",
                    widget.userData['nombre'] ?? "Sin nombre",
                  ),
                  const Divider(),
                  _crearFilaInfo(
                    Icons.email,
                    "Email",
                    widget.userData['email'],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40), // Espacio para separar los botones
          // 3. BOTÓN A: MODIFICAR (Editar)
          ElevatedButton.icon(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUser(
                    userData: widget.userData,
                  ), // <--- Nombre actualizado
                ),
              );

              if (resultado != null) {
                setState(() {
                  widget.userData['nombre'] = resultado['nombre'];
                  widget.userData['apellidos'] = resultado['apellidos'];
                  widget.userData['email'] = resultado['email'];
                });
              }
            },
            icon: const Icon(Icons.edit),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "MODIFICAR MIS DATOS",
                style: TextStyle(fontSize: 16),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 4. BOTÓN B: ELIMINAR (Peligro)
          ElevatedButton.icon(
            // En el botón rojo de ELIMINAR:
            onPressed: () {
              // Mostramos un diálogo de alerta (Pop-up)
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("¿Eliminar cuenta?"),
                    content: const Text(
                      "Esta acción no se puede deshacer. Perderás todos tus datos.",
                    ),
                    actions: [
                      // Botón de Cancelar
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop(); // Cierra la alerta sin hacer nada
                        },
                      ),
                      // Botón de Confirmar (El peligroso)
                      TextButton(
                        child: const Text(
                          "SÍ, ELIMINAR",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra la alerta
                          eliminarCuenta(); // <--- LLAMA A LA FUNCIÓN QUE BORRA DE VERDAD
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete_forever),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("ELIMINAR MI CUENTA", style: TextStyle(fontSize: 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // Rojo para alertar
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pequeña ayuda para no repetir código en las filas de información
  Widget _crearFilaInfo(IconData icon, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal[300]),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
