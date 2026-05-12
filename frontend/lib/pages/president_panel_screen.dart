import 'package:flutter/material.dart';
import 'package:frontend/models/recurso.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/recurso_service.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class PresidentPanelScreen extends StatefulWidget {
  const PresidentPanelScreen({super.key});

  @override
  State<PresidentPanelScreen> createState() => _PresidentPanelScreenState();
}

class _PresidentPanelScreenState extends State<PresidentPanelScreen> {
  final RecursoService _recursoService = RecursoService();
  int? _comunidadId;
  List<Recurso> _recursos = [];
  bool _isLoading = true;

  final Color primaryDark = const Color(0xFF1A365D);
  final Color accentColor = const Color(0xFFE27D60);

  @override
  void initState() {
    super.initState();
    _cargarDatosBasicos();
  }

  Future<void> _cargarDatosBasicos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final token = userProvider.token;

    if (user != null && token != null) {
      try {
        final url = Uri.parse('${ApiClient.baseUrl}/comunidades/detalle/${user.username}');
        final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _comunidadId = data['id'] ?? data['comunidadId'];
          if (_comunidadId != null) {
            _cargarRecursos(token);
          }
        }
      } catch (e) {
        debugPrint('Error al obtener comunidad: $e');
      }
    }
  }

  Future<void> _cargarRecursos(String token) async {
    try {
      final recursos = await _recursoService.obtenerRecursos(_comunidadId!, token);
      if (mounted) {
        setState(() {
          _recursos = recursos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar recursos')));
      }
    }
  }

  void _mostrarDialogoNuevoRecurso() {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    // NUEVO: Controlador para el número de horas (por defecto "2")
    final TextEditingController horasController = TextEditingController(text: '2'); 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Añadir nuevo Espacio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre (ej: Pista Pádel)'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción corta'),
                ),
                const SizedBox(height: 15),
                // NUEVO: Input numérico para las horas
                TextField(
                  controller: horasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Horas máximas por reserva',
                    hintText: 'Ej: 2',
                    icon: Icon(Icons.timer),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isEmpty || horasController.text.isEmpty) return;
                
                // Convertimos el texto a número
                int maxHoras = int.tryParse(horasController.text) ?? 2;

                try {
                  // OJO: Tu recurso_service.dart tiene que estar actualizado para enviar este INT
                  await _recursoService.crearRecurso(
                    _comunidadId!,
                    nombreController.text.trim(),
                    descController.text.trim(),
                    maxHoras, // 👈 Pasamos el número en vez del String tipoReserva
                    token!,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _cargarRecursos(token);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryDark, foregroundColor: Colors.white),
              child: const Text('CREAR ESPACIO'),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarRecurso(int recursoId) async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    try {
      await _recursoService.eliminarRecurso(recursoId, token!);
      _cargarRecursos(token);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Presidente', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Espacios Comunitarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _recursos.isEmpty
                        ? const Center(child: Text('No hay espacios añadidos. ¡Crea el primero!'))
                        : ListView.builder(
                            itemCount: _recursos.length,
                            itemBuilder: (context, index) {
                              final recurso = _recursos[index];
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.sports_tennis, // Icono genérico para espacios
                                    color: accentColor,
                                  ),
                                  title: Text(recurso.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  // Añadimos la info del límite al subtítulo
                                  subtitle: Text('${recurso.descripcion ?? ''}\nLímite: ${recurso.maxHorasReserva} hrs/reserva'),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarRecurso(recurso.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _comunidadId == null ? null : _mostrarDialogoNuevoRecurso,
        backgroundColor: primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}