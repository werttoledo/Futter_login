import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de correo electrónico
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Correo Electrónico"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese un correo";
                  }
                  // Expresión regular para validar el correo
                  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return "Ingrese un correo válido";
                  }
                  return null;
                },
              ),
              // Campo de contraseña
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese una contraseña";
                  }
                  if (value.length < 6) {
                    return "Debe tener al menos 6 caracteres";
                  }
                  return null;
                },
              ),
              // Confirmación de contraseña
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: "Repetir Contraseña"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Repita la contraseña";
                  }
                  if (value != _passwordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Botón de registro
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Registro exitoso")),
                    );
                    Navigator.pushReplacementNamed(context, "/home");
                  }
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
      ),
    );
  }
}
