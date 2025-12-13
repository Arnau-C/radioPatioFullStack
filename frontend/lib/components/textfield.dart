import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  // Estas son las variables que ahora pediremos desde fuera
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller, // Conectamos el controlador
        obscureText: obscureText, // Ocultamos texto si es true
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText, // Mostramos el texto de ayuda
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
