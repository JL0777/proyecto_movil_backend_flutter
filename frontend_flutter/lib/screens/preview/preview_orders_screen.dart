import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../login_screen.dart';
import '../register_screen.dart';

class PreviewOrdersScreen extends StatefulWidget {
  const PreviewOrdersScreen({super.key});

  @override
  State<PreviewOrdersScreen> createState() =>
      _PreviewOrdersScreenState();
}

class _PreviewOrdersScreenState extends State<PreviewOrdersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis pedidos")),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // HEADER PRO
                    Column(
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
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryOrange
                                    .withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 48,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Información sobre pedidos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          "Aquí encontrarás toda la información necesaria para entender cómo funcionan los pedidos dentro de la app.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _item(
                      Icons.receipt_long,
                      "Estados del pedido",
                      "Aprende qué significa cada estado: preparación, en camino y entregado.",
                    ),
                    _item(
                      Icons.history,
                      "Historial",
                      "Cómo consultar tus pedidos anteriores desde tu cuenta.",
                    ),
                    _item(
                      Icons.notifications,
                      "Notificaciones",
                      "Cómo recibir actualizaciones de tus pedidos.",
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Inicia sesión para acceder a la sección donde podrás gestionar tus pedidos.",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTONES
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "INICIAR SESIÓN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.lightOrange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(desc),
      ),
    );
  }
}