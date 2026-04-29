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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
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

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryOrange,
          unselectedItemColor: const Color(0xFFBBBBBB),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.home_outlined, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.home, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.receipt_long_outlined, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.receipt_long, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.person_outline, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.person, size: 28),
              ),
              label: '',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MenusBalanceadosScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8651A),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8651A).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Menús saludables',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCartTap;

  const _Header({required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x66000000), BlendMode.darken),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón búsqueda
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BusquedaScreen()),
                  );
                },
                child: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
              Flexible(
                child: Image.asset(
                  'assets/images/logo_mymeal.png',
                  height: 170,
                ),
              ),
              // Carrito
              Consumer<CartProvider>(
                builder: (context, cart, _) => GestureDetector(
                  onTap: onCartTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      if (cart.totalItems > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
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
          const SizedBox(height: 16),
          const Text(
            '¿Qué deseas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const Text(
            'comer hoy?',
            style: TextStyle(
              color: AppTheme.primaryOrange,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  final TabController controller;

  const _CategoryTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppTheme.primaryOrange,
        unselectedLabelColor: AppTheme.textGrey,
        indicatorColor: AppTheme.primaryOrange,
        indicatorWeight: 3,
        dividerColor: const Color(0xFFEEEEEE),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            height: 56,
            child: Text('Comida\ntradicional', textAlign: TextAlign.center),
          ),
          Tab(
            height: 56,
            child: Text('Comida\nRápida', textAlign: TextAlign.center),
          ),
          Tab(height: 56, child: Text('Bebidas', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
