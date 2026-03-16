import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: const [
        _Item(
          label: 'Jugos',
          subtitle: 'Naturales y frescos',
          icon: Icons.local_bar_outlined,
        ),
        SizedBox(height: 12),
        _Item(
          label: 'Gaseosas',
          subtitle: 'Frías y burbujeantes',
          icon: Icons.local_drink_outlined,
        ),
        SizedBox(height: 12),
        _Item(
          label: 'Bebidas calientes',
          subtitle: 'Café, té y más',
          icon: Icons.coffee_outlined,
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;

  const _Item({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 26),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        trailing: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.lightOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.chevron_right,
            color: AppTheme.primaryOrange,
            size: 22,
          ),
        ),
      ),
    );
  }
}