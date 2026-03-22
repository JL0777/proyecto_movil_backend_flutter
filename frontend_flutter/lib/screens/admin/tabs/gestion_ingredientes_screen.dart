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
    final nombreController =
        TextEditingController(text: ingrediente?['nombre'] ?? '');
    final cantidadController = TextEditingController(
        text: ingrediente?['cantidad']?.toString() ?? '');
    final precioController = TextEditingController(
        text: ingrediente?['precio']?.toString() ?? '0');

    String tipo = ingrediente?['tipo'] ??
        _tiposPorTab(_tabController.index).first;

    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ingrediente == null
                      ? 'Nuevo ingrediente'
                      : 'Editar ingrediente',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _campo(nombreController, 'Nombre'),
                const SizedBox(height: 12),
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad base (ej: 180)',
                    helperText: 'En gramos o ml',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8651A),
                        width: 1.8,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey),
                    suffixText: 'g/ml',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Precio base',
                    helperText: 'Precio para la cantidad base (IVA incluido)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8651A),
                        width: 1.8,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tipo,
                      isExpanded: true,
                      items: _todosLosTipos
                          .map((t) => DropdownMenuItem(
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
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => tipo = v ?? tipo),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nombreController.text.trim().isEmpty) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('El nombre es requerido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (cantidadController.text.trim().isEmpty) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('La cantidad base es requerida'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final data = {
                        'nombre': nombreController.text.trim(),
                        'cantidad': double.tryParse(
                                cantidadController.text.trim()) ??
                            0,
                        'precio': double.tryParse(
                                precioController.text.trim()) ??
                            0,
                        'tipo': tipo,
                      };

                      bool ok;
                      if (ingrediente == null) {
                        ok = await _service.create(data);
                      } else {
                        ok = await _service.update(
                            ingrediente['id'], data);
                      }

                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }

                      if (ok) {
                        _cargar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ingrediente == null
                                  ? 'Ingrediente creado correctamente'
                                  : 'Ingrediente actualizado correctamente',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      ingrediente == null
                          ? 'Crear ingrediente'
                          : 'Guardar cambios',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _eliminar(Map<String, dynamic> ingrediente) async {
    // Capturamos messenger ANTES de cualquier await
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (eliminarIngDialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar ingrediente'),
          ],
        ),
        content: Text('¿Eliminar "${ingrediente['nombre']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(eliminarIngDialogCtx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(eliminarIngDialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE8651A),
            width: 1.8,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
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
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFE8651A),
                ),
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
                        Icon(
                          Icons.close,
                          size: 12,
                          color: Color(0xFFE8651A),
                        ),
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
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca + para agregar uno',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
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
        itemBuilder: (ingListCtx, index) {
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              title: Text(
                ing['nombre'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Base: ${cantidad.toStringAsFixed(0)}g/ml',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                  GestureDetector(
                    onTap: () => _mostrarFormulario(ingrediente: ing),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFE8651A),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _eliminar(ing),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tradicional'),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_ingredientesFiltrados(0).length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Rápida'),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_ingredientesFiltrados(1).length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Comunes'),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_ingredientesFiltrados(2).length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFFE8651A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8651A)),
            )
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