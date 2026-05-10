import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'cliente/home_screen.dart';
import 'register_screen.dart';

class VerifyRegisterCodeScreen extends StatefulWidget {
  final String email;

  const VerifyRegisterCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyRegisterCodeScreen> createState() =>
      _VerifyRegisterCodeScreenState();
}

class _VerifyRegisterCodeScreenState
    extends State<VerifyRegisterCodeScreen> {
  final _codigoController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  bool _reenviando = false;

  void _mostrarMensaje(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _verificar() async {
    if (_codigoController.text.trim().isEmpty) {
      _mostrarMensaje('Ingresa el código de verificación');
      return;
    }

    setState(() => _loading = true);

    final result = await _authService.verificarRegistro(
      email: widget.email,
      codigo: _codigoController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _mostrarMensaje(
        '¡Cuenta creada exitosamente! Bienvenido a MyMeal 🎉',
        ok: true,
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(email: result['user']['email']),
        ),
        (route) => false,
      );
    } else {
      _mostrarMensaje(result['error']);
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() => _reenviando = true);
    final result = await _authService.reenviarCodigoRegistro(
      email: widget.email,
    );
    if (!mounted) return;
    setState(() => _reenviando = false);

    if (result['success']) {
      _codigoController.clear();
      _mostrarMensaje('Nuevo código enviado a ${widget.email}', ok: true);
    } else {
      _mostrarMensaje(result['error']);
    }
  }

  void _cambiarCorreo() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
      (route) => false,
    );
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

                // Tarjeta blanca
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
                          // Ícono
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
                                Icons.how_to_reg_rounded,
                                color: Color(0xFFE8651A),
                                size: 30,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Título
                          const Center(
                            child: Text(
                              'Verifica tu correo',
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
                          Center(
                            child: Text(
                              'Enviamos un código de 6 dígitos a\n${widget.email}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Label
                          const Text(
                            'Código de verificación',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C0E05),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Campo código
                          TextField(
                            controller: _codigoController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 12,
                              color: Color(0xFF1C0E05),
                            ),
                            decoration: InputDecoration(
                              hintText: '······',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                                letterSpacing: 12,
                                fontSize: 28,
                              ),
                              counterText: '',
                              prefixIcon: const Icon(
                                Icons.pin_rounded,
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

                          // Botón crear cuenta
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _verificar,
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
                                        Icon(Icons.check_circle_rounded,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Crear cuenta',
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

                          const SizedBox(height: 24),

                          // Reenviar código
                          Center(
                            child: _reenviando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFE8651A),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: _reenviarCodigo,
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black45,
                                        ),
                                        children: [
                                          TextSpan(
                                              text:
                                                  '¿No recibiste el código? '),
                                          TextSpan(
                                            text: 'Reenviar',
                                            style: TextStyle(
                                              color: Color(0xFFE8651A),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 14),

                          // Cambiar correo
                          Center(
                            child: GestureDetector(
                              onTap: _cambiarCorreo,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                  children: [
                                    TextSpan(text: '¿Correo equivocado? '),
                                    TextSpan(
                                      text: 'Usar otro correo',
                                      style: TextStyle(
                                        color: Color(0xFF1C0E05),
                                        fontWeight: FontWeight.w600,
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