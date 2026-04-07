import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../login_screen.dart';
import '../register_screen.dart';

class PreviewPaymentsScreen extends StatefulWidget {
  const PreviewPaymentsScreen({super.key});

  @override
  State<PreviewPaymentsScreen> createState() =>
      _PreviewPaymentsScreenState();
}

class _PreviewPaymentsScreenState extends State<PreviewPaymentsScreen>
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
      appBar: AppBar(title: const Text("Pagos y facturación")),
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
                          ),
                          child: const Icon(
                            Icons.payments_rounded,
                            size: 48,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Información sobre pagos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Aquí podrás conocer los métodos de pago disponibles y cómo funcionan dentro de la app.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _item("Pago con PSE",
                        "Aprende cómo pagar directamente desde tu banco.",
                        'assets/images/pse.png'),
                    _item("Contraentrega",
                        "Conoce cómo funciona el pago en efectivo al recibir.",
                        'assets/images/contraentrega.png'),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Inicia sesión para acceder a la sección donde podrás gestionar tus pagos.",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "INICIAR SESIÓN",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text("Crear cuenta"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String desc, String img) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(img, width: 45),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc),
              ],
            ),
          )
        ],
      ),
    );
  }
}