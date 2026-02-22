import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'home/traditional_food_screen.dart';
import 'home/fast_food_screen.dart';
import 'home/drinks_screen.dart';
import 'orders/my_orders_screen.dart';
import 'account/my_account_screen.dart';
import 'home/widgets/cart_modal.dart';

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
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: ''),
        ],
      ),
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
      height: 250 + statusBarHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, statusBarHeight + 6, 20, 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 42),
                Image.asset(
                  'assets/images/logo_mymeal.png',
                  height: 140,
                ),
                GestureDetector(
                  onTap: onCartTap,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '¿Qué deseas comer\nel día de hoy?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  final TabController controller;

  const _CategoryTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: AppTheme.primaryOrange,
      unselectedLabelColor: AppTheme.textGrey,
      indicatorColor: AppTheme.primaryOrange,
      tabs: const [
        Tab(text: 'Comida\ntradicional'),
        Tab(text: 'Comida\nRápida'),
        Tab(text: 'Bebidas'),
      ],
    );
  }
}