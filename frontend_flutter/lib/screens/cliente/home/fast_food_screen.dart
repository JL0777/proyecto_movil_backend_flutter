import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FastFoodScreen extends StatelessWidget {
  const FastFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Item(label: 'Hamburguesas'),
        _Item(label: 'Perros'),
        _Item(label: 'Sandwiches'),
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
      leading: const Icon(Icons.fastfood, color: AppTheme.primaryOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}