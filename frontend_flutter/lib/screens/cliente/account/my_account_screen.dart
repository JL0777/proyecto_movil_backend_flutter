import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/utils/logout_helper.dart';
import 'edit_profile_screen.dart';
import 'my_addresses_screen.dart';
import 'help_screen.dart';

class MyAccountScreen extends StatefulWidget {
  final String email;

  const MyAccountScreen({super.key, required this.email});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUser();
    setState(() {
      user = u;
    });
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      _loadUser();
    });
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primaryOrange,
    Color iconBg = AppTheme.lightOrange,
    Color titleColor = const Color(0xFF1A1A1A),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.lightOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.chevron_right,
            color: AppTheme.primaryOrange,
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = user?["email"] ?? widget.email;
    final nombre = user?["nombre"] ?? "";

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
                if (nombre.isNotEmpty) ...[
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _menuItem(
            icon: Icons.person_outline,
            title: "Editar información personal",
            onTap: () => _navigate(context, const EditProfileScreen()),
          ),
          _menuItem(
            icon: Icons.location_on_outlined,
            title: "Mis direcciones",
            onTap: () => _navigate(context, MyAddressesScreen()),
          ),
          _menuItem(
            icon: Icons.help_outline,
            title: "Ayuda",
            onTap: () => _navigate(context, const HelpScreen()),
          ),
          _menuItem(
            icon: Icons.logout,
            title: "Cerrar sesión",
            iconColor: Colors.red,
            iconBg: const Color(0xFFFEF2F2),
            titleColor: Colors.red,
            onTap: () => LogoutHelper.confirmarCierreSesion(context),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}