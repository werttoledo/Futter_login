import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar Sesión")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                // Simulación de autenticación exitosa
                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Text("Iniciar Sesión"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              child: Text("¿No tienes cuenta? Regístrate aquí"),
            ),
          ],
        ),
      ),
    );
  }
}
