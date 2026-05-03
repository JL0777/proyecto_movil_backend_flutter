import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/menu_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/upload_service.dart';

class GestionMenusScreen extends StatefulWidget {
  const GestionMenusScreen({super.key});

  @override
  State<GestionMenusScreen> createState() => _GestionMenusScreenState();
}

class _GestionMenusScreenState extends State<GestionMenusScreen> {
  final MenuService _menuService = MenuService();
  final CategoriaService _categoriaService = CategoriaService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _picker = ImagePicker();

  List<dynamic> _menus = [];
  List<dynamic> _categorias = [];
  bool _loading = true;
  int? _categoriaSeleccionada;

  List<dynamic> get _menusFiltrados => _categoriaSeleccionada == null
      ? _menus
      : _menus
            .where((m) => m['categoriaId'] == _categoriaSeleccionada)
            .toList();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final menus = await _menuService.getAll();
      final categorias = await _categoriaService.getAll();
      setState(() {
        _menus = menus;
        _categorias = categorias;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleDisponible(Map<String, dynamic> menu) async {
    final ok = await _menuService.toggleDisponible(menu['id']);
    if (ok) {
      final nuevoEstado = !(menu['disponible'] ?? true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  nuevoEstado ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  nuevoEstado ? 'Menú activado' : 'Menú desactivado',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: nuevoEstado ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _cargar();
    }
  }

  void _mostrarDetalle(Map<String, dynamic> menu) {
    final precio = double.tryParse(menu['precio'].toString()) ?? 0;
    final disponible = menu['disponible'] ?? true;
    final categoria = menu['Categoria'];
    final esBalanceado = menu['esBalanceado'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    if (menu['imagenUrl'] != null &&
                        menu['imagenUrl'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Image.network(
                          menu['imagenUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagenPlaceholderGrande(),
                        ),
                      )
                    else
                      _imagenPlaceholderGrande(),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre + precio
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  menu['nombre'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '\$${precio.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE8651A),
                                ),
                              ),
                            ],
                          ),

                          // Categoría
                          if (categoria != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8651A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                categoria['nombre'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE8651A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],

                          // Descripción
                          if (menu['descripcion'] != null &&
                              menu['descripcion'].toString().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              menu['descripcion'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Balanceado
                          if (esBalanceado) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    color: Colors.green.shade600,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Menú Balanceado',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  if (menu['calorias'] != null) ...[
                                    const Spacer(),
                                    Text(
                                      '${menu['calorias']} kcal',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Toggle disponible
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: disponible
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: disponible
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  disponible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: disponible
                                      ? Colors.green.shade600
                                      : Colors.red.shade400,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        disponible
                                            ? 'Visible para clientes'
                                            : 'Oculto para clientes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: disponible
                                              ? Colors.green.shade700
                                              : Colors.red.shade600,
                                        ),
                                      ),
                                      Text(
                                        disponible
                                            ? 'Los clientes pueden ver y pedir este menú'
                                            : 'Este menú no aparece en la app del cliente',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: disponible,
                                  onChanged: (_) async {
                                    Navigator.pop(ctx);
                                    await _toggleDisponible(menu);
                                  },
                                  activeThumbColor: Colors.green,
                                  inactiveThumbColor: Colors.red.shade300,
                                  inactiveTrackColor: Colors.red.shade100,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botones
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _mostrarFormulario(menu: menu);
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Editar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFE8651A),
                                    side: const BorderSide(
                                      color: Color(0xFFE8651A),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _mostrarFormularioNutricional(menu: menu);
                                  },
                                  icon: const Icon(
                                    Icons.monitor_weight_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Nutrición',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _eliminar(menu);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
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
            ),
          ],
        ),
      ),
    );
  }

  // ── Formulario de crear / editar menú ──────────────────────────────────────

  void _mostrarFormulario({Map<String, dynamic>? menu}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MenuFormPage(
          menu: menu,
          categorias: _categorias,
          menuService: _menuService,
          uploadService: _uploadService,
          picker: _picker,
          onSaved: _cargar,
        ),
      ),
    );
  }

  // ── Formulario nutricional (sin cambios de diseño) ─────────────────────────

  void _mostrarFormularioNutricional({required Map<String, dynamic> menu}) {
    final caloriasController = TextEditingController(
      text: menu['calorias']?.toString() ?? '',
    );
    final proteinasController = TextEditingController(
      text: menu['proteinas']?.toString() ?? '',
    );
    final carbosController = TextEditingController(
      text: menu['carbohidratos']?.toString() ?? '',
    );
    final grasasController = TextEditingController(
      text: menu['grasas']?.toString() ?? '',
    );

    String? objetivo = menu['objetivo'];
    bool esBalanceado = menu['esBalanceado'] ?? false;
    bool guardando = false;

    final messenger = ScaffoldMessenger.of(context);

    final List<Map<String, dynamic>> objetivos = [
      {
        'valor': 'bajar_peso',
        'label': 'Bajar peso',
        'icono': Icons.trending_down_rounded,
        'color': Colors.blue,
      },
      {
        'valor': 'subir_musculo',
        'label': 'Subir músculo',
        'icono': Icons.fitness_center_rounded,
        'color': Colors.orange,
      },
      {
        'valor': 'mantenimiento',
        'label': 'Mantenimiento',
        'icono': Icons.balance_rounded,
        'color': Colors.green,
      },
      {
        'valor': 'energia',
        'label': 'Energía',
        'icono': Icons.bolt_rounded,
        'color': Colors.amber,
      },
      {
        'valor': 'digestivo',
        'label': 'Digestivo',
        'icono': Icons.spa_rounded,
        'color': Colors.teal,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3ED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.monitor_weight_outlined,
                        color: Color(0xFFE8651A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Info nutricional',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            menu['nombre'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Macronutrientes (por porción)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _campoNutricional(
                        caloriasController,
                        'Calorías',
                        'kcal',
                        Icons.local_fire_department_outlined,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _campoNutricional(
                        proteinasController,
                        'Proteínas',
                        'g',
                        Icons.fitness_center_outlined,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _campoNutricional(
                        carbosController,
                        'Carbohidratos',
                        'g',
                        Icons.grain_outlined,
                        Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _campoNutricional(
                        grasasController,
                        'Grasas',
                        'g',
                        Icons.water_drop_outlined,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Objetivo del menú',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: objetivos.map((o) {
                    final seleccionado = objetivo == o['valor'];
                    final color = o['color'] as Color;
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => objetivo = o['valor'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? color
                              : color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: seleccionado
                                ? color
                                : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              o['icono'] as IconData,
                              size: 14,
                              color: seleccionado ? Colors.white : color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              o['label'] as String,
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
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: esBalanceado
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: esBalanceado
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: esBalanceado ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activar como menú balanceado',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: esBalanceado
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'Aparecerá en la sección de menús saludables',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: esBalanceado,
                        onChanged: (v) => setModalState(() => esBalanceado = v),
                        activeThumbColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: guardando
                        ? null
                        : () async {
                            if (esBalanceado) {
                              if (caloriasController.text.isEmpty ||
                                  proteinasController.text.isEmpty ||
                                  carbosController.text.isEmpty ||
                                  grasasController.text.isEmpty ||
                                  objetivo == null) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Para activar como balanceado completa todos los campos y selecciona un objetivo',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                            }

                            setModalState(() => guardando = true);

                            final ok = await _menuService
                                .updateNutricional(menu['id'], {
                                  'calorias': int.tryParse(
                                    caloriasController.text,
                                  ),
                                  'proteinas': double.tryParse(
                                    proteinasController.text,
                                  ),
                                  'carbohidratos': double.tryParse(
                                    carbosController.text,
                                  ),
                                  'grasas': double.tryParse(
                                    grasasController.text,
                                  ),
                                  'objetivo': objetivo,
                                  'esBalanceado': esBalanceado,
                                });

                            setModalState(() => guardando = false);

                            if (sheetCtx.mounted) {
                              Navigator.of(sheetCtx).pop();
                            }

                            if (ok) {
                              _cargar();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Info nutricional guardada ✓',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Error al guardar'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar info nutricional',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoNutricional(
    TextEditingController controller,
    String label,
    String sufijo,
    IconData icono,
    Color color,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        suffixText: sufijo,
        prefixIcon: Icon(icono, color: color, size: 18),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        floatingLabelStyle: TextStyle(color: color, fontSize: 12),
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
          borderSide: BorderSide(color: color, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
      ),
    );
  }

  Future<void> _eliminar(Map<String, dynamic> menu) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar menú'),
          ],
        ),
        content: Text('¿Eliminar "${menu['nombre']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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

    final ok = await _menuService.delete(menu['id']);

    if (ok) {
      _cargar();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Menú eliminado correctamente'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de menús'),
        backgroundColor: const Color(0xFFE8651A),
        foregroundColor: Colors.white,
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
          : Column(
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
                      child: DropdownButton<int?>(
                        value: _categoriaSeleccionada,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFFE8651A),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Todas las categorías'),
                          ),
                          ..._categorias.map(
                            (c) => DropdownMenuItem<int?>(
                              value: c['id'],
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8651A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c['nombre']),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _categoriaSeleccionada = v),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${_menusFiltrados.length} menú${_menusFiltrados.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_categoriaSeleccionada != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _categoriaSeleccionada = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE8651A,
                              ).withValues(alpha: 0.1),
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
                const SizedBox(height: 8),
                Expanded(
                  child: _menusFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu_outlined,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _categoriaSeleccionada != null
                                    ? 'No hay menús en esta categoría'
                                    : 'No hay menús creados',
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
                        )
                      : RefreshIndicator(
                          onRefresh: _cargar,
                          color: const Color(0xFFE8651A),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _menusFiltrados.length,
                            itemBuilder: (ctx, index) {
                              final menu = _menusFiltrados[index];
                              final categoria = menu['Categoria'];
                              final precio = double.parse(
                                menu['precio'].toString(),
                              );
                              final disponible = menu['disponible'] ?? true;

                              return GestureDetector(
                                onTap: () => _mostrarDetalle(menu),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: disponible
                                          ? Colors.grey.shade200
                                          : Colors.red.shade100,
                                      width: disponible ? 1 : 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
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
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          menu['imagenUrl'] != null &&
                                              menu['imagenUrl']
                                                  .toString()
                                                  .isNotEmpty
                                          ? Image.network(
                                              menu['imagenUrl'],
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, o, s) =>
                                                  _imagenPlaceholder(),
                                            )
                                          : _imagenPlaceholder(),
                                    ),
                                    title: Text(
                                      menu['nombre'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (categoria != null)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFE8651A,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              categoria['nombre'],
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFE8651A),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${precio.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFE8651A),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: disponible
                                                    ? Colors.green.shade50
                                                    : Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: disponible
                                                      ? Colors.green.shade200
                                                      : Colors.red.shade200,
                                                ),
                                              ),
                                              child: Text(
                                                disponible
                                                    ? 'Activo'
                                                    : 'Inactivo',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: disponible
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _iconBtn(
                                              icon: Icons.edit_outlined,
                                              color: const Color(0xFFE8651A),
                                              bg: const Color(0xFFFFF3ED),
                                              onTap: () => _mostrarFormulario(
                                                menu: menu,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _iconBtn(
                                              icon:
                                                  Icons.monitor_weight_outlined,
                                              color:
                                                  menu['esBalanceado'] == true
                                                  ? Colors.green
                                                  : Colors.grey.shade400,
                                              bg: menu['esBalanceado'] == true
                                                  ? Colors.green.shade50
                                                  : Colors.grey.shade100,
                                              onTap: () =>
                                                  _mostrarFormularioNutricional(
                                                    menu: menu,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            _iconBtn(
                                              icon: Icons.delete_outline,
                                              color: Colors.red,
                                              bg: const Color(0xFFFEF2F2),
                                              onTap: () => _eliminar(menu),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                    trailing: null,
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
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade100,
      child: const Icon(Icons.fastfood_outlined, color: Colors.grey, size: 28),
    );
  }

  Widget _imagenPlaceholderGrande() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.restaurant_outlined,
        color: Colors.grey.shade300,
        size: 50,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Página completa para crear / editar menú
// ══════════════════════════════════════════════════════════════════════════════

class _MenuFormPage extends StatefulWidget {
  final Map<String, dynamic>? menu;
  final List<dynamic> categorias;
  final MenuService menuService;
  final UploadService uploadService;
  final ImagePicker picker;
  final VoidCallback onSaved;

  const _MenuFormPage({
    required this.menu,
    required this.categorias,
    required this.menuService,
    required this.uploadService,
    required this.picker,
    required this.onSaved,
  });

  @override
  State<_MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<_MenuFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;

  int? _categoriaId;
  File? _imagenSeleccionada;
  String _imagenUrl = '';
  bool _guardando = false;

  bool get _editMode => widget.menu != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.menu?['nombre'] ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.menu?['descripcion'] ?? '',
    );
    _precioController = TextEditingController(
      text: widget.menu?['precio']?.toString() ?? '',
    );
    _categoriaId = widget.menu?['categoriaId'];
    _imagenUrl = widget.menu?['imagenUrl'] ?? '';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? img = await widget.picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (img != null) {
      setState(() => _imagenSeleccionada = File(img.path));
    }
  }

  String? _validar(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  String? _validarPrecio(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (double.tryParse(v.trim()) == null) return 'Ingresa un número válido';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    String imagenFinal = _imagenUrl;

    if (_imagenSeleccionada != null) {
      final url = await widget.uploadService.subirImagen(_imagenSeleccionada!);
      if (url == null) {
        setState(() => _guardando = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al subir la imagen'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Eliminar imagen anterior si la hay
      if (widget.menu != null &&
          widget.menu!['imagenUrl'] != null &&
          widget.menu!['imagenUrl'].toString().contains('/uploads/')) {
        await widget.uploadService.eliminarImagen(widget.menu!['imagenUrl']);
      }

      imagenFinal = url;
    }

    final data = {
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'precio': double.parse(_precioController.text.trim()),
      'imagenUrl': imagenFinal,
      'categoriaId': _categoriaId,
    };

    final bool ok = _editMode
        ? await widget.menuService.update(widget.menu!['id'], data)
        : await widget.menuService.create(data);

    setState(() => _guardando = false);

    if (!mounted) return;

    if (ok) {
      widget.onSaved();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editMode
                ? 'Menú actualizado correctamente'
                : 'Menú creado correctamente',
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
  }

  @override
  Widget build(BuildContext context) {
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
                    // ── Imagen ──
                    _buildTarjeta(
                      icono: Icons.image_outlined,
                      color: const Color(0xFFE8651A),
                      titulo: 'Imagen del menú',
                      child: Column(
                        children: [
                          // Preview
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _imagenSeleccionada != null
                                ? Image.file(
                                    _imagenSeleccionada!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : _imagenUrl.isNotEmpty
                                ? Image.network(
                                    _imagenUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) =>
                                        _previewPlaceholder(),
                                  )
                                : _previewPlaceholder(),
                          ),
                          const SizedBox(height: 12),
                          // Botones de imagen
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _guardando
                                      ? null
                                      : () => _pickImage(ImageSource.gallery),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFE8651A),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                    color: Color(0xFFE8651A),
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Galería',
                                    style: TextStyle(
                                      color: Color(0xFFE8651A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _guardando
                                      ? null
                                      : () => _pickImage(ImageSource.camera),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFE8651A),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Color(0xFFE8651A),
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Cámara',
                                    style: TextStyle(
                                      color: Color(0xFFE8651A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Información básica ──
                    _buildTarjeta(
                      icono: Icons.restaurant_outlined,
                      color: const Color(0xFFE8651A),
                      titulo: 'Información del menú',
                      child: Column(
                        children: [
                          _campo(
                            controller: _nombreController,
                            label: 'Nombre del menú',
                            icono: Icons.label_outline,
                            validator: _validar,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _descripcionController,
                            label: 'Descripción',
                            icono: Icons.notes_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _precioController,
                            label: 'Precio',
                            icono: Icons.attach_money_outlined,
                            tipo: TextInputType.number,
                            validator: _validarPrecio,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Categoría ──
                    _buildTarjeta(
                      icono: Icons.category_outlined,
                      color: Colors.blue,
                      titulo: 'Categoría',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _categoriaId,
                            hint: Row(
                              children: [
                                Icon(
                                  Icons.grid_view_outlined,
                                  color: Colors.grey.shade400,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Selecciona una categoría',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade400,
                            ),
                            items: widget.categorias
                                .map(
                                  (c) => DropdownMenuItem<int>(
                                    value: c['id'],
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE8651A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          c['nombre'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _categoriaId = v),
                          ),
                        ),
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
                          disabledBackgroundColor: const Color(
                            0xFFE8651A,
                          ).withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _guardando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
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
                                        : 'Crear menú',
                                    style: const TextStyle(
                                      fontSize: 15,
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
            ),
          ),
        ],
      ),
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
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editMode ? 'Editar menú' : 'Nuevo menú',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _editMode
                    ? 'Modifica la información del menú'
                    : 'Completa los datos del nuevo menú',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                  color: Colors.black87,
                ),
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipo,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFE8651A),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icono, color: Colors.grey.shade400, size: 18),
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
          borderSide: const BorderSide(color: Color(0xFFE8651A), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
      ),
    );
  }

  // ── Preview imagen ────────────────────────────────────────────────────────

  Widget _previewPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
