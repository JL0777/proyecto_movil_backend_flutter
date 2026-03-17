import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logout_helper.dart';
import 'tabs/pedidos_tab.dart';
import 'tabs/productos_tab.dart';
import 'tabs/ventas_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _tabSeleccionado = 0;

  final List<Widget> _tabs = const [
    PedidosTab(),
    ProductosTab(),
    VentasTab(),
  ];

  final List<String> _titulos = [
    'Pedidos realizados\ny listos',
    'Gestión de\nProductos',
    'Reporte de\nVentas',
  ];

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Column(
        children: [

          SizedBox(
            height: 230,
            child: Stack(
              children: [
                // Imagen de fondo
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // Overlay oscuro
                Positioned.fill(
                  child: Container(
                    color: const Color(0x66000000),
                  ),
                ),

                // Contenido
                SafeArea(
                  child: Stack(
                    children: [
                      // Logo centrado
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

                      // Título y botón logout abajo
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _titulos[_tabSeleccionado],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    LogoutHelper.confirmarCierreSesion(context),
                                child: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 28,
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

          // TABS
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('Pedidos\nRealizados', 0),
                _buildTab('Gestión de\nProductos', 1),
                _buildTab('Reporte de\nVentas', 2),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Expanded(child: _tabs[_tabSeleccionado]),
        ],
      ),
    );
  }

  Widget _buildTab(String titulo, int index) {
    final bool activo = _tabSeleccionado == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabSeleccionado = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: activo ? AppTheme.primaryOrange : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              color: activo ? AppTheme.primaryOrange : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}