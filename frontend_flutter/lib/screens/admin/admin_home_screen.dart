import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({
    super.key,
    required this.user,
  });

  Future<void> _logout(BuildContext context) async {
    await SessionManager.clearSession();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Administrador"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
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