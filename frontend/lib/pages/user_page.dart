import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_user.dart';
import 'login_page.dart'; // <--- 1. IMPORTANTE: Añade esto para poder volver al login

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

  // --- LA JOYA DE LA CORONA: EL BORRADO Y REDIRECCIÓN ---
  Future<void> eliminarCuenta() async {
    String username = widget.userData['username'].toString().trim();

    // Recuerda: Si usas Android Emulator usa 'http://10.0.2.2:8080/...'
    final url = Uri.parse('http://localhost:8080/api/auth/borrar/$username');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (mounted) {
          // A) Feedback visual inmediato
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cuenta eliminada correctamente. Hasta pronto."),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );

          // B) LA MAGIA: "pushAndRemoveUntil"
          // Esto mata todas las pantallas anteriores y pone el Login como la primera y única.
          // (route) => false significa: "Borra todo lo que haya antes".
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Añadimos un botón de Salir (Logout) en la barra superior también, es buena práctica
        title: Text(isAdmin ? "Panel de Administrador" : "Bienvenido"),
        backgroundColor: isAdmin ? Colors.indigo : Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout manual (mismo efecto: volver al login borrando historial)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: isAdmin ? _buildAdminView() : _buildUserView(),
    );
  }

  // --- VISTA ADMIN (Igual que antes) ---
  Widget _buildAdminView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                backgroundColor: Colors.orange[800],
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

  // --- VISTA USUARIO (Igual que antes) ---
  Widget _buildUserView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUser(userData: widget.userData),
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

          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("¿Eliminar cuenta?"),
                    content: const Text(
                      "Esta acción no se puede deshacer. Perderás todos tus datos.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text(
                          "SÍ, ELIMINAR",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          eliminarCuenta(); // Llamada a la función mágica
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
              backgroundColor: Colors.redAccent,
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
