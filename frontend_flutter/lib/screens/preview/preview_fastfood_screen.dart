import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PreviewFastFoodScreen extends StatelessWidget {
  const PreviewFastFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Item('Hamburguesas'),
        _Item('Perros'),
        _Item('Sandwiches'),
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
      leading: const Icon(Icons.fastfood, color: AppTheme.primaryOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}