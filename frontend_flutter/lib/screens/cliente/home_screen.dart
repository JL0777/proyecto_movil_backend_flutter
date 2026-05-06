import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/cart_provider.dart';
import '../../services/notificacion_service.dart';
import 'home/traditional_food_screen.dart';
import 'home/fast_food_screen.dart';
import 'home/drinks_screen.dart';
import 'orders/my_orders_screen.dart';
import 'account/my_account_screen.dart';
import 'home/widgets/cart_modal.dart';
import 'home/widgets/cart_fab.dart';
import 'home/busqueda_screen.dart';
import 'account/menuBalanceado/menus_balanceados_screen.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificacionService().iniciar(context);
      _mostrarBannerBalanceados();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    NotificacionService().detener();
    super.dispose();
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CartModal(),
    );
  }

  void _goToMenusBalanceados() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MenusBalanceadosScreen()),
    );
  }

  void _mostrarBannerBalanceados() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _goToMenusBalanceados();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Parte superior naranja con texto
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'VISITA NUESTROS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'MENÚS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'BALANCEADOS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Imagen
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/balanceados.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Parte inferior blanca
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      color: Colors.white,
                      child: Column(
                        children: [
                          const Text(
                            'DELICIOSO, SALUDABLE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'Y A TU PUERTA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _goToMenusBalanceados();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8651A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                              child: const Text(
                                'Ver menús saludables',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón X
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: _currentIndex == 0
          ? Column(
              children: [
                _Header(onCartTap: _openCart),
                _CategoryTabBar(controller: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      TraditionalFoodScreen(),
                      FastFoodScreen(),
                      DrinksScreen(),
                    ],
                  ),
                ),
              ],
            )
          : _currentIndex == 1
          ? const MyOrdersScreen()
          : MyAccountScreen(email: widget.email),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
      floatingActionButton: _currentIndex == 0
          ? _MenusBalanceadosFab(onTap: _goToMenusBalanceados)
          : const CartFab(),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onCartTap;
  const _Header({required this.onCartTap});

  static const _primary = Color(0xFFE8651A);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x66000000), BlendMode.darken),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior
          Row(
            children: [
              _IconButton(
                icon: Icons.search_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusquedaScreen()),
                ),
              ),
              const Spacer(),
              // Logo pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primary.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.restaurant_menu_rounded,
                      color: _primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'MyMeal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Consumer<CartProvider>(
                builder: (_, cart, _) => GestureDetector(
                  onTap: onCartTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _IconButton(
                        icon: Icons.shopping_cart_outlined,
                        onTap: onCartTap,
                      ),
                      if (cart.totalItems > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${cart.totalItems}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Saludo
          Text(
            'Bienvenido de nuevo 👋',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          // Cambia el fontSize fijo por uno adaptativo
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '¿Qué deseas\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        MediaQuery.of(context).size.width * 0.062, // adaptativo
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                TextSpan(
                  text: 'comer hoy?',
                  style: TextStyle(
                    color: _primary,
                    fontSize: MediaQuery.of(context).size.width * 0.062,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Barra de búsqueda decorativa
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BusquedaScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Busca tu plato favorito...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Icon button helper ──────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _CategoryTabBar extends StatelessWidget {
  final TabController controller;
  const _CategoryTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: const Color(0xFFE8651A),
        unselectedLabelColor: AppTheme.textGrey,
        indicatorColor: const Color(0xFFE8651A),
        indicatorWeight: 2.5,
        dividerColor: const Color(0xFFEEEEEE),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            height: 52,
            icon: Icon(Icons.restaurant_outlined, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'Tradicional',
          ),
          Tab(
            height: 52,
            icon: Icon(Icons.fastfood_outlined, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'Rápida',
          ),
          Tab(
            height: 52,
            icon: Icon(Icons.local_drink_outlined, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'Bebidas',
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Nav ──────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFE8651A),
        unselectedItemColor: const Color(0xFFCCCCCC),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.home_outlined, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.home_rounded, size: 26),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.receipt_long_outlined, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.receipt_long_rounded, size: 26),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.person_outline_rounded, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.person_rounded, size: 26),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

// ─── FAB Menús Balanceados ───────────────────────────────────────────────────

class _MenusBalanceadosFab extends StatelessWidget {
  final VoidCallback onTap;
  const _MenusBalanceadosFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8651A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8651A).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined, color: Color(0xFFE8651A), size: 16),
            SizedBox(width: 6),
            Text(
              'Menús saludables',
              style: TextStyle(
                color: Color(0xFFE8651A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
