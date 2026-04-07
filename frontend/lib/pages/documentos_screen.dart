import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:frontend/models/carpeta.dart';
import 'package:frontend/models/documento.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/services/documento_service.dart';
import 'package:frontend/pages/visor_pdf_screen.dart'; // <--- NUEVO

class DocumentosScreen extends StatefulWidget {
  const DocumentosScreen({super.key});

  @override
  State<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen> {
  final DocumentoService _docService = DocumentoService();

  List<Carpeta> _carpetas = [];
  List<Documento> _documentos = [];
  Carpeta? _carpetaActual;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token!;
      final communityProv = Provider.of<CommunityProvider>(
        context,
        listen: false,
      );

      if (communityProv.communityName == null)
        await communityProv.getCommunityDetails();
      final comunidad = communityProv.communityName!;

      _carpetas = await _docService.getCarpetas(comunidad, token);

      // Mantenemos la carpeta seleccionada o cogemos la principal por defecto
      if (_carpetaActual != null) {
        _carpetaActual = _carpetas.firstWhere(
          (c) => c.id == _carpetaActual!.id,
          orElse: () => _carpetas.first,
        );
      } else {
        _carpetaActual = _carpetas.firstWhere(
          (c) => c.esPrincipal,
          orElse: () => _carpetas.first,
        );
      }

      await _cargarDocumentosDeCarpeta();
    } catch (e) {
      _mostrarMensaje("Error al cargar datos: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarDocumentosDeCarpeta() async {
    if (_carpetaActual == null) return;
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token!;
      _documentos = await _docService.getDocumentos(_carpetaActual!.id, token);
    } catch (e) {
      _mostrarMensaje("Error al cargar documentos", Colors.red);
    }
  }

