import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home MyMeal'),
        backgroundColor: const Color(0xFFE8651A),
      ),
      body: Center(
        child: Text(
          'Bienvenido $email 🎉',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}