import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PreviewTraditionalScreen extends StatelessWidget {
  const PreviewTraditionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Item('Desayuno'),
        _Item('Almuerzo'),
        _Item('Cena'),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  const _Item(this.label);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}