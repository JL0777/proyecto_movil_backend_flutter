import 'package:flutter/material.dart';
import '../../../services/categoria_service.dart';

class CategoriasTab extends StatefulWidget {
  const CategoriasTab({super.key});

  @override
  State<CategoriasTab> createState() => _CategoriasTabState();
}

class _CategoriasTabState extends State<CategoriasTab> {
  final CategoriaService _service = CategoriaService();
  List<dynamic> _categorias = [];
  bool _loading = true;
  String? _tipoSeleccionado;

  final List<String> _tipos = ['tradicional', 'rapida', 'bebida'];

  final Map<String, Color> _coloresTipo = {
    'tradicional': const Color(0xFFE8651A),
    'rapida': Colors.red,
    'bebida': Colors.blue,
  };

  final Map<String, String> _labelTipo = {
    'tradicional': 'Comida tradicional',
    'rapida': 'Comida rápida',
    'bebida': 'Bebidas',
  };

  final Map<String, IconData> _iconosTipo = {
    'tradicional': Icons.set_meal_outlined,
    'rapida': Icons.fastfood_outlined,
    'bebida': Icons.local_drink_outlined,
  };

  List<dynamic> get _categoriasFiltradas => _tipoSeleccionado == null
      ? _categorias
      : _categorias.where((c) => c['tipo'] == _tipoSeleccionado).toList();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getAll();
      setState(() {
        _categorias = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? categoria}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CategoriaFormPage(
          categoria: categoria,
          tipos: _tipos,
          labelTipo: _labelTipo,
          coloresTipo: _coloresTipo,
          iconosTipo: _iconosTipo,
          service: _service,
          onSaved: _cargar,
        ),
      ),
    );
  }

  Future<void> _eliminar(Map<String, dynamic> categoria) async {
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
            Text('Eliminar categoría'),
          ],
        ),
        content: Text(
          '¿Eliminar "${categoria['nombre']}"? También se eliminarán todos sus menús.',
        ),
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

    final ok = await _service.delete(categoria['id']);

    if (ok) {
      _cargar();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Categoría eliminada correctamente'),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8651A)),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFFE8651A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Filtro ──
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
                  value: _tipoSeleccionado,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFFE8651A)),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos los tipos'),
                    ),
                    ..._tipos.map((t) => DropdownMenuItem<String?>(
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
                  onChanged: (v) => setState(() => _tipoSeleccionado = v),
                ),
              ),
            ),
          ),

          // ── Contador y limpiar filtro ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_categoriasFiltradas.length} categoría${_categoriasFiltradas.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_tipoSeleccionado != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _tipoSeleccionado = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE8651A).withValues(alpha: 0.1),
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
                          Icon(Icons.close,
                              size: 12, color: Color(0xFFE8651A)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Lista ──
          Expanded(
            child: _categoriasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _tipoSeleccionado != null
                              ? 'No hay categorías de este tipo'
                              : 'No hay categorías creadas',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca + para agregar una',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    color: const Color(0xFFE8651A),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _categoriasFiltradas.length,
                      itemBuilder: (ctx, index) {
                        final cat = _categoriasFiltradas[index];
                        final color = _coloresTipo[cat['tipo']] ??
                            const Color(0xFFE8651A);
                        final icono = _iconosTipo[cat['tipo']] ??
                            Icons.category_outlined;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icono, color: color, size: 22),
                            ),
                            title: Text(
                              cat['nombre'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _labelTipo[cat['tipo']] ?? cat['tipo'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _iconBtn(
                                  icon: Icons.edit_outlined,
                                  color: const Color(0xFFE8651A),
                                  bg: const Color(0xFFFFF3ED),
                                  onTap: () =>
                                      _mostrarFormulario(categoria: cat),
                                ),
                                const SizedBox(width: 8),
                                _iconBtn(
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  bg: const Color(0xFFFEF2F2),
                                  onTap: () => _eliminar(cat),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
}

// ══════════════════════════════════════════════════════════════════════════════
// Página completa para crear / editar categoría
// ══════════════════════════════════════════════════════════════════════════════

class _CategoriaFormPage extends StatefulWidget {
  final Map<String, dynamic>? categoria;
  final List<String> tipos;
  final Map<String, String> labelTipo;
  final Map<String, Color> coloresTipo;
  final Map<String, IconData> iconosTipo;
  final CategoriaService service;
  final VoidCallback onSaved;

  const _CategoriaFormPage({
    required this.categoria,
    required this.tipos,
    required this.labelTipo,
    required this.coloresTipo,
    required this.iconosTipo,
    required this.service,
    required this.onSaved,
  });

  @override
  State<_CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<_CategoriaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late String _tipo;
  bool _guardando = false;

  bool get _editMode => widget.categoria != null;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.categoria?['nombre'] ?? '');
    _tipo = widget.categoria?['tipo'] ?? widget.tipos.first;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  String? _validar(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (v.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final data = {
      'nombre': _nombreController.text.trim(),
      'tipo': _tipo,
    };

    final bool ok = _editMode
        ? await widget.service.update(widget.categoria!['id'], data)
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
                ? 'Categoría actualizada correctamente'
                : 'Categoría creada correctamente',
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
    final colorActual =
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
                    // ── Selector de tipo ──
                    _buildTarjeta(
                      icono: Icons.category_outlined,
                      color: colorActual,
                      titulo: 'Tipo de categoría',
                      child: _buildSelectorTipo(),
                    ),
                    const SizedBox(height: 14),

                    // ── Nombre ──
                    _buildTarjeta(
                      icono: Icons.label_outline,
                      color: const Color(0xFFE8651A),
                      titulo: 'Información de la categoría',
                      child: _campo(
                        controller: _nombreController,
                        label: 'Nombre de la categoría',
                        icono: Icons.drive_file_rename_outline,
                        validator: _validar,
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
                                        : 'Crear categoría',
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
    return Row(
      children: widget.tipos.map((t) {
        final seleccionado = _tipo == t;
        final color = widget.coloresTipo[t] ?? Colors.grey;
        final icono = widget.iconosTipo[t] ?? Icons.category_outlined;
        final label = widget.labelTipo[t] ?? t;
        // Label corto para que quepan en fila
        final labelCorto = t == 'tradicional' ? 'Tradicional' : label;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tipo = t),
            child: Container(
              margin: EdgeInsets.only(right: t != widget.tipos.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: seleccionado
                    ? color.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: seleccionado
                      ? color.withValues(alpha: 0.6)
                      : Colors.grey.shade200,
                  width: seleccionado ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icono,
                    size: 22,
                    color: seleccionado ? color : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labelCorto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color:
                          seleccionado ? color : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
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
                _editMode ? 'Editar categoría' : 'Nueva categoría',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _editMode
                    ? 'Modifica los datos de la categoría'
                    : 'Completa los datos de la nueva categoría',
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
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