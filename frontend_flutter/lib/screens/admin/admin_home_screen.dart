import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Administrador"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          "Bienvenido Admin\n${user['email']}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}