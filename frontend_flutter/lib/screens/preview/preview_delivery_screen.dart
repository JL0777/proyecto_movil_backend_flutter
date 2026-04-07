import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../login_screen.dart';
import '../register_screen.dart';

class PreviewDeliveryScreen extends StatefulWidget {
  const PreviewDeliveryScreen({super.key});

  @override
  State<PreviewDeliveryScreen> createState() =>
      _PreviewDeliveryScreenState();
}

class _PreviewDeliveryScreenState extends State<PreviewDeliveryScreen>
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
      appBar: AppBar(title: const Text("Entregas y direcciones")),
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
                    // HEADER
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
                            Icons.local_shipping_rounded,
                            size: 48,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Información sobre entregas",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Aquí encontrarás información sobre direcciones, cobertura y tiempos de entrega.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _item(Icons.location_on, "Direcciones",
                        "Aprende cómo agregar y usar direcciones."),
                    _item(Icons.timer, "Tiempos de entrega",
                        "Consulta información sobre tiempos estimados."),
                    _item(Icons.map, "Cobertura",
                        "Cómo verificar si el servicio llega a tu zona."),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Inicia sesión para acceder a la sección donde podrás gestionar tus direcciones.",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          _buttons(context),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _item(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryOrange),
        title: Text(title),
        subtitle: Text(desc),
      ),
    );
  }
}