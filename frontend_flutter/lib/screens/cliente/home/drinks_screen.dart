import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Item(label: 'Jugos'),
        _Item(label: 'Gaseosas'),
        _Item(label: 'Bebidas calientes'),
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
      leading: const Icon(Icons.local_drink, color: AppTheme.primaryOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}