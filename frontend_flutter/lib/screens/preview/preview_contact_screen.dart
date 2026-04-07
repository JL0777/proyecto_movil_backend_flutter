import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../login_screen.dart';
import '../register_screen.dart';

class PreviewContactScreen extends StatefulWidget {
  const PreviewContactScreen({super.key});

  @override
  State<PreviewContactScreen> createState() => _PreviewContactScreenState();
}

class _PreviewContactScreenState extends State<PreviewContactScreen>
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
      appBar: AppBar(title: const Text("Contáctanos")),
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
                            Icons.support_agent_rounded, // ICONO PRO
                            size: 48,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Soporte MyMeal",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          "Puedes comunicarte con nosotros a través de los siguientes canales:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _item(
                      Icons.email_outlined,
                      "Correo",
                      "noreply.mymeal@gmail.com",
                    ),
                    const SizedBox(height: 12),

                    _item(
                      Icons.phone_outlined,
                      "Teléfono",
                      "+57 323 490 0920",
                    ),
                    const SizedBox(height: 12),

                    _item(
                      Icons.access_time_outlined,
                      "Horario",
                      "Lunes a sábado de 8:00 AM a 8:00 PM",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTONES (MEJORADOS)
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
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }
}