import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFE8760A);
  static const Color lightOrange   = Color(0xFFFFF3E8);
  static const Color lightGrey     = Color(0xFFF7F7F7);
  static const Color textDark      = Color(0xFF1A1A1A);
  static const Color textGrey      = Color(0xFF888888);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryOrange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Color(0xFFBBBBBB),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: primaryOrange,
          unselectedLabelColor: Color(0xFF888888),
          indicatorColor: primaryOrange,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}