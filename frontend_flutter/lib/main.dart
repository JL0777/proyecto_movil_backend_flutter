import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> getMessage() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/'),
    );

    final data = json.decode(response.body);
    return data['message'];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Prueba Backend")),
        body: FutureBuilder<String>(
          future: getMessage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error conectando"));
            }

            return Center(
              child: Text(snapshot.data ?? "Sin datos"),
            );
          },
        ),
      ),
    );
  }
}