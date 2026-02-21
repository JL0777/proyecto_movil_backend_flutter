import 'package:flutter/material.dart';

class CocinaHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const CocinaHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Cocina"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          "Bienvenido Cocina\n${user['email']}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}