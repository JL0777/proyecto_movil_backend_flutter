import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TraditionalFoodScreen extends StatelessWidget {
  const TraditionalFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Item(label: 'Desayuno'),
        _Item(label: 'Almuerzo'),
        _Item(label: 'Cena'),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String label;

  const _Item({required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}