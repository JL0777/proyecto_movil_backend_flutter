import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../welcome_screen.dart';

class CocinaHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const CocinaHomeScreen({
    super.key,
    required this.user,
  });

  Future<void> _logout(BuildContext context) async {
    await SessionManager.clearSession();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Cocina"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
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