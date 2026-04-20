import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'preview_orders_screen.dart';
import 'preview_payments_screen.dart';
import 'preview_delivery_screen.dart';
import 'preview_contact_screen.dart';

class PreviewHelpScreen extends StatefulWidget {
  const PreviewHelpScreen({super.key});

  @override
  State<PreviewHelpScreen> createState() => _PreviewHelpScreenState();
}

class _PreviewHelpScreenState extends State<PreviewHelpScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          "Ayuda",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          children: [
            /// HEADER REFINADO
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryOrange, Color(0xFFFF8C42)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "¿En qué podemos ayudarte?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Encuentra respuestas a tus preguntas",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            _sectionLabel("CATEGORÍAS DE AYUDA"),
            const SizedBox(height: 16),

            /// LISTA DE OPCIONES
            _HelpCard(
              icon: Icons.shopping_bag_outlined,
              title: "Mis pedidos",
              subtitle: "Consulta el estado de tus pedidos",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreviewOrdersScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _HelpCard(
              icon: Icons.payment_outlined,
              title: "Pagos y facturación",
              subtitle: "Información sobre métodos de pago",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreviewPaymentsScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _HelpCard(
              icon: Icons.location_on_outlined,
              title: "Entregas y direcciones",
              subtitle: "Todo sobre el envío de tu pedido",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreviewDeliveryScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _HelpCard(
              icon: Icons.chat_bubble_outline,
              title: "Contáctanos",
              subtitle: "Habla con nuestro equipo de soporte",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreviewContactScreen()),
              ),
            ),
            
            const SizedBox(height: 40),
            
            Center(
              child: Text(
                "Estamos para servirte",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.withValues(alpha: 0.5),
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFFBBBBBB),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon, 
                    color: AppTheme.primaryOrange, 
                    size: 24
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFCCCCCC),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}