  void _mostrarMensaje(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // --- LÓGICA SUBIR PDF ---
  Future<void> _subirPDF() async {
    try {
      // 1. Abrimos el selector de archivos nativo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      // 2. Si el usuario eligió un archivo y no canceló
      if (result != null) {
        // Comprobación de seguridad
        if (_carpetaActual == null) {
          _mostrarMensaje(
            "Error: No hay ninguna carpeta seleccionada",
            Colors.orange,
          );
          return;
        }

        setState(() => _isLoading = true);

        final token = Provider.of<UserProvider>(context, listen: false).token!;
        final username = Provider.of<UserProvider>(
          context,
          listen: false,
        ).user!.username;

        // Llamamos al backend para subirlo
        await _docService.subirPDF(
          result.files.first,
          _carpetaActual!.id,
          username,
          token,
        );

        _mostrarMensaje("¡PDF subido correctamente! 🎉", Colors.green);
        await _cargarDatos(); // Recargar para ver el nuevo PDF
      }
    } catch (e) {
      // SI ALGO EXPLOTA (Explorador, permisos, o backend), LO VEREMOS AQUÍ:
      _mostrarMensaje("🚨 ERROR: ${e.toString()}", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA GESTIÓN DE CARPETAS ---
  Future<void> _crearCarpetaDialog() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Carpeta"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nombre de la carpeta"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final token = Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).token!;
                final comunidad = Provider.of<CommunityProvider>(
                  context,
                  listen: false,
                ).communityName!;
                await _docService.crearCarpeta(
                  controller.text,
                  comunidad,
                  token,
                );
                await _cargarDatos();
              } catch (e) {
                _mostrarMensaje("Error al crear carpeta", Colors.red);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  Future<void> _moverDocumento(Documento doc) async {
    // Excluir la carpeta actual de la lista de destinos
    final carpetasDestino = _carpetas
        .where((c) => c.id != _carpetaActual!.id)
        .toList();
    if (carpetasDestino.isEmpty) {
      _mostrarMensaje("No hay otras carpetas donde moverlo", Colors.orange);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mover Documento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: carpetasDestino
              .map(
                (c) => ListTile(
                  leading: const Icon(Icons.folder, color: Colors.orangeAccent),
                  title: Text(c.nombre),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    try {
                      final token = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).token!;
                      await _docService.moverDocumento(doc.id, c.id, token);
                      _mostrarMensaje("Documento movido", Colors.green);
                      await _cargarDatos();
                    } catch (e) {
                      _mostrarMensaje("Error al mover", Colors.red);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administración"),
        backgroundColor: const Color.fromARGB(255, 77, 87, 86),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de Carpetas (Tipo Pestañas)
                Container(
                  height: 60,
                  color: Colors.grey[200],
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    itemCount: _carpetas.length,
                    itemBuilder: (context, index) {
                      final carpeta = _carpetas[index];
                      final isSelected = carpeta.id == _carpetaActual?.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(carpeta.nombre),
                          selected: isSelected,
                          selectedColor: Colors.teal[100],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _carpetaActual = carpeta;
                                _isLoading = true;
                              });
                              _cargarDocumentosDeCarpeta().then(
                                (_) => setState(() => _isLoading = false),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Botonera de Opciones de Carpeta
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _subirPDF,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Subir PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings, color: Colors.grey),
                        onSelected: (value) async {
                          if (value == 'crear') _crearCarpetaDialog();
                          if (value == 'borrar') {
                            try {
                              setState(() => _isLoading = true);
                              await _docService.borrarCarpeta(
                                _carpetaActual!.id,
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).token!,
                              );
                              _carpetaActual = null; // Reiniciamos selección
                              await _cargarDatos();
                            } catch (e) {
                              _mostrarMensaje(e.toString(), Colors.red);
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'crear',
                            child: Text("Crear Nueva Carpeta"),
                          ),
                          if (_carpetaActual != null &&
                              !_carpetaActual!.esPrincipal)
                            const PopupMenuItem(
                              value: 'borrar',
                              child: Text(
                                "Borrar Carpeta Actual",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de Documentos
                Expanded(
                  child: _documentos.isEmpty
                      ? const Center(
                          child: Text(
                            "Carpeta vacía. No hay PDFs.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _documentos.length,
                          itemBuilder: (context, index) {
                            final doc = _documentos[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                                title: Text(
                                  doc.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Subido por: ${doc.creadorUsername}",
                                ),

                                // --- ¡NUEVO! AL TOCAR EL DOCUMENTO, SE ABRE EL VISOR ---
                                onTap: () {
                                  final token = Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).token!;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VisorPdfScreen(
                                        docId: doc.id,
                                        titulo: doc.titulo,
                                        token: token,
                                      ),
                                    ),
                                  );
                                },

                                // -------------------------------------------------------
                                // Busca tu propiedad 'trailing' y cámbiala por esto:
                                trailing: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // ¡Muy importante para que no explote!
                                  children: [
                                    // --- BOTÓN DE MOVER (El que ya tenías) ---
                                    IconButton(
                                      icon: const Icon(
                                        Icons.drive_file_move_outline,
                                        color: Colors.teal,
                                      ),
                                      tooltip: "Mover documento",
                                      onPressed: () => _moverDocumento(doc),
                                    ),

                                    // --- BOTÓN NUEVO: BORRAR ---
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: "Borrar documento",
                                      onPressed: () async {
                                        // 1. Pedir confirmación al usuario
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("¿Borrar PDF?"),
                                            content: Text(
                                              "¿Estás seguro de que quieres eliminar '${doc.titulo}'?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text("Cancelar"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text(
                                                  "Borrar",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        // 2. Si confirma, llamamos al servicio
                                        if (confirmar == true) {
                                          try {
                                            setState(() => _isLoading = true);
                                            final token =
                                                Provider.of<UserProvider>(
                                                  context,
                                                  listen: false,
                                                ).token!;

                                            // Llamamos a la función borrar que creamos en el paso anterior
                                            await _docService.borrarDocumento(
                                              doc.id,
                                              token,
                                            );

                                            _mostrarMensaje(
                                              "Archivo eliminado correctamente",
                                              Colors.green,
                                            );
                                            await _cargarDatos(); // Recargamos la lista
                                          } catch (e) {
                                            _mostrarMensaje(
                                              "Error al borrar: $e",
                                              Colors.red,
                                            );
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
