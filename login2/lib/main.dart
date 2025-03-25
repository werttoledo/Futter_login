import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/login", // Inicia en el Login
    routes: {
      "/login": (context) => LoginScreen(),
      "/register": (context) => RegisterScreen(),
      "/home": (context) => HomeScreen(),
    },
  ));
}
