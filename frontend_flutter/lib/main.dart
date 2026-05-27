import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/session/session_manager.dart';
import 'core/providers/cart_provider.dart';

import 'screens/preview/splash_screen.dart';
import 'screens/preview/preview_home_screen.dart';
import 'screens/cliente/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/cocina/cocina_home_screen.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  await NotificationService().inicializar();

  // Solicitar permisos en iOS al arrancar
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await NotificationService().pedirPermisos();
  }

  try {
    await http
        .get(Uri.parse('https://mymeal-backend-bncr.onrender.com/'))
        .timeout(Duration(seconds: 60));
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final token = await SessionManager.getToken();
    if (token == null) return const PreviewHomeScreen();

    final user = await SessionManager.getUser();
    if (user == null) return const PreviewHomeScreen();

    final rol = user['rol'];
    if (rol == 'admin') return AdminHomeScreen(user: user);
    if (rol == 'cocinero') return CocinaHomeScreen(user: user);
    return HomeScreen(email: user['email']);
  }

  @override
  Widget build(BuildContext context) {
    final Future<Widget> initial = _getInitialScreen();

    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        builder: (context, child) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          );
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                mediaQuery.textScaleFactor.clamp(0.85, 1.15),
              ),
            ),
            child: child!,
          );
        },
        routes: {
          '/home': (context) => FutureBuilder<Widget>(
            future: initial,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data!;
            },
          ),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
