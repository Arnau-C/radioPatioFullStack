import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/utils/validators.dart';
import 'package:provider/provider.dart';

/// [EditUser]
///
/// Página que permite al usuario editar su propia información personal, como
/// nombre, apellidos y email. El nombre de usuario no es editable.
///
/// Es un `StatefulWidget` para gestionar los controladores de los campos de texto
/// y el estado de la operación de actualización.
class EditUser extends StatefulWidget {
  const EditUser({super.key});

  @override
  State<EditUser> createState() => _EditUserState();
}

/// [_EditUserState]
///
/// Gestiona el estado y la lógica de la página [EditUser].
class _EditUserState extends State<EditUser> {
  // Controladores para los campos de texto.
  late final TextEditingController _userController;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _emailController;

  // Proveedor para acceder a los datos del usuario y actualizarlos.
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    // Obtenemos la instancia del UserProvider y los datos del usuario actual.
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    final AppUser? user = _userProvider.user;

    // Inicializamos los controladores con los datos del usuario.
    // Si algún dato es nulo, se usa un string vacío como fallback.
    _userController = TextEditingController(text: user?.username ?? '');
    _nombreController = TextEditingController(text: user?.nombre ?? '');
    _apellidosController = TextEditingController(text: user?.apellidos ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    // Liberamos los recursos de los controladores para evitar fugas de memoria.
    _userController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// [_handleConfirmChanges]
  ///
  /// Valida los datos y, si son correctos, llama al proveedor para actualizarlos.
  Future<void> _handleConfirmChanges() async {
    // --- Validación local ---
    // Realiza validaciones rápidas en el cliente antes de enviar la petición.
    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(emailError)));
      return; // Detiene la ejecución si hay un error.
    }

    final nombreError = Validators.validateNotNull(
        _nombreController.text, "El nombre es obligatorio");
    if (nombreError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(nombreError)));
      return;
    }

    // Prepara el mapa con los datos a actualizar.
    // Solo se incluyen los campos que el usuario puede modificar.
    final dataToUpdate = {
      "nombre": _nombreController.text,
      "apellidos": _apellidosController.text,
      "email": _emailController.text,
    };

    // Llama al método del proveedor para actualizar el usuario.
    final success = await _userProvider.updateUser(dataToUpdate);

    // --- Manejo de la respuesta ---
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario modificado correctamente")),
      );
      // Si la actualización fue exitosa, vuelve a la página anterior.
      Navigator.pop(context);
    } else if (mounted) {
      // Si hubo un error, muestra el mensaje de error del proveedor.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_userProvider.error ?? "Error al modificar el usuario."),
          backgroundColor: Colors.red,
        ),
      );
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
            // Campo de usuario (no editable).
            _buildReadOnlyInput(_userController, "Usuario (ID)", Icons.lock),
            const SizedBox(height: 15),

            // Campos editables.
            _buildEditableInput(_nombreController, "Nombre", Icons.person),
            const SizedBox(height: 15),
            _buildEditableInput(
                _apellidosController, "Apellidos", Icons.badge),
            const SizedBox(height: 15),
            _buildEditableInput(_emailController, "Email", Icons.email,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 40),

            // Botón de confirmación.
            Consumer<UserProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // El botón se deshabilita mientras se está procesando la petición.
                    onPressed: provider.isLoading ? null : _handleConfirmChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    // Muestra un indicador de carga o el texto.
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "CONFIRMAR",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un campo de texto editable.
  /// Es un método helper para no repetir código en el `build`.
  Widget _buildEditableInput(
      TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// Construye un campo de texto de solo lectura.
  Widget _buildReadOnlyInput(
      TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      readOnly: true, // La clave para que no sea editable.
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
      ),
    );
  }
}
