import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _dotsController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring2Scale;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _ring1Scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _ring2Scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _iniciarSecuencia();
  }

  Future<void> _iniciarSecuencia() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    const double size = 220;
    const Color gold = Color(0xFFC97A3A);
    const Color cream = Color(0xFFF5E6C8);

    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo exterior
                  Transform.scale(
                    scale: _ring1Scale.value,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 3),
                      ),
                    ),
                  ),

                  // Anillo interior
                  Transform.scale(
                    scale: _ring2Scale.value,
                    child: Container(
                      width: size * 0.84,
                      height: size * 0.84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 1),
                      ),
                    ),
                  ),

                  // 4 puntos decorativos
                  ...[
                    Alignment.topCenter,
                    Alignment.bottomCenter,
                    Alignment.centerLeft,
                    Alignment.centerRight,
                  ].map(
                    (align) => Align(
                      alignment: align,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: gold,
                        ),
                      ),
                    ),
                  ),

                  // Línea horizontal punteada
                  Positioned(
                    left: size * 0.1,
                    right: size * 0.1,
                    child: Row(
                      children: List.generate(18, (i) => Expanded(
                        child: Container(
                          height: 1,
                          color: i.isEven ? gold : Colors.transparent,
                        ),
                      )),
                    ),
                  ),

                  // MM y tagline
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'MM',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 78,
                          fontWeight: FontWeight.w700,
                          color: cream,
                          height: 1,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MY · MEAL',
                        style: TextStyle(
                          fontSize: 9,
                          color: gold,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo: tu imagen background.png
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Overlay oscuro para que el logo resalte
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC1C0E05),
                    Color(0xEE1C0E05),
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo MM
                _buildLogo(),

                const SizedBox(height: 32),

                // Nombre
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) => FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  ),
                  child: const Text(
                    'My Meal',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF5E6C8),
                      letterSpacing: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    'Tu comida, a tu manera',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xAAF5E6C8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Puntos de carga
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: AnimatedBuilder(
                    animation: _dotsController,
                    builder: (context, _) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final delay = i * 0.3;
                        final val =
                            (_dotsController.value - delay).clamp(0.0, 1.0);
                        final opacity =
                            (val < 0.5 ? val * 2 : (1 - val) * 2)
                                .clamp(0.3, 1.0);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFC97A3A)
                                .withValues(alpha: opacity),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}