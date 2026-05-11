import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

class MiembrosComunidadScreen extends StatefulWidget {
  final int comunidadId;
  final String tokenJwt;
  final bool isPresidente;

  const MiembrosComunidadScreen({
    Key? key,
    required this.comunidadId,
    required this.tokenJwt,
    required this.isPresidente,
  }) : super(key: key);

  @override
  State<MiembrosComunidadScreen> createState() => _MiembrosComunidadScreenState();
}

class _MiembrosComunidadScreenState extends State<MiembrosComunidadScreen> {
  List<dynamic> miembros = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMiembros();
  }

  Future<void> _cargarMiembros() async {
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/${widget.comunidadId}/miembros');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.tokenJwt}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          miembros = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // --- NUEVA FUNCIÓN: Llamada al backend para guardar permisos ---
  Future<void> _actualizarPermisos(int index, String usernameVecino, bool pAvisos, bool pDocs) async {
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/${widget.comunidadId}/miembros/$usernameVecino/permisos');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.tokenJwt}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'permisoCrearAvisos': pAvisos,
          'permisoGestionarDocumentos': pDocs,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Actualizamos la lista local para que no haga falta recargar la pantalla
          miembros[index]['permisoCrearAvisos'] = pAvisos;
          miembros[index]['permisoGestionarDocumentos'] = pDocs;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permisos actualizados'), backgroundColor: Colors.green)
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar permisos'), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      debugPrint('Error al actualizar permisos: $e');
    }
  }

  // --- NUEVA FUNCIÓN: Ventanita del formulario ---
  void _mostrarDialogoPermisos(Map<String, dynamic> vecino, int index) {
    // Leemos lo que viene de base de datos (por si son nulos, ponemos false por defecto)
    bool pAvisos = vecino['permisoCrearAvisos'] ?? false;
    bool pDocs = vecino['permisoGestionarDocumentos'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Permisos de @${vecino['username']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Crear Avisos"),
                subtitle: const Text("Permitir que publique avisos en el tablón"),
                value: pAvisos,
                activeColor: Colors.teal,
                onChanged: (val) => setDialogState(() => pAvisos = val),
              ),
              SwitchListTile(
                title: const Text("Ver Documentos"),
                subtitle: const Text("Acceso a la zona de administración"),
                value: pDocs,
                activeColor: Colors.teal,
                onChanged: (val) => setDialogState(() => pDocs = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                _actualizarPermisos(index, vecino['username'], pAvisos, pDocs);
                Navigator.pop(context);
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _expulsarVecino(String usernameExpulsado) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expulsar vecino'),
        content: Text('¿Estás seguro de que quieres expulsar a @$usernameExpulsado de la comunidad?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Expulsar', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/${widget.comunidadId}/miembros/$usernameExpulsado/expulsar');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer ${widget.tokenJwt}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          miembros.removeWhere((m) => m['username'] == usernameExpulsado);
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vecino expulsado correctamente'), backgroundColor: Colors.green));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al expulsar vecino'), backgroundColor: Colors.red));
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros de la Comunidad'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: miembros.length,
              itemBuilder: (context, index) {
                final miembro = miembros[index];
                final String rol = miembro['rol'] ?? 'USER';
                final String username = miembro['username'] ?? 'Desconocido';
                
                final bool esElMismo = rol == 'PRESIDENTE'; 

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rol == 'PRESIDENTE' ? Colors.orange : Colors.teal.shade200,
                    child: Icon(rol == 'PRESIDENTE' ? Icons.star : Icons.person, color: Colors.white),
                  ),
                  title: Text('@$username', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(rol == 'PRESIDENTE' ? 'Presidente' : 'Vecino'),
                  
                  // --- AQUÍ ESTÁ EL CAMBIO: Ponemos los dos botones juntos ---
                  trailing: (widget.isPresidente && !esElMismo)
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.admin_panel_settings, color: Colors.blueGrey),
                              onPressed: () => _mostrarDialogoPermisos(miembro, index),
                              tooltip: 'Gestionar permisos',
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove, color: Colors.red),
                              onPressed: () => _expulsarVecino(username),
                              tooltip: 'Expulsar de la comunidad',
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
    );
  }
}