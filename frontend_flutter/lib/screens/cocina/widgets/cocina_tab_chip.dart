import 'package:flutter/material.dart';

class CocinaTabChip extends StatelessWidget {
  final int index;
  final String label;
  final IconData icono;
  final int count;
  final Color color;
  final TabController tabController;

  const CocinaTabChip({
    super.key,
    required this.index,
    required this.label,
    required this.icono,
    required this.count,
    required this.color,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final activo = tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activo ? color : color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 18, color: activo ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: activo ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
              ),
              if (count > 0) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: activo
                        ? Colors.white.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: activo ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}