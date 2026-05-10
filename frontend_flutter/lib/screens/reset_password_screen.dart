import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import 'welcome_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String codigo;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.codigo,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final PasswordResetService _service = PasswordResetService();
  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  void _mostrarMensaje(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
  }

  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasNumber && hasMinLength;
  }

  Future<void> _cambiarPassword() async {
    if (_passwordController.text.trim().isEmpty ||
        _confirmController.text.trim().isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    if (_passwordController.text.trim() != _confirmController.text.trim()) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    if (!_isPasswordStrong(_passwordController.text.trim())) {
      _mostrarMensaje(
        'La contraseña debe tener mínimo 8 caracteres, una mayúscula y un número.',
      );
      return;
    }

    setState(() => _loading = true);
    final result = await _service.cambiarPassword(
      widget.email,
      widget.codigo,
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _mostrarMensaje('Contraseña actualizada correctamente', ok: true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C0E05),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Colors.black26),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFE8651A),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                visible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: Colors.black38,
                size: 20,
              ),
              onPressed: onToggle,
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
      ],
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
                                Icons.lock_open_rounded,
                                color: Color(0xFFE8651A),
                                size: 30,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Título
                          const Center(
                            child: Text(
                              'Nueva contraseña',
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
                              'Mínimo 8 caracteres,\nuna mayúscula y un número.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Campo nueva contraseña
                          _buildPasswordField(
                            controller: _passwordController,
                            label: 'Nueva contraseña',
                            visible: _passwordVisible,
                            onToggle: () => setState(
                                () => _passwordVisible = !_passwordVisible),
                          ),

                          const SizedBox(height: 20),

                          // Campo confirmar contraseña
                          _buildPasswordField(
                            controller: _confirmController,
                            label: 'Confirmar contraseña',
                            visible: _confirmVisible,
                            onToggle: () => setState(
                                () => _confirmVisible = !_confirmVisible),
                          ),

                          const SizedBox(height: 32),

                          // Botón guardar
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _cambiarPassword,
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
                                        Icon(Icons.save_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Guardar contraseña',
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