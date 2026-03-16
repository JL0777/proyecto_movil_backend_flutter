import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TraditionalFoodScreen extends StatelessWidget {
  const TraditionalFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: const [
        _Item(
          label: 'Desayuno',
          subtitle: 'Empieza el día con energía',
          icon: Icons.wb_sunny_outlined,
        ),
        SizedBox(height: 12),
        _Item(
          label: 'Almuerzo',
          subtitle: 'El plato fuerte del día',
          icon: Icons.restaurant_outlined,
        ),
        SizedBox(height: 12),
        _Item(
          label: 'Cena',
          subtitle: 'Cierra el día con sabor',
          icon: Icons.nightlight_outlined,
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