import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/session/session_manager.dart';
import '../../welcome_screen.dart';
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
    ).then((_) {
      _loadUser();
    });

  }

  @override
  Widget build(BuildContext context) {

    final email = user?["email"] ?? widget.email;

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

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Editar información personal"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(
              context,
              const EditProfileScreen(),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Mis direcciones"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(
              context,
              MyAddressesScreen(),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Ayuda"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(
              context,
              HelpScreen(),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Cerrar sesión"),
            onTap: () => _logout(context),
          ),

          const SizedBox(height: 40),

        ],

      ),

    );

  }

}