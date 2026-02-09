import 'package:flutter/material.dart';

class MyTextField
    extends StatelessWidget {
  final TextEditingController
  controller;
  final String hintText;
  final bool obscureText;
  // Nueva variable para recibir el mensaje de error (puede ser null si no hay error)
  final String? errorMsg;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.errorMsg, // No es 'required' porque al principio no habrá error
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          // Estilos Base
          enabledBorder:
              OutlineInputBorder(
                borderSide:
                    const BorderSide(
                      color:
                          Colors.white,
                    ),
                borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
              ),
          focusedBorder:
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors
                      .grey
                      .shade400,
                ),
                borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
              ),

          // Estilos de Error (NUEVO)
          // Define cómo se ve el borde cuando hay un error (rojo por estándar)
          errorBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(
                  color:
                      Colors.redAccent,
                ),
            borderRadius:
                BorderRadius.circular(
                  10,
                ),
          ),
          // Define cómo se ve si tocas el campo mientras tiene error
          focusedErrorBorder:
              OutlineInputBorder(
                borderSide:
                    const BorderSide(
                      color: Colors.red,
                    ),
                borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
              ),

          // Mensaje de Error (NUEVO)
          errorText:
              errorMsg, // Si esto tiene texto, Flutter activa el modo error
          errorStyle: const TextStyle(
            // Personalizamos para que se lea bien
            color: Colors.redAccent,
            fontWeight: FontWeight
                .bold, // Negrita para mayor visibilidad
            fontSize: 13,
          ),

          fillColor:
              Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
