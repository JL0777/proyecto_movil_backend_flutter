import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logout_helper.dart';
import 'tabs/pedidos_tab.dart';
import 'tabs/productos_tab.dart';
import 'tabs/ventas_tab.dart';
import 'tabs/usuarios_tab.dart';
import 'tabs/categorias_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _seccionActual = 0;

  final List<String> _titulos = [
    'Pedidos realizados\ny listos',
    'Gestión de\nProductos',
    'Reporte de\nVentas',
    'Gestión de\nUsuarios',
    'Gestión de\nCategorías',
  ];

  Widget _getSeccion() {
    switch (_seccionActual) {
      case 0:
        return const PedidosTab();
      case 1:
        return const ProductosTab();
      case 2:
        return const VentasTab();
      case 3:
        return const UsuariosTab();
      case 4:
        return const CategoriasTab();
      default:
        return const PedidosTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      drawer: _AdminDrawer(
        seccionActual: _seccionActual,
        user: widget.user,
        onSeccionSeleccionada: (index) {
          setState(() => _seccionActual = index);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          SizedBox(
            height: 230,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned.fill(
                  child: Container(color: const Color(0x66000000)),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Image.asset(
                            'assets/images/logo_mymeal.png',
                            width: 200,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Builder(
                                builder: (context) => GestureDetector(
                                  onTap: () =>
                                      Scaffold.of(context).openDrawer(),
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _titulos[_seccionActual],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    LogoutHelper.confirmarCierreSesion(
                                        context),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(child: _getSeccion()),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final int seccionActual;
  final Map<String, dynamic> user;
  final Function(int) onSeccionSeleccionada;

  const _AdminDrawer({
    required this.seccionActual,
    required this.user,
    required this.onSeccionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0x66000000),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user['nombre'] ?? 'Administrador',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerItem(
            context: context,
            icon: Icons.receipt_long_outlined,
            titulo: 'Pedidos realizados',
            index: 0,
          ),
          _drawerItem(
            context: context,
            icon: Icons.fastfood_outlined,
            titulo: 'Gestión de productos',
            index: 1,
          ),
          _drawerItem(
            context: context,
            icon: Icons.bar_chart_outlined,
            titulo: 'Reporte de ventas',
            index: 2,
          ),
          _drawerItem(
            context: context,
            icon: Icons.people_outline,
            titulo: 'Gestión de usuarios',
            index: 3,
          ),
          _drawerItem(
            context: context,
            icon: Icons.category_outlined,
            titulo: 'Gestión de categorías',
            index: 4,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  LogoutHelper.confirmarCierreSesion(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String titulo,
    required int index,
  }) {
    final bool activo = seccionActual == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: activo
            ? AppTheme.primaryOrange.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: activo ? AppTheme.primaryOrange : Colors.grey.shade600,
          size: 24,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
            color: activo ? AppTheme.primaryOrange : Colors.black87,
          ),
        ),
        trailing: activo
            ? Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
        onTap: () => onSeccionSeleccionada(index),
      ),
    );
  }
}