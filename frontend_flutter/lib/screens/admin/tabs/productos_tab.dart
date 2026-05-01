import 'package:flutter/material.dart';
import 'gestion_menus_screen.dart';
import 'gestion_ingredientes_screen.dart';

class ProductosTab extends StatelessWidget {
  const ProductosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué deseas gestionar?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona una opción para continuar',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),

          _OpcionCard(
            icono: Icons.restaurant_menu_rounded,
            titulo: 'Gestión de menús',
            descripcion: 'Crea, edita y organiza los menús disponibles',
            color: const Color(0xFFE8651A),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GestionMenusScreen()),
            ),
          ),
          const SizedBox(height: 14),

          _OpcionCard(
            icono: Icons.egg_alt_rounded,
            titulo: 'Gestión de ingredientes',
            descripcion: 'Administra los ingredientes y sus precios base',
            color: Colors.green.shade600,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const GestionIngredientesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _OpcionCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icono, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: color, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}