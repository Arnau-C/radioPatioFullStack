import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool validateOnChange;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.validateOnChange = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late FocusNode _focusNode;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_hasInteracted) {
        setState(() {
          _hasInteracted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        validator: widget.validator,
        focusNode: _focusNode,
        autovalidateMode: (widget.validateOnChange || _hasInteracted)
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
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
          // errorText: Ya no manual, TextFormField se encarga
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
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
