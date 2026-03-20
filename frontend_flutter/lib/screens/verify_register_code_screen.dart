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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0x73000000)),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset('assets/images/logo_mymeal.png', width: 750),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VERIFICA TU CORREO',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Enviamos un código de 6 dígitos a ${widget.email}. Ingrésalo para crear tu cuenta.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _codigoController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 12,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Código de verificación',
                              counterText: '',
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFE8651A)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _verificar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8651A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'CREAR CUENTA',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: _reenviando
                                ? const CircularProgressIndicator(
                                    color: Color(0xFFE8651A),
                                  )
                                : GestureDetector(
                                    onTap: _reenviarCodigo,
                                    child: const Text(
                                      '¿No recibiste el código? Reenviar',
                                      style: TextStyle(
                                        color: Color(0xFFE8651A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: GestureDetector(
                              onTap: _cambiarCorreo,
                              child: const Text(
                                '¿Correo equivocado? Usar otro correo',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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