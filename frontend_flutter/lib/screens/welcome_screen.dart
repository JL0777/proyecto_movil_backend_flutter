import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import '../screens/preview/preview_home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoScale;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _registerFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
        );

    _registerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),

          // Partículas animadas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
              ),
            ),
          ),

          // Anillos de pulso
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) =>
                  CustomPaint(painter: _PulsePainter(_pulseController.value)),
            ),
          ),

          /// 🔥 BOTÓN MODO INVITADO (AGREGADO)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PreviewHomeScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Modo invitado",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo con animación
                FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Anillo exterior
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color.fromARGB(255, 235, 183, 141),
                                  width: 3,
                                ),
                              ),
                            ),
                            // Anillo interior
                            Container(
                              width: 151,
                              height: 151,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color.fromARGB(255, 235, 183, 141),
                                  width: 1,
                                ),
                              ),
                            ),
                            // 4 puntos dorados
                            ...[
                              Alignment.topCenter,
                              Alignment.bottomCenter,
                              Alignment.centerLeft,
                              Alignment.centerRight,
                            ].map(
                              (align) => Align(
                                alignment: align,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 235, 183, 141),
                                  ),
                                ),
                              ),
                            ),
                            // Línea horizontal punteada
                            Positioned(
                              left: 18,
                              right: 18,
                              child: Row(
                                children: List.generate(
                                  16,
                                  (i) => Expanded(
                                    child: Container(
                                      height: 1,
                                      color: i.isEven
                                          ? const Color.fromARGB(255, 153, 151, 150)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // MM + tagline
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'MM',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 64,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF5E6C8),
                                    height: 1,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'MY · MEAL',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFFF5E6C8),
                                    letterSpacing: 5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Botón con animación
                SlideTransition(
                  position: _buttonSlide,
                  child: FadeTransition(
                    opacity: _buttonFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: _AnimatedButton(
                        label: 'Iniciar Sesión',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Registro
                FadeTransition(
                  opacity: _registerFade,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Color(0xFFE8651A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFE8651A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Botón con efecto press animado ---
class _AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedButton({required this.label, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFFE8651A),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8651A).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Iniciar Sesión',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Partículas flotantes ---
class _ParticlePainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles = List.generate(
    35,
    (i) => _Particle(seed: i),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final dy = (p.startY - progress * size.height * p.speed) % size.height;
      final y = dy < 0 ? dy + size.height : dy;
      final paint = Paint()
        ..color = p.isOrange
            ? const Color(0xFFE8651A).withValues(alpha: p.alpha)
            : Colors.white.withValues(alpha: p.alpha);
      canvas.drawCircle(Offset(p.x * size.width, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _Particle {
  final double x, startY, radius, alpha, speed;
  final bool isOrange;

  _Particle({required int seed})
    : x = (seed * 37.7 % 100) / 100,
      startY = (seed * 53.1 % 100) / 100,
      radius = (seed * 17.3 % 25 + 5) / 10,
      alpha = (seed * 11.7 % 40 + 10) / 100,
      speed = (seed * 7.3 % 6 + 2) / 10,
      isOrange = seed % 3 == 0;
}

// --- Anillos de pulso ---
class _PulsePainter extends CustomPainter {
  final double progress;
  _PulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    for (int i = 0; i < 3; i++) {
      final t = ((progress + i / 3) % 1.0);
      final radius = 80.0 + t * 160;
      final opacity = (1.0 - t) * 0.15;
      final paint = Paint()
        ..color = const Color(0xFFE8651A).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) => true;
}
