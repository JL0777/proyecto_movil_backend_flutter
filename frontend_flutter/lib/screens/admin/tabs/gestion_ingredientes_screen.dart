import 'package:flutter/material.dart';
import '../../../services/ingrediente_service.dart';

class GestionIngredientesScreen extends StatefulWidget {
  const GestionIngredientesScreen({super.key});

  @override
  State<GestionIngredientesScreen> createState() =>
      _GestionIngredientesScreenState();
}

class _GestionIngredientesScreenState extends State<GestionIngredientesScreen>
    with SingleTickerProviderStateMixin {
  final IngredienteService _service = IngredienteService();

  List<dynamic> _ingredientes = [];
  bool _loading = true;
  late TabController _tabController;

  String? _filtroTradicional;
  String? _filtroRapida;
  String? _filtroComunes;

  final List<String> _tiposTradicional = [
    'proteina',
    'legumbre',
    'carbohidrato',
    'vegetal',
  ];

  final List<String> _tiposRapida = [
    'pan',
    'proteina',
    'salsa',
    'vegetal',
    'extra',
  ];

  final List<String> _tiposComunes = [
    'bebida',
    'complemento',
  ];

  final List<String> _todosLosTipos = [
    'proteina',
    'legumbre',
    'carbohidrato',
    'vegetal',
    'bebida',
    'complemento',
    'pan',
    'salsa',
    'extra',
  ];

  final Map<String, String> _labelTipo = {
    'proteina': 'Proteína',
    'legumbre': 'Legumbre',
    'carbohidrato': 'Carbohidrato',
    'vegetal': 'Vegetal',
    'bebida': 'Bebida',
    'complemento': 'Complemento',
    'pan': 'Pan',
    'salsa': 'Salsa',
    'extra': 'Extra',
  };

  final Map<String, Color> _coloresTipo = {
    'proteina': Colors.orange,
    'legumbre': Colors.green,
    'carbohidrato': Colors.amber,
    'vegetal': Colors.teal,
    'bebida': Colors.blue,
    'complemento': Colors.purple,
    'pan': Colors.brown,
    'salsa': Colors.red,
    'extra': Colors.indigo,
  };

  final Map<String, IconData> _iconosTipo = {
    'proteina': Icons.egg_outlined,
    'legumbre': Icons.spa_outlined,
    'carbohidrato': Icons.grain_outlined,
    'vegetal': Icons.eco_outlined,
    'bebida': Icons.local_drink_outlined,
    'complemento': Icons.add_circle_outline,
    'pan': Icons.breakfast_dining_outlined,
    'salsa': Icons.water_drop_outlined,
    'extra': Icons.stars_outlined,
  };

  List<dynamic> _ingredientesFiltrados(int tabIndex) {
    List<String> tipos;
    String? filtro;

    if (tabIndex == 0) {
      tipos = _tiposTradicional;
      filtro = _filtroTradicional;
    } else if (tabIndex == 1) {
      tipos = _tiposRapida;
      filtro = _filtroRapida;
    } else {
      tipos = _tiposComunes;
      filtro = _filtroComunes;
    }

    final base =
        _ingredientes.where((i) => tipos.contains(i['tipo'])).toList();

    if (filtro != null) {
      return base.where((i) => i['tipo'] == filtro).toList();
    }

    return base;
  }

  List<String> _tiposPorTab(int tabIndex) {
    if (tabIndex == 0) return _tiposTradicional;
    if (tabIndex == 1) return _tiposRapida;
    return _tiposComunes;
  }

  String? _filtroActual(int tabIndex) {
    if (tabIndex == 0) return _filtroTradicional;
    if (tabIndex == 1) return _filtroRapida;
    return _filtroComunes;
  }

  void _setFiltro(int tabIndex, String? valor) {
    setState(() {
      if (tabIndex == 0) _filtroTradicional = valor;
      if (tabIndex == 1) _filtroRapida = valor;
      if (tabIndex == 2) _filtroComunes = valor;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getAll();
      setState(() {
        _ingredientes = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? ingrediente}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _IngredienteFormPage(
          ingrediente: ingrediente,
          tiposPorTab: _tiposPorTab(_tabController.index),
          todosLosTipos: _todosLosTipos,
          labelTipo: _labelTipo,
          coloresTipo: _coloresTipo,
          iconosTipo: _iconosTipo,
          service: _service,
          onSaved: _cargar,
        ),
      ),
    );
  }

  Future<void> _eliminar(Map<String, dynamic> ingrediente) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('Eliminar ingrediente')),
          ],
        ),
        content: Text('¿Eliminar "${ingrediente['nombre']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await _service.delete(ingrediente['id']);

    if (ok) {
      _cargar();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Ingrediente eliminado correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Widget _buildSelect(int tabIndex) {
    final tipos = _tiposPorTab(tabIndex);
    final filtroActual = _filtroActual(tabIndex);
    final lista = _ingredientesFiltrados(tabIndex);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: filtroActual,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFFE8651A)),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos los tipos'),
                  ),
                  ...tipos.map((t) => DropdownMenuItem<String?>(
                        value: t,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _coloresTipo[t] ?? Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_labelTipo[t] ?? t),
                          ],
                        ),
                      )),
                ],
                onChanged: (v) => _setFiltro(tabIndex, v),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${lista.length} ingrediente${lista.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (filtroActual != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _setFiltro(tabIndex, null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8651A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Limpiar filtro',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE8651A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.close, size: 12, color: Color(0xFFE8651A)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLista(int tabIndex) {
    final lista = _ingredientesFiltrados(tabIndex);

    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood_outlined,
                size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No hay ingredientes aquí',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca + para agregar uno',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: const Color(0xFFE8651A),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: lista.length,
        itemBuilder: (ctx, index) {
          final ing = lista[index];
          final precio = double.parse(ing['precio'].toString());
          final cantidad = ing['cantidad'] != null
              ? double.parse(ing['cantidad'].toString())
              : 0.0;
          final color = _coloresTipo[ing['tipo']] ?? Colors.grey;
          final precioPorGramo = cantidad > 0 ? precio / cantidad : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant_outlined,
                    color: color, size: 22),
              ),
              title: Text(
                ing['nombre'],
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Base: ${cantidad.toStringAsFixed(0)}g/ml',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _labelTipo[ing['tipo']] ?? ing['tipo'],
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '\$${precio.toStringAsFixed(0)} · \$${precioPorGramo.toStringAsFixed(1)}/g',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8651A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFFE8651A),
                    bg: const Color(0xFFFFF3ED),
                    onTap: () => _mostrarFormulario(ingrediente: ing),
                  ),
                  const SizedBox(width: 8),
                  _iconBtn(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    bg: const Color(0xFFFEF2F2),
                    onTap: () => _eliminar(ing),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de ingredientes'),
        backgroundColor: const Color(0xFFE8651A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: List.generate(3, (i) {
            final labels = ['Tradicional', 'Rápida', 'Comunes'];
            return Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(labels[i]),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_ingredientesFiltrados(i).length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFFE8651A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8651A)))
          : TabBarView(
              controller: _tabController,
              children: List.generate(
                3,
                (tabIndex) => Column(
                  children: [
                    _buildSelect(tabIndex),
                    const SizedBox(height: 8),
                    Expanded(child: _buildLista(tabIndex)),
                  ],
                ),
              ),
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Página completa para crear / editar ingrediente
// ══════════════════════════════════════════════════════════════════════════════

class _IngredienteFormPage extends StatefulWidget {
  final Map<String, dynamic>? ingrediente;
  final List<String> tiposPorTab;
  final List<String> todosLosTipos;
  final Map<String, String> labelTipo;
  final Map<String, Color> coloresTipo;
  final Map<String, IconData> iconosTipo;
  final IngredienteService service;
  final VoidCallback onSaved;

  const _IngredienteFormPage({
    required this.ingrediente,
    required this.tiposPorTab,
    required this.todosLosTipos,
    required this.labelTipo,
    required this.coloresTipo,
    required this.iconosTipo,
    required this.service,
    required this.onSaved,
  });

  @override
  State<_IngredienteFormPage> createState() => _IngredienteFormPageState();
}

class _IngredienteFormPageState extends State<_IngredienteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _precioController;

  late String _tipo;
  bool _guardando = false;

  bool get _editMode => widget.ingrediente != null;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.ingrediente?['nombre'] ?? '');
    _cantidadController = TextEditingController(
        text: widget.ingrediente?['cantidad']?.toString() ?? '');
    _precioController = TextEditingController(
        text: widget.ingrediente?['precio']?.toString() ?? '0');
    _tipo = widget.ingrediente?['tipo'] ?? widget.tiposPorTab.first;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  String? _validar(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  String? _validarNumero(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (double.tryParse(v.trim()) == null) return 'Ingresa un número válido';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final data = {
      'nombre': _nombreController.text.trim(),
      'cantidad':
          double.tryParse(_cantidadController.text.trim()) ?? 0,
      'precio': double.tryParse(_precioController.text.trim()) ?? 0,
      'tipo': _tipo,
    };

    final bool ok = _editMode
        ? await widget.service.update(widget.ingrediente!['id'], data)
        : await widget.service.create(data);

    setState(() => _guardando = false);

    if (!mounted) return;

    if (ok) {
      widget.onSaved();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editMode
                ? 'Ingrediente actualizado correctamente'
                : 'Ingrediente creado correctamente',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTipoActual =
        widget.coloresTipo[_tipo] ?? const Color(0xFFE8651A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tipo de ingrediente ──
                    _buildTarjeta(
                      icono: Icons.category_outlined,
                      color: colorTipoActual,
                      titulo: 'Tipo de ingrediente',
                      child: _buildSelectorTipo(),
                    ),
                    const SizedBox(height: 14),

                    // ── Información básica ──
                    _buildTarjeta(
                      icono: Icons.restaurant_outlined,
                      color: const Color(0xFFE8651A),
                      titulo: 'Información del ingrediente',
                      child: Column(
                        children: [
                          _campo(
                            controller: _nombreController,
                            label: 'Nombre del ingrediente',
                            icono: Icons.label_outline,
                            validator: _validar,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Cantidad y precio ──
                    _buildTarjeta(
                      icono: Icons.scale_outlined,
                      color: Colors.blue,
                      titulo: 'Cantidad y precio base',
                      child: Column(
                        children: [
                          _campo(
                            controller: _cantidadController,
                            label: 'Cantidad base',
                            icono: Icons.monitor_weight_outlined,
                            tipo: TextInputType.number,
                            validator: _validarNumero,
                            sufijo: 'g/ml',
                            helper: 'En gramos o mililitros',
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _precioController,
                            label: 'Precio base',
                            icono: Icons.attach_money_outlined,
                            tipo: TextInputType.number,
                            validator: _validarNumero,
                            prefijo: '\$ ',
                            helper: 'Precio para la cantidad base (IVA incluido)',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Botón guardar ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8651A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE8651A)
                              .withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _guardando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _editMode
                                        ? Icons.check_circle_outline
                                        : Icons.save_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _editMode
                                        ? 'Guardar cambios'
                                        : 'Crear ingrediente',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Selector visual de tipo ───────────────────────────────────────────────

  Widget _buildSelectorTipo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.todosLosTipos.map((t) {
        final seleccionado = _tipo == t;
        final color = widget.coloresTipo[t] ?? Colors.grey;
        final icono = widget.iconosTipo[t] ?? Icons.circle_outlined;
        final label = widget.labelTipo[t] ?? t;

        return GestureDetector(
          onTap: () => setState(() => _tipo = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color:
                  seleccionado ? color : color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: seleccionado
                    ? color
                    : color.withValues(alpha: 0.3),
                width: seleccionado ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icono,
                  size: 15,
                  color: seleccionado ? Colors.white : color,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: seleccionado ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Header con gradiente ──────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editMode ? 'Editar ingrediente' : 'Nuevo ingrediente',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _editMode
                    ? 'Modifica la información del ingrediente'
                    : 'Completa los datos del nuevo ingrediente',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tarjeta de sección ────────────────────────────────────────────────────

  Widget _buildTarjeta({
    required IconData icono,
    required Color color,
    required String titulo,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── Campo de texto ────────────────────────────────────────────────────────

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType tipo = TextInputType.text,
    String? sufijo,
    String? prefijo,
    String? helper,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipo,
      validator: validator,
      style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        suffixText: sufijo,
        prefixText: prefijo,
        labelStyle:
            TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFFE8651A),
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon:
            Icon(icono, color: Colors.grey.shade400, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE8651A), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}