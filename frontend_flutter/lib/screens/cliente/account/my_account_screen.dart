import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/session/session_manager.dart';
import '../../welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'my_addresses_screen.dart';
import 'help_screen.dart';

class MyAccountScreen extends StatelessWidget {
  final String email;

  const MyAccountScreen({super.key, required this.email});

  Future<void> _logout(BuildContext context) async {
    await SessionManager.clearSession();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.lightOrange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryOrange,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Divider(),

          _AccountTile(
            icon: Icons.person_outline,
            label: 'Editar información personal',
            onTap: () => _navigate(context, EditProfileScreen()),
          ),

          _AccountTile(
            icon: Icons.location_on_outlined,
            label: 'Mis direcciones',
            onTap: () => _navigate(context, MyAddressesScreen()),
          ),

          _AccountTile(
            icon: Icons.help_outline,
            label: 'Ayuda',
            onTap: () => _navigate(context, HelpScreen()),
          ),

          const Divider(),

          _AccountTile(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            color: Colors.red,
            onTap: () => _logout(context),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textDark;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: c),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: c,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}