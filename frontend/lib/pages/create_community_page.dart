import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateCommunityPage extends StatefulWidget{
  final String username;

  const CreateCommunityPage({super.key, required this.username});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage>{
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> crearComunidad() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // URL directa como la tenías tú (Para Linux usa 127.0.0.1)
    final url = Uri.parse('http://127.0.0.1:8080/api/comunidades/crear');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Estos campos coinciden con lo que espera tu Java (ComunidadRequest)
          'nombre': _nombreController.text.trim(),
          'direccion': _direccionController.text.trim(),
          'presidenteUsername': widget.username, 
        }),
      );

      if (response.statusCode == 200) {
        // El backend nos devuelve el JSON con el código generado
        final data = jsonDecode(response.body);
        String codigoGenerado = data['codigoInvitacion'];

        if (mounted) {
          // Mostramos el código en un diálogo bonito
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("¡Comunidad Creada! 🎉"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("La comunidad se ha guardado correctamente."),
                  const SizedBox(height: 10),
                  const Text("Este es el CÓDIGO DE INVITACIÓN para tus vecinos:"),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      codigoGenerado,
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 2
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Cierra el diálogo
                    Navigator.pop(context, { // Vuelve a la pantalla anterior diciendo "true" (éxito)
                      'exito': true,
                      'nuevoCodigo': codigoGenerado
                    });
                  },
                  child: const Text("ENTENDIDO"),
                )
              ],
            ),
          );
        }
      } else {
        // Si falla (ej: usuario ya tiene comunidad)
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.body}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Comunidad"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_city, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                "Registra tu Comunidad",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // CAMPO NOMBRE (Mapea a private String nombre)
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Comunidad",
                  hintText: "Ej: Residencial Los Olivos",
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El nombre es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // CAMPO DIRECCIÓN (Mapea a private String direccion)
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección Física",
                  hintText: "Ej: Av. Principal 123",
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La dirección es obligatoria";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // BOTÓN GUARDAR
              ElevatedButton(
                onPressed: _isLoading ? null : crearComunidad,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CREAR COMUNIDAD", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}