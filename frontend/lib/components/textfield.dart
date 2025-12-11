import 'package:flutter/material.dart';

class MyTextField
    extends StatelessWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 20,
          ),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                  12,
                ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
