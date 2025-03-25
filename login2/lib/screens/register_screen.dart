import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Correo Electrónico"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Text("Registrarse"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("¿Ya tienes cuenta? Inicia sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
