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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
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
      height: 250 + top,
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
        padding: EdgeInsets.fromLTRB(20, top + 6, 20, 8),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/logo_mymeal.png',
              height: 140,
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '¿Que quieres comer\nel dia de hoy?',
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

class _CategoryTabs extends StatelessWidget {
  final TabController controller;

  const _CategoryTabs({required this.controller});

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