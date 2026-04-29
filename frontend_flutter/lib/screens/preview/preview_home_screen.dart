import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'preview_traditional_screen.dart';
import 'preview_fastfood_screen.dart';
import 'preview_drinks_screen.dart';
import 'preview_account_screen.dart';
import '../login_screen.dart';

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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

  void _mostrarDialogRegistro(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu_outlined,
                  color: Color(0xFFE8651A),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              const Text(
                'Menús Saludables',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                'Regístrate o inicia sesión para acceder a menús personalizados según tu IMC y objetivo de salud.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Beneficios
              _beneficio(
                Icons.monitor_weight_outlined,
                'Calcula tu IMC y calorías diarias',
                Colors.blue,
              ),
              _beneficio(
                Icons.fitness_center_rounded,
                'Menús según tu objetivo de salud',
                Colors.orange,
              ),
              _beneficio(
                Icons.trending_down_rounded,
                'Bajar peso, subir músculo y más',
                Colors.green,
              ),

              const SizedBox(height: 20),

              // Botón registrarse
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8651A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Registrarme ahora',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón cancelar
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Seguir como invitado',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _beneficio(IconData icono, String texto, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _bottomIndex == 0
          ? GestureDetector(
              onTap: () => _mostrarDialogRegistro(context),
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
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
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
          colorFilter: ColorFilter.mode(Color(0x66000000), BlendMode.darken),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset('assets/images/logo_mymeal.png', height: 170),
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
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            height: 56,
            child: Text('Comida\nTradicional', textAlign: TextAlign.center),
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
