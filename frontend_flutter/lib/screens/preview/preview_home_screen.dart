import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'preview_traditional_screen.dart';
import 'preview_fastfood_screen.dart';
import 'preview_drinks_screen.dart';
import 'preview_account_screen.dart';

class PreviewHomeScreen extends StatefulWidget {
  const PreviewHomeScreen({super.key});

  @override
  State<PreviewHomeScreen> createState() => _PreviewHomeScreenState();
}

class _PreviewHomeScreenState extends State<PreviewHomeScreen>
    with SingleTickerProviderStateMixin {

  int _bottomIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // ← aviso de bienvenida como invitado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                "¡Bienvenido! Has ingresado como invitado",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryOrange,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomIndex == 0
          ? Column(
              children: [
                const _PreviewHeader(),
                _CategoryTabs(controller: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PreviewTraditionalScreen(),
                      PreviewFastFoodScreen(),
                      PreviewDrinksScreen(),
                    ],
                  ),
                ),
              ],
            )
          : const PreviewAccountScreen(),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomIndex,
          onTap: (i) => setState(() => _bottomIndex = i),
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

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

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
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_mymeal.png',
              height: 170,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Qué quieres',
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

class _CategoryTabs extends StatelessWidget {
  final TabController controller;

  const _CategoryTabs({required this.controller});

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
              'Comida\nTradicional',
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