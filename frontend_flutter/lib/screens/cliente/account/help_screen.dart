import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        children: [

          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.lightOrange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryOrange,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    size: 48,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '¿En qué podemos ayudarte?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Encuentra respuestas a tus preguntas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          const _HelpCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Mis pedidos',
            subtitle: 'Consulta el estado de tus pedidos',
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            icon: Icons.payment_outlined,
            title: 'Pagos y facturación',
            subtitle: 'Información sobre métodos de pago',
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            icon: Icons.location_on_outlined,
            title: 'Entregas y direcciones',
            subtitle: 'Todo sobre el envío de tu pedido',
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            icon: Icons.chat_bubble_outline,
            title: 'Contáctanos',
            subtitle: 'Habla con nuestro equipo de soporte',
          ),

        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.lightOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.chevron_right,
            color: AppTheme.primaryOrange,
            size: 20,
          ),
        ),
      ),
    );
  }
}