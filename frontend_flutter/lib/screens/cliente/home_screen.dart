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

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
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
          colorFilter: ColorFilter.mode(
            Color(0x66000000),
            BlendMode.darken,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 42),
              Flexible( // ← fix del overflow
                child: Image.asset(
                  'assets/images/logo_mymeal.png',
                  height: 170,
                ),
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
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            height: 56,
            child: Text(
              'Comida\ntradicional',
              textAlign: TextAlign.center,
            ),
          ),
          Tab(
            height: 56,
            child: Text(
              'Comida\nRápida',
              textAlign: TextAlign.center,
            ),
          ),
          Tab(
            height: 56,
            child: Text(
              'Bebidas',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}