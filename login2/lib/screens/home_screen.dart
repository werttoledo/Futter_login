import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String purchaseInfo = "Presiona el botón para realizar una compra";
  bool isLoading = false;

  Future<void> makePurchase() async {
    final url = Uri.parse("http://52.90.111.225:8081/api/cal/purchases");

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsImtpZCI6Imc0QzNCc1ExTE9USEtsUDUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2xlcGdtcXV1dWRnY2F0b3pkcWNwLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJmZDYyOTZjNS00N2M3LTQyN2YtOTgwYS05OGI0YmQ5MTRhYTkiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzQyOTI1NjA2LCJpYXQiOjE3NDI5MjIwMDYsImVtYWlsIjoid2VydHRvbGVkb0BnbWFpbC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoid2VydHRvbGVkb0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJzdWIiOiJmZDYyOTZjNS00N2M3LTQyN2YtOTgwYS05OGI0YmQ5MTRhYTkifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MTc0MjkyMjAwNn1dLCJzZXNzaW9uX2lkIjoiY2E3MGJjNGYtZWUwYi00NDk1LWIxMWQtMWUzYjgyOGU2Y2I0IiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.VgG1eZnikt19jGM8EU09Jo0ut7a1a5T_KdKvrm832ls",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "description": "Compra de prueba",
          "amountInCents": 50000
        }),
      );

      setState(() {
        isLoading = false;
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          purchaseInfo = """
          ✅ Compra realizada con éxito
          📌 ID: ${data['id']}
          📧 Usuario: ${data['user']['email']}
          🛒 Descripción: ${data['description']}
          💲 Monto: ${data['amountInCents']} centavos
          🔄 Estado: ${data['status']}
          📅 Fecha: ${data['createdAt']}
          🔢 Referencia: ${data['reference']}
          """;
        } else {
          purchaseInfo = "⚠️ Error en la compra (${response.statusCode}):\n${response.body}";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        purchaseInfo = "❌ Error de conexión: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Compra en Línea", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pushReplacementNamed(context, "/"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              "Realiza tu compra de manera segura",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator(color: Colors.deepPurple)
                : ElevatedButton.icon(
                    onPressed: makePurchase,
                    icon: Icon(Icons.payment),
                    label: Text("Realizar Compra"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  purchaseInfo,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}