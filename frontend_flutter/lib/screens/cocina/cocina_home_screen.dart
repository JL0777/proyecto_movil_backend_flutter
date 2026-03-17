import 'package:flutter/material.dart';
import '../../core/utils/logout_helper.dart';

class CocinaHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const CocinaHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Cocina"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.confirmarCierreSesion(context),
          ),
        ],
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