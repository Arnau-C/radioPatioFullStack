import 'package:flutter/material.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// [CreateCommunityPage]
///
/// Página dedicada a la creación de una nueva comunidad de vecinos.
/// Permite a un administrador introducir el nombre y la dirección de la comunidad.
///
/// Es un `StatefulWidget` para gestionar el estado del formulario y la lógica de creación.
class CreateCommunityPage
    extends StatefulWidget {
  const CreateCommunityPage({
    super.key,
  });

  @override
  State<CreateCommunityPage>
  createState() =>
      _CreateCommunityPageState();
}

/// [_CreateCommunityPageState]
///
/// Gestiona el estado y la lógica de la [CreateCommunityPage].
class _CreateCommunityPageState
    extends State<CreateCommunityPage> {
  // Clave global para identificar y gestionar el estado del formulario.
  // Permite validar todos los campos de texto a la vez.
  final _formKey =
      GlobalKey<FormState>();

  // Controladores para los campos de nombre y dirección.
  final _nombreController =
      TextEditingController();
  final _direccionController =
      TextEditingController();

  /// [_crearComunidad]
  ///
  /// Gestiona la validación y el proceso de creación de la comunidad.
  Future<void> _crearComunidad() async {
    // Si el formulario no es válido, no hace nada.
    // `validate()` ejecuta la función `validator` de cada TextFormField.
    if (!_formKey.currentState!
        .validate())
      return;

    // Obtiene las instancias de los proveedores.
    final communityProvider =
        Provider.of<CommunityProvider>(
          context,
          listen: false,
        );
    final userProvider =
        Provider.of<UserProvider>(
          context,
          listen: false,
        );

    // Llama al método del proveedor para crear la comunidad.
    final updatedUserData =
        await communityProvider
            .createCommunity(
              nombre: _nombreController
                  .text
                  .trim(),
              direccion:
                  _direccionController
                      .text
                      .trim(),
            );

    // --- Manejo de la respuesta ---
    if (updatedUserData != null &&
        mounted) {
      // Si la creación fue exitosa, actualiza los datos del usuario en el UserProvider.
      userProvider.setUser(
        updatedUserData,
      );

      // Muestra un diálogo de éxito con el código de invitación.
      // Es un paso crucial para que otros usuarios puedan unirse.
      await showDialog(
        context: context,
        barrierDismissible:
            false, // El usuario no puede cerrar el diálogo pulsando fuera.
        builder: (ctx) => AlertDialog(
          title: const Text(
            "¡Comunidad Creada!",
          ),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // La columna ocupa el mínimo espacio.
            children: [
              const Text(
                "La comunidad se ha guardado correctamente.",
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Este es el CÓDIGO DE INVITACIÓN para tus vecinos:",
              ),
              const SizedBox(
                height: 15,
              ),
              // Contenedor resaltado para el código de invitación.
              Container(
                padding:
                    const EdgeInsets.all(
                      15,
                    ),
                decoration: BoxDecoration(
                  color: Colors
                      .orange
                      .shade100,
                  borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                  border: Border.all(
                    color:
                        Colors.orange,
                  ),
                ),
                child: Text(
                  communityProvider
                          .invitationCode ??
                      '',
                  style:
                      const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight
                                .bold,
                        letterSpacing:
                            2,
                      ),
                  textAlign:
                      TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                ); // Cierra el diálogo.
                Navigator.pop(
                  context,
                  true,
                ); // Vuelve a la pantalla anterior.
              },
              child: const Text(
                "ENTENDIDO",
              ),
            ),
          ],
        ),
      );
    } else if (mounted) {
      // Si hay un error, muestra un mensaje en una SnackBar.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${communityProvider.error}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nueva Comunidad",
        ),
        backgroundColor:
            Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Form(
          key:
              _formKey, // Asigna la clave al formulario.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              const Icon(
                Icons.location_city,
                size: 80,
                color:
                    Colors.deepPurple,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Registra tu Comunidad",
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // Campo de texto para el nombre.
              TextFormField(
                controller:
                    _nombreController,
                decoration: const InputDecoration(
                  labelText:
                      "Nombre de la Comunidad",
                  hintText:
                      "Ej: Residencial Los Olivos",
                  prefixIcon: Icon(
                    Icons.home,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "El nombre es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              // Campo de texto para la dirección.
              TextFormField(
                controller:
                    _direccionController,
                decoration: const InputDecoration(
                  labelText:
                      "Dirección Física",
                  hintText:
                      "Ej: Av. Principal 123",
                  prefixIcon: Icon(
                    Icons.map,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "La dirección es obligatoria";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 40,
              ),
              // Botón para enviar el formulario.
              Consumer<
                CommunityProvider
              >(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed:
                        provider
                            .isLoading
                        ? null
                        : _crearComunidad,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors
                              .deepPurple,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                            vertical:
                                15,
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                      ),
                    ),
                    child:
                        provider
                            .isLoading
                        ? const CircularProgressIndicator(
                            color: Colors
                                .white,
                          )
                        : const Text(
                            "CREAR COMUNIDAD",
                            style: TextStyle(
                              fontSize:
                                  18,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
