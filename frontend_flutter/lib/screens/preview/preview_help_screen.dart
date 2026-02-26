import 'package:flutter/material.dart';

class PreviewHelpScreen extends StatelessWidget {
  const PreviewHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayuda")),
      body: const Center(
        child: Text(
          "TAB DE AYUDA",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}