import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ¡OJO! Ajusta esta ruta a donde tengas guardado tu ApiClient

class TablonIncidenciasScreen extends StatefulWidget {
  final int comunidadId;
  final String tokenJwt;
  final bool isPresidenteOrAdmin;

  const TablonIncidenciasScreen({
    super.key, 
    required this.comunidadId,
    required this.tokenJwt,
    required this.isPresidenteOrAdmin,
  });

  @override
  State<TablonIncidenciasScreen> createState() => _TablonIncidenciasScreenState();
}

class _TablonIncidenciasScreenState extends State<TablonIncidenciasScreen> {
  List<dynamic> incidencias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarIncidencias();
  }

  // 1. OBTENER LAS INCIDENCIAS DESDE SPRING BOOT
  Future<void> _cargarIncidencias() async {
    // Usamos tu ApiClient centralizado
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/${widget.comunidadId}/incidencias');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.tokenJwt}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          // Usamos utf8.decode para evitar problemas con las tildes y caracteres raros
          incidencias = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        // Podrías manejar aquí un mensaje de error si falla la carga
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al cargar incidencias: $e');
    }
  }

  // 2. MARCAR COMO RESUELTA
  Future<void> _resolverIncidencia(int incidenciaId) async {
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/${widget.comunidadId}/incidencias/$incidenciaId/resolver');
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.tokenJwt}',
        },
      );

      if (response.statusCode == 200) {
        // La borramos de la lista visual al instante para que la UI reaccione rápido
        setState(() {
          incidencias.removeWhere((item) => item['id'] == incidenciaId);
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Incidencia resuelta y eliminada del tablón!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al resolver: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablón de Incidencias'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : incidencias.isEmpty
              ? const Center(
                  child: Text(
                    '¡Todo en orden!\nNo hay incidencias pendientes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: incidencias.length,
                  itemBuilder: (context, index) {
                    final incidencia = incidencias[index];
                    
                    // Extraemos los datos basándonos en tu modelo real de Java
                    final titulo = incidencia['titulo'] ?? 'Sin título';
                    final descripcion = incidencia['descripcion'] ?? 'Sin descripción';
                    
                    // Tu modelo de Java devuelve el objeto "creador" completo, accedemos al username
                    final vecino = incidencia['creador']?['username'] ?? 'Desconocido'; 
                    
                    // Extraemos los primeros 10 caracteres (YYYY-MM-DD) de LocalDateTime para que quede limpio
                    final fecha = incidencia['fechaCreacion']?.toString().substring(0, 10) ?? 'Fecha no disponible';

                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            child: Icon(Icons.priority_high, color: Colors.white),
                          ),
                          title: Text(
                            titulo, 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Text('Enviado por: $vecino', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                                Text('Fecha: $fecha', style: const TextStyle(color: Colors.blueGrey)),
                              ],
                            ),
                          ),
                          isThreeLine: true,
                          // El botón para marcar como resuelto
                          trailing: widget.isPresidenteOrAdmin ? IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
                            tooltip: 'Marcar como resuelta',
                            onPressed: () {
                              _resolverIncidencia(incidencia['id']);
                            },
                          ) : null,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/incidencias/nueva'),
        icon: const Icon(Icons.add_alert),
        label: const Text("Nueva Incidencia"),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}