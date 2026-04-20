import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PaymentsHelpScreen extends StatefulWidget {
  const PaymentsHelpScreen({super.key});

  @override
  State<PaymentsHelpScreen> createState() => _PaymentsHelpScreenState();
}

class _PaymentsHelpScreenState extends State<PaymentsHelpScreen> with TickerProviderStateMixin {
  final List<int> _openItems = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    setState(() {
      _openItems.contains(index)
          ? _openItems.remove(index)
          : _openItems.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          'Pagos y facturación',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            /// HEADER VISUAL
            _buildHeader(),

            const SizedBox(height: 35),

            _sectionTitle("Preguntas frecuentes"),
            const SizedBox(height: 15),

            /// -------------------- METODOS DISPONIBLES --------------------
            _faqItem(
              index: 0,
              question: "¿Qué métodos de pago se pueden usar?",
              icon: Icons.account_balance_wallet_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Actualmente puedes pagar tus pedidos utilizando los siguientes métodos:",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  _paymentItem(
                    title: "Pago con PSE",
                    description:
                        "Realiza pagos directamente desde tu cuenta bancaria de forma segura.",
                    image: 'assets/images/pse.png',
                  ),

                  const SizedBox(height: 12),

                  _paymentItem(
                    title: "Contraentrega",
                    description:
                        "Paga en efectivo al momento de recibir tu pedido. Ideal si prefieres no usar tarjetas.",
                    image: 'assets/images/contraentrega.png',
                  ),
                ],
              ),
            ),

            /// -------------------- DONDE ESCOGER --------------------
            _faqItem(
              index: 1,
              question: "¿Dónde escoger el método de pago?",
              icon: Icons.touch_app_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoStep(
                    "Paso 1", 
                    "Selecciona el método durante el proceso de compra, justo antes de confirmar."
                  ),
                  _infoStep(
                    "Paso 2", 
                    "Después de elegir productos y dirección, verás las opciones disponibles."
                  ),
                  _infoStep(
                    "Paso 3", 
                    "Elige tu preferencia y revisa el resumen final del pedido."
                  ),

                  const SizedBox(height: 20),

                  _imageLabel("Pantalla de selección de pago:"),
                  _buildStyledImage('assets/help/pago_seleccion.png'),

                  const SizedBox(height: 20),

                  _imageLabel("Pantalla de revisión del pedido:"),
                  _buildStyledImage('assets/help/pago_revision.png'),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                // CORRECCIÓN: withValues en lugar de withOpacity
                color: AppTheme.primaryOrange.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // CORRECCIÓN: withValues
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.payments_rounded, size: 40, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Centro de Pagos",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          "Resuelve tus dudas sobre facturación y métodos de pago aceptados",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textGrey, fontSize: 15),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _faqItem({
    required int index,
    required String question,
    required Widget content,
    required IconData icon,
  }) {
    final isOpen = _openItems.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // CORRECCIÓN: withValues
          color: isOpen ? AppTheme.primaryOrange.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN: withValues
            color: isOpen ? AppTheme.primaryOrange.withValues(alpha: 0.05) : const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _toggle(index),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(
              icon, 
              color: isOpen ? AppTheme.primaryOrange : Colors.grey,
              size: 22,
            ),
            title: Text(
              question,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isOpen ? AppTheme.primaryOrange : Colors.black87,
              ),
            ),
            trailing: AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isOpen ? AppTheme.primaryOrange : Colors.grey,
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Column(
                children: [
                  // CORRECCIÓN: withValues
                  Divider(color: Colors.grey.withValues(alpha: 0.1)),
                  const SizedBox(height: 10),
                  content,
                ],
              ),
            ),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _paymentItem({
    required String title,
    required String description,
    required String image,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // CORRECCIÓN: withValues
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
            ),
            child: Image.asset(image, width: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoStep(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step, 
            style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  Widget _imageLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildStyledImage(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // CORRECCIÓN: withValues
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}