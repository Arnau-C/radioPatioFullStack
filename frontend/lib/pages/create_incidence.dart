import 'package:flutter/material.dart';
import 'package:frontend/services/incidencia_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';

class CrearIncidenciaPage extends StatefulWidget {
  final int comunidadId;

  const CrearIncidenciaPage({Key? key, required this.comunidadId})
      : super(key: key);

  @override
  State<CrearIncidenciaPage> createState() => _CrearIncidenciaPageState();
}

class _CrearIncidenciaPageState extends State<CrearIncidenciaPage> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false; // Para mostrar un cargando en el botón

  void _enviarIncidencia() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? token = userProvider.token;
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay sesión activa')),
        );
        setState(() => _isSending = false);
        return;
      }

      final incidenciaService = IncidenciaService();
      bool exito = await incidenciaService.crearIncidencia(
          widget.comunidadId,
          _tituloController.text.trim(),
          _descripcionController.text.trim(),
          token);

      if (mounted) {
        setState(() => _isSending = false);
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incidencia enviada correctamente 🎉'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al enviar la incidencia ❌'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo ligeramente gris para resaltar los campos
      appBar: AppBar(
        title: const Text('Nueva Incidencia', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column( 
            children: [
              // Icono e Instrucción
              const Icon(Icons.build_circle_outlined, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                '¿Qué ha ocurrido?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Describe la avería para que el presidente pueda gestionarla lo antes posible.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Campo Título
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título de la avería',
                  prefixIcon: const Icon(Icons.title, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val!.isEmpty ? 'El título es obligatorio' : null,
              ),
              const SizedBox(height: 20),

              // Campo Descripción
              TextFormField(
                controller: _descripcionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descripción detallada',
                  hintText: 'Explica dónde y qué sucede...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80), // Ajuste para que el icono suba
                    child: Icon(Icons.description, color: Colors.teal),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
                validator: (val) => val!.isEmpty ? 'Explica un poco la avería' : null,
              ),
              const SizedBox(height: 40),

              // Botón de Enviar
              ElevatedButton(
                onPressed: _isSending ? null : _enviarIncidencia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'ENVIAR REPORTE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Botón Cancelar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}