import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final PasswordResetService _service = PasswordResetService();
  bool _loading = false;

  void _mostrarMensaje(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _enviarCodigo() async {
    if (_emailController.text.trim().isEmpty) {
      _mostrarMensaje('Ingresa tu correo electrónico');
      return;
    }
    setState(() => _loading = true);
    final result = await _service.solicitarCodigo(_emailController.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      _mostrarMensaje(result['error']);
    }
  }

  Widget _buildLogo() {
    const double size = 140;
    const Color gold = Color(0xFFC97A3A);
    const Color cream = Color(0xFFF5E6C8);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 2.5),
            ),
          ),
          Container(
            width: size * 0.84,
            height: size * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 0.8),
            ),
          ),
          ...[
            Alignment.topCenter,
            Alignment.bottomCenter,
            Alignment.centerLeft,
            Alignment.centerRight,
          ].map((align) => Align(
                alignment: align,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: gold,
                  ),
                ),
              )),
          Positioned(
            left: size * 0.1,
            right: size * 0.1,
            child: Row(
              children: List.generate(
                14,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i.isEven ? gold : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'MM',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: cream,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'MY · MEAL',
                style: TextStyle(
                  fontSize: 7,
                  color: gold,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C0E05),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Overlay oscuro
          Positioned.fill(
            child: Container(color: const Color(0xAA1C0E05)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Botón atrás
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 12),

                // Logo MM
                _buildLogo(),

                const SizedBox(height: 28),

                // Tarjeta blanca que ocupa el resto
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ícono candado
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0E6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE8651A),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                color: Color(0xFFE8651A),
                                size: 30,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Título centrado
                          const Center(
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C0E05),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Descripción
                          const Center(
                            child: Text(
                              'Ingresa tu correo y te enviaremos\nun código de verificación.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Label correo
                          const Text(
                            'Correo electrónico',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C0E05),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Campo email mejorado
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'tucorreo@ejemplo.com',
                              hintStyle:
                                  const TextStyle(color: Colors.black26),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFFE8651A),
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAF7F4),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEAE0D6),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE8651A),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Botón enviar
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _enviarCodigo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8651A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Enviar código',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
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
}