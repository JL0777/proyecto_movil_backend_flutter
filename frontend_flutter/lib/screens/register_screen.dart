import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'verify_register_code_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  late AnimationController _heroController;
  late AnimationController _cardController;
  late AnimationController _fieldsController;
  late AnimationController _bottomBarController;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _fieldsFade;
  late Animation<Offset> _fieldsSlide;
  late Animation<double> _bottomBarFade;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bottomBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _fieldsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fieldsController, curve: Curves.easeOut),
    );
    _fieldsSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fieldsController, curve: Curves.easeOut),
    );

    _bottomBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bottomBarController, curve: Curves.easeOut),
    );

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bottomBarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _fieldsController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heroController.dispose();
    _cardController.dispose();
    _fieldsController.dispose();
    _bottomBarController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasNumber && hasMinLength;
  }

  Future<void> _registrar() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _mostrarError('Por favor completa todos los campos.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarError('Las contraseñas no coinciden.');
      return;
    }

    if (!_isPasswordStrong(_passwordController.text)) {
      _mostrarError(
        'La contraseña debe tener mínimo 8 caracteres, una mayúscula y un número.',
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      telefono: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerifyRegisterCodeScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      _mostrarError(result['error'] ?? 'Error al registrarse');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = bottomInset > 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight =
        screenHeight - safeAreaTop - safeAreaBottom - bottomInset;
    final heroHeight = keyboardOpen ? 60.0 : screenHeight * 0.28;
    final cardHeight =
        (availableHeight - heroHeight).clamp(300.0, double.infinity);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: Container(color: Colors.black.withValues(alpha: 0.50)),
          ),
          // Barra blanca inferior con animación
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: safeAreaBottom + 10,
            child: FadeTransition(
              opacity: _bottomBarFade,
              child: Container(color: Colors.white),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: heroHeight,
                  child: ClipRect(
                    child: FadeTransition(
                      opacity: _heroFade,
                      child: SlideTransition(
                        position: _heroSlide,
                        child: _buildHeroArea(collapsed: keyboardOpen),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _buildCard(cardHeight: cardHeight),
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

  Widget _buildHeroArea({bool collapsed = false}) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8651A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE8651A).withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8651A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'MYMEAL',
                    style: TextStyle(
                      color: Color(0xFFE8651A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8651A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE8651A).withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8651A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'MYMEAL',
                        style: TextStyle(
                          color: Color(0xFFE8651A),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crea tu\ncuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Regístrate para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required double cardHeight}) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        height: cardHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
          child: FadeTransition(
            opacity: _fieldsFade,
            child: SlideTransition(
              position: _fieldsSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabToggle(),
                  const SizedBox(height: 18),
                  _buildField(
                    label: 'CORREO ELECTRÓNICO',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'TELÉFONO',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixText: '+57 ',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'CONTRASEÑA',
                    icon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    isPassword: true,
                    passwordVisible: _passwordVisible,
                    onTogglePassword: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mínimo 8 caracteres, una mayúscula y un número.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.35),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'CONFIRMAR CONTRASEÑA',
                    icon: Icons.lock_outline_rounded,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    passwordVisible: _confirmPasswordVisible,
                    onTogglePassword: () => setState(
                      () =>
                          _confirmPasswordVisible = !_confirmPasswordVisible,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _RegisterButton(isLoading: _isLoading, onTap: _registrar),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F2),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Text(
                  'INICIAR SESIÓN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBBBBBB),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFE8651A),
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Text(
                'REGISTRARSE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool passwordVisible = false,
    VoidCallback? onTogglePassword,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return _FocusField(
      label: label,
      icon: icon,
      controller: controller,
      isPassword: isPassword,
      passwordVisible: passwordVisible,
      onTogglePassword: onTogglePassword,
      prefixText: prefixText,
      keyboardType: keyboardType,
    );
  }
}

class _FocusField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool passwordVisible;
  final VoidCallback? onTogglePassword;
  final String? prefixText;
  final TextInputType keyboardType;

  const _FocusField({
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.passwordVisible = false,
    this.onTogglePassword,
    this.prefixText,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_FocusField> createState() => _FocusFieldState();
}

class _FocusFieldState extends State<_FocusField>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _borderColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _labelColor;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderColor = ColorTween(
      begin: const Color(0xFFEBEBEB),
      end: const Color(0xFFE8651A),
    ).animate(_ctrl);
    _iconColor = ColorTween(
      begin: const Color(0xFFCCCCCC),
      end: const Color(0xFFE8651A),
    ).animate(_ctrl);
    _labelColor = ColorTween(
      begin: const Color(0xFFBBBBBB),
      end: const Color(0xFFE8651A),
    ).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.3,
                color: _labelColor.value,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _borderColor.value!,
                    width: _focused ? 1.8 : 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: _iconColor.value),
                  const SizedBox(width: 10),
                  if (widget.prefixText != null)
                    Text(
                      widget.prefixText!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF222222),
                      ),
                    ),
                  Expanded(
                    child: Focus(
                      onFocusChange: (f) {
                        setState(() => _focused = f);
                        f ? _ctrl.forward() : _ctrl.reverse();
                      },
                      child: TextField(
                        controller: widget.controller,
                        obscureText:
                            widget.isPassword && !widget.passwordVisible,
                        keyboardType: widget.keyboardType,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  if (widget.isPassword)
                    GestureDetector(
                      onTap: widget.onTogglePassword,
                      child: Icon(
                        widget.passwordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 18,
                        color: _iconColor.value,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RegisterButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _RegisterButton({required this.isLoading, required this.onTap});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFE8651A),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8651A).withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'REGISTRARSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
        ),
      ),
    );
  }
}