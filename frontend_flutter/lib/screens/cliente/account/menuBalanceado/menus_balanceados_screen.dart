import 'package:flutter/material.dart';
import '../../../../services/menu_service.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';

class MenusBalanceadosScreen extends StatefulWidget {
  final String? objetivoInicial;

  const MenusBalanceadosScreen({super.key, this.objetivoInicial});

  @override
  State<MenusBalanceadosScreen> createState() => _MenusBalanceadosScreenState();
}

class _MenusBalanceadosScreenState extends State<MenusBalanceadosScreen> {
  final MenuService _menuService = MenuService();
  List<dynamic> _menus = [];
  bool _loading = true;
  String? _objetivoSeleccionado;

  final Map<String, Map<String, dynamic>> _objetivos = {
    'todos': {
      'label': 'Todos',
      'icono': Icons.grid_view_rounded,
      'color': Colors.grey,
    },
    'bajar_peso': {
      'label': 'Bajar peso',
      'icono': Icons.trending_down_rounded,
      'color': Colors.blue,
    },
    'subir_musculo': {
      'label': 'Músculo',
      'icono': Icons.fitness_center_rounded,
      'color': Colors.orange,
    },
    'mantenimiento': {
      'label': 'Mantenimiento',
      'icono': Icons.balance_rounded,
      'color': Colors.green,
    },
    'energia': {
      'label': 'Energía',
      'icono': Icons.bolt_rounded,
      'color': Colors.amber,
    },
    'digestivo': {
      'label': 'Digestivo',
      'icono': Icons.spa_rounded,
      'color': Colors.teal,
    },
  };

  @override
  void initState() {
    super.initState();
    // Si viene con objetivo desde PerfilNutricional, lo preseleccionamos
    _objetivoSeleccionado = widget.objetivoInicial ?? 'todos';
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final objetivo = _objetivoSeleccionado == 'todos'
          ? null
          : _objetivoSeleccionado;
      final menus = await _menuService.getMenusBalanceados(objetivo: objetivo);
      if (mounted) setState(() => _menus = menus);
    } catch (e) {
      debugPrint('Error cargando menús: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Menús Balanceados',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comida según tu objetivo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Menús diseñados para tu salud',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Chips de filtro ──
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      children: _objetivos.entries.map((entry) {
                        final key = entry.key;
                        final data = entry.value;
                        final seleccionado = _objetivoSeleccionado == key;
                        final color = data['color'] as Color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _objetivoSeleccionado = key);
                            _cargar();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: seleccionado
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: seleccionado
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  data['icono'] as IconData,
                                  size: 14,
                                  color: seleccionado ? color : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: seleccionado ? color : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // ── Lista ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
                  )
                : _menus.isEmpty
                ? _sinResultados()
                : RefreshIndicator(
                    onRefresh: _cargar,
                    color: const Color(0xFFE8651A),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _menus.length,
                      itemBuilder: (_, i) => _menuCard(_menus[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(Map<String, dynamic> menu) {
    final objetivo = _objetivos[menu['objetivo']];
    final color = objetivo?['color'] as Color? ?? Colors.grey;
    final precio = double.tryParse(menu['precio'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          if (menu['imagenUrl'] != null &&
              menu['imagenUrl'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                menu['imagenUrl'],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagenPlaceholder(),
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: _imagenPlaceholder(),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + badge objetivo
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        menu['nombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (objetivo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              objetivo['icono'] as IconData,
                              size: 12,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              objetivo['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                if (menu['descripcion'] != null &&
                    menu['descripcion'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    menu['descripcion'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),

                // Macros
                if (menu['calorias'] != null)
                  Row(
                    children: [
                      _macro(
                        Icons.local_fire_department_outlined,
                        '${menu['calorias']} kcal',
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      if (menu['proteinas'] != null)
                        _macro(
                          Icons.fitness_center_outlined,
                          '${menu['proteinas']}g prot',
                          Colors.red,
                        ),
                      const SizedBox(width: 12),
                      if (menu['carbohidratos'] != null)
                        _macro(
                          Icons.grain_outlined,
                          '${menu['carbohidratos']}g carbs',
                          Colors.amber.shade700,
                        ),
                    ],
                  ),

                const SizedBox(height: 10),

                // Precio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${precio.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartProvider>().agregarMenu(menu, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${menu['nombre']} agregado al carrito',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8651A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_shopping_cart_outlined,
                        size: 16,
                      ),
                      label: const Text(
                        'Agregar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macro(IconData icono, String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No hay menús para este objetivo',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otro filtro',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.restaurant_outlined,
        size: 50,
        color: Colors.grey.shade300,
      ),
    );
  }
}
