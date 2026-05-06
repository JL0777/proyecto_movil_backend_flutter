import 'package:flutter/material.dart';
import '../../../../services/menu_service.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';
import 'perfil_nutricional_screen.dart';
import '../../home/widgets/cart_fab.dart';
import '../../../../services/user_service.dart';

class MenusBalanceadosScreen extends StatefulWidget {
  final String? objetivoInicial;

  const MenusBalanceadosScreen({super.key, this.objetivoInicial});

  @override
  State<MenusBalanceadosScreen> createState() => _MenusBalanceadosScreenState();
}

class _MenusBalanceadosScreenState extends State<MenusBalanceadosScreen> {
  final MenuService _menuService = MenuService();
  final UserService _userService = UserService();
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
    _objetivoSeleccionado = widget.objetivoInicial ?? 'todos';
    _cargar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), _verificarPerfil);
    });
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

  Future<void> _verificarPerfil() async {
    try {
      final result = await _userService.getPerfilNutricional();
      final tieneDatos = result['tieneDatos'] ?? false;
      if (!tieneDatos && mounted) {
        _mostrarTipPerfil();
      }
    } catch (e) {
      // si hay error no mostramos nada
    }
  }

  void _mostrarTipPerfil() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: Color(0xFFE8651A),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              const Text(
                '¡Completa tu perfil nutricional!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Descripción
              Text(
                'Para recibir menús personalizados según tu IMC, calorías y objetivo de salud, llena tu perfil nutricional.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Tip flecha apuntando al botón
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8651A).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.north_east, color: Color(0xFFE8651A), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Toca "Mi perfil" en la esquina superior derecha',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8651A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Botones
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilNutricionalScreen(),
                      ),
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
                    'Llenar mi perfil ahora',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Ahora no',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0x66000000),
                  BlendMode.darken,
                ),
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
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PerfilNutricionalScreen(),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.monitor_weight_outlined,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Mi perfil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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
                      itemBuilder: (_, i) => _MenuCard(
                        menu: _menus[i],
                        objetivos: _objetivos,
                        onAgregar: () {
                          context.read<CartProvider>().agregarMenu(
                            _menus[i],
                            1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_menus[i]['nombre']} agregado al carrito',
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
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: const CartFab(),
    );
  }

  Widget _sinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.no_meals_outlined,
              size: 40,
              color: Color(0xFFE8651A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay menús para este objetivo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Prueba con otro filtro',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Card de menú balanceado
// ══════════════════════════════════════════════════════════════

class _MenuCard extends StatefulWidget {
  final Map<String, dynamic> menu;
  final Map<String, Map<String, dynamic>> objetivos;
  final VoidCallback onAgregar;

  const _MenuCard({
    required this.menu,
    required this.objetivos,
    required this.onAgregar,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final objetivo = widget.objetivos[widget.menu['objetivo']];
    final color = objetivo?['color'] as Color? ?? Colors.grey;
    final precio = double.tryParse(widget.menu['precio'].toString()) ?? 0;
    final descripcion = widget.menu['descripcion']?.toString() ?? '';
    final tieneDescripcionLarga = descripcion.length > 80;

    return GestureDetector(
      onTap: () => _mostrarDetalle(context),
      child: Container(
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
            // ── Imagen ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child:
                  widget.menu['imagenUrl'] != null &&
                      widget.menu['imagenUrl'].toString().isNotEmpty
                  ? Image.network(
                      widget.menu['imagenUrl'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nombre + badge ──
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.menu['nombre'] ?? '',
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

                  // ── Descripción con Ver más ──
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                      maxLines: _expandido ? null : 2,
                      overflow: _expandido
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (tieneDescripcionLarga)
                      GestureDetector(
                        onTap: () => setState(() => _expandido = !_expandido),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _expandido ? 'Ver menos' : 'Ver más...',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE8651A),
                            ),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 10),

                  // ── Macros ──
                  if (widget.menu['calorias'] != null)
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _macro(
                          Icons.local_fire_department_outlined,
                          '${widget.menu['calorias']} kcal',
                          Colors.orange,
                        ),
                        if (widget.menu['proteinas'] != null)
                          _macro(
                            Icons.fitness_center_outlined,
                            '${widget.menu['proteinas']}g prot',
                            Colors.red,
                          ),
                        if (widget.menu['carbohidratos'] != null)
                          _macro(
                            Icons.grain_outlined,
                            '${widget.menu['carbohidratos']}g carbs',
                            Colors.amber.shade700,
                          ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  // ── Precio + botón ──
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
                        onPressed: widget.onAgregar,
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
      ),
    );
  }

  // ── Detalle completo ────────────────────────────────────────

  void _mostrarDetalle(BuildContext context) {
    final objetivo = widget.objetivos[widget.menu['objetivo']];
    final color = objetivo?['color'] as Color? ?? Colors.grey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    if (widget.menu['imagenUrl'] != null &&
                        widget.menu['imagenUrl'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          widget.menu['imagenUrl'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Nombre + badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.menu['nombre'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (objetivo != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
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
                                  size: 13,
                                  color: color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  objetivo['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Descripción completa
                    if (widget.menu['descripcion'] != null &&
                        widget.menu['descripcion'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        widget.menu['descripcion'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Macros detallados
                    if (widget.menu['calorias'] != null) ...[
                      const Text(
                        'Información nutricional',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _filaMacro(
                        'Calorías',
                        '${widget.menu['calorias']} kcal',
                        Colors.orange,
                      ),
                      if (widget.menu['proteinas'] != null)
                        _filaMacro(
                          'Proteínas',
                          '${widget.menu['proteinas']}g',
                          Colors.red,
                        ),
                      if (widget.menu['carbohidratos'] != null)
                        _filaMacro(
                          'Carbohidratos',
                          '${widget.menu['carbohidratos']}g',
                          Colors.amber.shade700,
                        ),
                      if (widget.menu['grasas'] != null)
                        _filaMacro(
                          'Grasas',
                          '${widget.menu['grasas']}g',
                          Colors.blue,
                        ),
                    ],

                    const SizedBox(height: 16),

                    // Precio
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Precio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$${double.tryParse(widget.menu['precio'].toString())?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

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

  Widget _filaMacro(String label, String valor, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
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
