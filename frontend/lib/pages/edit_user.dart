import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditUser extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUser({super.key, required this.userData});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  // Controladores de texto
  late TextEditingController _userController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _emailController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos actuales en las cajas
    _userController = TextEditingController(text: widget.userData['username']);
    _nombreController = TextEditingController(
      text: widget.userData['nombre'] ?? "",
    );
    _apellidosController = TextEditingController(
      text: widget.userData['apellidos'] ?? "",
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? "",
    );
  }

  Future<void> confirmarCambios() async {
    // Validar que no estén vacíos los importantes
    if (_emailController.text.isEmpty || _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y Email son obligatorios")),
      );
      return;
    }

    setState(() => _isSaving = true);

    String username = widget.userData['username'];

    // 1. CORRECCIÓN URL: Apuntamos al AuthController
    // (Recuerda: Si usas Android Emulator usa 'http://10.0.2.2:8080/...')
    final url = Uri.parse('http://localhost:8080/api/auth/modificar/$username');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // 2. CORRECCIÓN BODY: Solo enviamos lo que el DTO UpdateUserRequest espera
          "nombre": _nombreController.text,
          "apellidos": _apellidosController.text,
          "email": _emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          // Devolvemos los datos nuevos a la pantalla anterior
          final nuevosDatos = {
            ...widget.userData,
            "nombre": _nombreController.text,
            "apellidos": _apellidosController.text,
            "email": _emailController.text,
          };
          Navigator.pop(context, nuevosDatos);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuario modificado correctamente")),
          );
        }
      } else {
        throw Exception(
          "Error del servidor: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Usuario"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. USUARIO (ID) - BLOQUEADO
            _crearInput(
              _userController,
              "Usuario (ID)",
              Icons.lock,
              bloqueado: true,
            ),
            const SizedBox(height: 15),

            // 2. NOMBRE - EDITABLE
            _crearInput(_nombreController, "Nombre", Icons.person),
            const SizedBox(height: 15),

            // 3. APELLIDOS - EDITABLE
            _crearInput(_apellidosController, "Apellidos", Icons.badge),
            const SizedBox(height: 15),

            // 4. EMAIL - EDITABLE
            _crearInput(
              _emailController,
              "Email",
              Icons.email,
              tipo: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),

            // BOTÓN CONFIRMAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : confirmarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CONFIRMAR",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las cajas de texto
  Widget _crearInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool bloqueado = false,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: bloqueado,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: bloqueado ? Colors.grey : Colors.teal),
        filled: true,
        fillColor: bloqueado ? Colors.grey[200] : Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
