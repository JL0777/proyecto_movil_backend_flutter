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

  void _mostrarFormulario({Map<String, dynamic>? menu}) {
    final nombreController = TextEditingController(text: menu?['nombre'] ?? '');
    final descripcionController = TextEditingController(
      text: menu?['descripcion'] ?? '',
    );
    final precioController = TextEditingController(
      text: menu?['precio']?.toString() ?? '',
    );
    final imagenUrlController = TextEditingController(
      text: menu?['imagenUrl'] ?? '',
    );
    int? categoriaId = menu?['categoriaId'];
    File? imagenSeleccionada;
    bool subiendoImagen = false;

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
                  menu == null ? 'Nuevo menú' : 'Editar menú',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _campo(nombreController, 'Nombre del menú'),
                const SizedBox(height: 12),
                _campo(descripcionController, 'Descripción', maxLines: 3),
                const SizedBox(height: 12),
                _campo(precioController, 'Precio', tipo: TextInputType.number),
                const SizedBox(height: 12),

                const Text(
                  'Imagen del menú',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imagenSeleccionada != null
                      ? Image.file(
                          imagenSeleccionada!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : imagenUrlController.text.isNotEmpty
                      ? Image.network(
                          imagenUrlController.text,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (previewErrCtx, previewErrObj, previewErrStack) =>
                                  _previewPlaceholder(),
                        )
                      : _previewPlaceholder(),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: subiendoImagen
                            ? null
                            : () async {
                                final XFile? img = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                );
                                if (img != null) {
                                  setModalState(() {
                                    imagenSeleccionada = File(img.path);
                                  });
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE8651A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: subiendoImagen
                            ? null
                            : () async {
                                final XFile? img = await _picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 80,
                                );
                                if (img != null) {
                                  setModalState(() {
                                    imagenSeleccionada = File(img.path);
                                  });
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE8651A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    child: DropdownButton<int>(
                      value: categoriaId,
                      hint: const Text('Selecciona categoría'),
                      isExpanded: true,
                      items: _categorias
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c['id'],
                              child: Text(c['nombre']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setModalState(() => categoriaId = v),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: subiendoImagen
                        ? null
                        : () async {
                            if (nombreController.text.trim().isEmpty ||
                                precioController.text.trim().isEmpty ||
                                categoriaId == null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Completa todos los campos'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            String imagenUrl = imagenUrlController.text.trim();

                            if (imagenSeleccionada != null) {
                              setModalState(() => subiendoImagen = true);

                              final url = await _uploadService.subirImagen(
                                imagenSeleccionada!,
                              );

                              setModalState(() => subiendoImagen = false);

                              if (url != null) {
                                imagenUrl = url;
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al subir la imagen'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                            }

                            if (imagenSeleccionada != null &&
                                menu != null &&
                                menu['imagenUrl'] != null &&
                                menu['imagenUrl'].toString().isNotEmpty &&
                                menu['imagenUrl'].toString().contains(
                                  '/uploads/',
                                )) {
                              await _uploadService.eliminarImagen(
                                menu['imagenUrl'],
                              );
                            }

                            final data = {
                              'nombre': nombreController.text.trim(),
                              'descripcion': descripcionController.text.trim(),
                              'precio': double.parse(
                                precioController.text.trim(),
                              ),
                              'imagenUrl': imagenUrl,
                              'categoriaId': categoriaId,
                            };

                            bool ok;
                            if (menu == null) {
                              ok = await _menuService.create(data);
                            } else {
                              ok = await _menuService.update(menu['id'], data);
                            }

                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }

                            if (ok) {
                              _cargar();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    menu == null
                                        ? 'Menú creado correctamente'
                                        : 'Menú actualizado correctamente',
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
                      disabledBackgroundColor: const Color(
                        0xFFE8651A,
                      ).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: subiendoImagen
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            menu == null ? 'Crear menú' : 'Guardar cambios',
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
                // Handle
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

                // Título
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

                // Macros
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

                // Objetivo
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

                // Toggle esBalanceado
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

                // Botón guardar
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

  Widget _previewPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminar(Map<String, dynamic> menu) async {
    // Capturamos messenger ANTES de cualquier await
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (eliminarMenuDialogCtx) => AlertDialog(
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
            onPressed: () => Navigator.pop(eliminarMenuDialogCtx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(eliminarMenuDialogCtx, true),
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

  Widget _campo(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8651A), width: 1.8),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
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
                            itemBuilder: (menuListCtx, index) {
                              final menu = _menusFiltrados[index];
                              final categoria = menu['Categoria'];
                              final precio = double.parse(
                                menu['precio'].toString(),
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
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
                                            errorBuilder:
                                                (
                                                  menuImgErrCtx,
                                                  menuImgErrObj,
                                                  menuImgErrStack,
                                                ) => _imagenPlaceholder(),
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
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFE8651A,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                      Text(
                                        '\$${precio.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFE8651A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ── Editar info básica ──
                                      GestureDetector(
                                        onTap: () =>
                                            _mostrarFormulario(menu: menu),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3ED),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFFE8651A),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // ── Info nutricional ──
                                      GestureDetector(
                                        onTap: () =>
                                            _mostrarFormularioNutricional(
                                              menu: menu,
                                            ),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: menu['esBalanceado'] == true
                                                ? Colors.green.shade50
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.monitor_weight_outlined,
                                            color: menu['esBalanceado'] == true
                                                ? Colors.green
                                                : Colors.grey.shade400,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // ── Eliminar ──
                                      GestureDetector(
                                        onTap: () => _eliminar(menu),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                        ),
                ),
              ],
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
}
