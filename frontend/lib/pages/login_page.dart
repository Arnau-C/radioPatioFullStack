import 'package:flutter/material.dart';
import 'package:frontend/components/button.dart';
import 'package:frontend/components/textfield.dart';

class LoginPage
    extends StatelessWidget {
  const LoginPage({super.key});

  //sign in user method
  void onTap() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(
            255,
            223,
            156,
            136,
          ),
      body: Center(
        child: Column(
          children: [
            //logo
            Image.asset(
              'lib/images/logo.png',
              width: 300,
              height: 300,
            ),

            Text(
              'Usuario',
              style: TextStyle(
                color:
                    const Color.fromARGB(
                      255,
                      0,
                      30,
                      53,
                    ),
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            //user textfield
            MyTextField(),

            Text(
              'Contraseña',
              style: TextStyle(
                color:
                    const Color.fromARGB(
                      255,
                      0,
                      30,
                      53,
                    ),
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            //password textfield
            MyTextField(),

            const SizedBox(height: 25),
            //button
            MyButton(onTap: onTap),
          ],
        ),
      ),
    );
  }
}
