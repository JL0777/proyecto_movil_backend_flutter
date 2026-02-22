import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar información'),
      ),
      body: const Center(
        child: Text('Pantalla de edición'),
      ),
    );
  }
}