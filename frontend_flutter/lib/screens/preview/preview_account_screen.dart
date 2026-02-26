import 'package:flutter/material.dart';
import '../welcome_screen.dart';
import 'preview_help_screen.dart';

class PreviewAccountScreen extends StatelessWidget {
  const PreviewAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const SizedBox(height: 40),

          const Icon(Icons.person_outline, size: 80),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            },
            child: const Text("Iniciar sesión / Registrarse"),
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Ayuda"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreviewHelpScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}