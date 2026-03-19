import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codigoController = TextEditingController();
  final PasswordResetService _service = PasswordResetService();
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

  Future<void> _verificarCodigo() async {
    if (_codigoController.text.trim().isEmpty) {
      _mostrarMensaje('Ingresa el código de verificación');
      return;
    }

    setState(() => _loading = true);
    final result = await _service.verificarCodigo(
      widget.email,
      _codigoController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            codigo: _codigoController.text.trim(),
          ),
        ),
      );
    } else {
      _mostrarMensaje(result['error']);
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() => _reenviando = true);
    final result = await _service.solicitarCodigo(widget.email);
    if (!mounted) return;
    setState(() => _reenviando = false);

    if (result['success']) {
      _codigoController.clear();
      _mostrarMensaje('Nuevo código enviado a ${widget.email}', ok: true);
    } else {
      _mostrarMensaje(result['error']);
    }
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
                            'VERIFICAR CÓDIGO',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ingresa el código de 6 dígitos que enviamos a ${widget.email}',
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
                                borderSide: BorderSide(color: Color(0xFFE8651A)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _verificarCodigo,
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
                                      'VERIFICAR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Botón reenviar código
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