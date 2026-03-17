import 'package:flutter/material.dart';

class VentasTab extends StatelessWidget {
  const VentasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Reporte de Ventas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'En construcción 🚧',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}