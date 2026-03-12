import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/session/session_manager.dart';

import 'screens/preview/splash_screen.dart';
import 'screens/preview/preview_home_screen.dart';
import 'screens/cliente/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/cocina/cocina_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final token = await SessionManager.getToken();

    if (token == null) {
      return const PreviewHomeScreen();
    }

    final user = await SessionManager.getUser();

    if (user == null) {
      return const PreviewHomeScreen();
    }

    final rol = user['rol'];

    if (rol == 'admin') {
      return AdminHomeScreen(user: user);
    } 
    else if (rol == 'cocinero') {
      return CocinaHomeScreen(user: user);
    } 
    else {
      return HomeScreen(email: user['email']);
    }
  }

  @override
  Widget build(BuildContext context) {

    final Future<Widget> initial = _getInitialScreen();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      routes: {
        '/home': (context) {
          return FutureBuilder<Widget>(
            future: initial,
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return snapshot.data!;
            },
          );
        }
      },

      home: const SplashScreen(),
    );
  }
}