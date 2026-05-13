import 'package:flutter/material.dart';
import 'package:frontend/models/recurso.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/recurso_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
  }

  Future<void> _cargarDatos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final token = userProvider.token;
    if (token == null) return;

    // Si el provider ya tiene el communityId cargado, lo usamos directamente
    if (communityProvider.communityId == null) {
      await communityProvider.getCommunityDetails();
    }

    _comunidadId = communityProvider.communityId;

    if (_comunidadId != null) {
      await _cargarRecursos(token);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarRecursos(String token) async {
    try {
      final recursos = await _recursoService.obtenerRecursos(_comunidadId!, token);
      if (!mounted) return;
      setState(() {
        _recursos = recursos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar recursos')),
      );
    }
  }

  void _mostrarDialogoNuevoRecurso() {
    if (_comunidadId == null) return;
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) return;

    // Guardamos el contexto de la pantalla para usarlo en el SnackBar,
    // ya que el contexto del dialog no tiene acceso al Scaffold principal.
    final screenContext = context;

    final TextEditingController nombreController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String tipoReserva = 'POR_HORAS';
    int maxHorasReserva = 2;

    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, setDialogState) => AlertDialog(
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
                DropdownButtonFormField<String>(
                  initialValue: tipoReserva,
                  decoration: const InputDecoration(labelText: 'Modo de reserva'),
                  items: const [
                    DropdownMenuItem(value: 'POR_HORAS', child: Text('Por bloques de horas')),
                    DropdownMenuItem(value: 'POR_DIAS', child: Text('Por días enteros')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => tipoReserva = val);
                    }
                  },
                ),
                // Solo tiene sentido limitar horas en el modo POR_HORAS
                if (tipoReserva == 'POR_HORAS') ...[
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    initialValue: maxHorasReserva,
                    decoration: const InputDecoration(
                      labelText: 'Máximo de horas por reserva',
                      helperText: 'Tiempo máximo que un vecino puede reservar de una vez',
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 hora')),
                      DropdownMenuItem(value: 2, child: Text('2 horas')),
                      DropdownMenuItem(value: 3, child: Text('3 horas')),
                      DropdownMenuItem(value: 4, child: Text('4 horas')),
                      DropdownMenuItem(value: 6, child: Text('6 horas')),
                      DropdownMenuItem(value: 8, child: Text('8 horas (día completo)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => maxHorasReserva = val);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isEmpty) return;
                final dialogNav = Navigator.of(dialogContext);
                final screenMessenger = ScaffoldMessenger.of(screenContext);
                try {
                  await _recursoService.crearRecurso(
                    _comunidadId!,
                    nombreController.text.trim(),
                    descController.text.trim(),
                    tipoReserva,
                    maxHorasReserva,
                    token,
                  );
                  dialogNav.pop();
                  if (mounted) _cargarRecursos(token);
                } catch (e) {
                  dialogNav.pop();
                  screenMessenger.showSnackBar(
                    SnackBar(content: Text('Error al crear espacio: $e'), backgroundColor: Colors.red),
                  );
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _recursoService.eliminarRecurso(recursoId, token!);
      if (mounted) _cargarRecursos(token);
    } catch (e) {
      messenger.showSnackBar(const SnackBar(content: Text('Error al eliminar')));
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
                                    recurso.tipoReserva == 'POR_HORAS' ? Icons.access_time : Icons.calendar_today,
                                    color: accentColor,
                                  ),
                                  title: Text(recurso.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(recurso.descripcion ?? 'Sin descripción'),
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
        heroTag: null,
        onPressed: _comunidadId == null ? null : _mostrarDialogoNuevoRecurso,
        backgroundColor: primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
