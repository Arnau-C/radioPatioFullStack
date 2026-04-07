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

  Future<void> _expulsarVecino(String usernameExpulsado) async {
    // Confirmación antes de borrar
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
          // Lo quitamos de la lista al instante
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
                
                // Evitar que el presidente se expulse a sí mismo
                final bool esElMismo = rol == 'PRESIDENTE'; 

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rol == 'PRESIDENTE' ? Colors.orange : Colors.teal.shade200,
                    child: Icon(rol == 'PRESIDENTE' ? Icons.star : Icons.person, color: Colors.white),
                  ),
                  title: Text('@$username', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(rol == 'PRESIDENTE' ? 'Presidente' : 'Vecino'),
                  trailing: (widget.isPresidente && !esElMismo)
                      ? IconButton(
                          icon: const Icon(Icons.person_remove, color: Colors.red),
                          onPressed: () => _expulsarVecino(username),
                          tooltip: 'Expulsar de la comunidad',
                        )
                      : null,
                );
              },
            ),
    );
  }
}