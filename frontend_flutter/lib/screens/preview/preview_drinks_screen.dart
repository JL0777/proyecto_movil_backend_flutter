import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PreviewDrinksScreen extends StatelessWidget {
  const PreviewDrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Item('Jugos'),
        _Item('Gaseosas'),
        _Item('Bebidas calientes'),
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
      leading: const Icon(Icons.local_drink, color: AppTheme.primaryOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}