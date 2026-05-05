import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
// Asegúrate de importar correctamente la ruta de tu pantalla de perfil nutricional:
import '../menuBalanceado/perfil_nutricional_screen.dart';

class ImcHelpScreen extends StatefulWidget {
  const ImcHelpScreen({super.key});

  @override
  State<ImcHelpScreen> createState() => _ImcHelpScreenState();
}

class _ImcHelpScreenState extends State<ImcHelpScreen> with TickerProviderStateMixin {
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
          'Calculadora IMC',
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

            _sectionTitle("Guía de cálculo"),
            const SizedBox(height: 15),

            /// -------------------- ¿POR QUÉ EL IMC? --------------------
            _faqItem(
              index: 0,
              question: "¿Por qué calculamos tu IMC?",
              icon: Icons.info_outline_rounded,
              content: const Text(
                "El Índice de Masa Corporal (IMC) nos permite conocer tu estado nutricional actual. Al registrarlo, podemos recomendarte menús saludables que se ajusten a tus necesidades calóricas y objetivos personales de salud.",
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ),

            /// -------------------- PASO A PASO --------------------
            _faqItem(
              index: 1,
              question: "¿Cómo calculo correctamente mi IMC?",
              icon: Icons.calculate_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sigue estos pasos para obtener un resultado preciso:",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  
                  // PASO 1 CON HIPERVÍNCULO
                  _infoStepRich(
                    "Paso 1", 
                    [
                      const TextSpan(text: "Ir a la "),
                      TextSpan(
                        text: "sección de Cacular IMC", 
                        style: const TextStyle(
                          color: AppTheme.primaryOrange, 
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PerfilNutricionalScreen()),
                          );
                        },
                      ),
                      const TextSpan(text: " que encontramos en la sección "),
                      const TextSpan(
                        text: "Mi account", 
                        style: TextStyle(
                          color: AppTheme.primaryOrange, 
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const TextSpan(text: "."),
                    ]
                  ),
                  _imageLabel("Imagen 0:"),
                  _buildStyledImage('assets/help/imc_paso0.png'),
                  const SizedBox(height: 20),

                  _infoStep("Paso 2", "Ingresar nuestro peso en kilogramos (se recomienda en ayunas), ingresar nuestra altura en centímetros y nuestra edad."),
                  _imageLabel("Foto 1:"),
                  _buildStyledImage('assets/help/imc_paso1.png'),
                  const SizedBox(height: 20),

                  _infoStep("Paso 3", "Ingresar el sexo biológico."),
                  _imageLabel("Foto 2:"),
                  _buildStyledImage('assets/help/imc_paso2.png'),
                  const SizedBox(height: 20),

                  _infoStep("Paso 4", "Escoger qué nivel de actividad en estilo de vida se lleva al momento (mira bien la imagen 3 que ahí están bien explicados todos)."),
                  _imageLabel("Imagen 3:"),
                  _buildStyledImage('assets/help/imc_paso3.png'),
                  const SizedBox(height: 20),

                  _infoStep("Paso 5", "Darle al botón de calcular para hacer el cálculo."),
                  _imageLabel("Imagen 4:"),
                  _buildStyledImage('assets/help/imc_paso4.png'),
                  const SizedBox(height: 20),

                  _infoStep("Paso 6", "Revisar qué resultado nos dio según el cálculo para mirar qué menús saludables son los más recomendados."),
                  _imageLabel("Imagen 5:"),
                  _buildStyledImage('assets/help/imc_paso5.png'),
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
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.monitor_weight_rounded, size: 40, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Tu Salud Primero",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          "Entiende cómo tus datos nos ayudan a personalizar tu nutrición",
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

  Widget _faqItem({required int index, required String question, required Widget content, required IconData icon}) {
    final isOpen = _openItems.contains(index);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOpen ? AppTheme.primaryOrange.withValues(alpha: 0.3) : const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: isOpen ? AppTheme.primaryOrange.withValues(alpha: 0.05) : const Color(0x05000000), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _toggle(index),
            leading: Icon(icon, color: isOpen ? AppTheme.primaryOrange : Colors.grey, size: 22),
            title: Text(question, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isOpen ? AppTheme.primaryOrange : Colors.black87)),
            trailing: Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isOpen ? AppTheme.primaryOrange : Colors.grey),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey.withValues(alpha: 0.1)), 
                  const SizedBox(height: 10), 
                  content
                ]
              ),
            ),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
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
          Text(step, style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  Widget _infoStepRich(String step, List<TextSpan> textSpans) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step, style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                children: textSpans,
              ),
            ),
          ),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}