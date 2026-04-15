import 'package:flutter/material.dart';
import '../../../../services/ingrediente_service.dart';
import 'paso2_complementos_screen.dart';

class Paso1IngredientesScreen extends StatefulWidget {
  final Map<String, dynamic> categoria;

  const Paso1IngredientesScreen({super.key, required this.categoria});

  @override
  State<Paso1IngredientesScreen> createState() =>
      _Paso1IngredientesScreenState();
}

class _Paso1IngredientesScreenState extends State<Paso1IngredientesScreen> {
  final IngredienteService _service = IngredienteService();

  Map<String, List<dynamic>> _ingredientes = {};
  Map<String, dynamic> _seleccionados = {};
  bool _loading = true;

  Map<String, String> get _labels {
    final tipo = widget.categoria['tipo'] ?? 'tradicional';
    if (tipo == 'rapida') {
      return {
        'pan': '+ TIPO DE PAN',
        'proteina': '+ PROTEÍNA',
        'salsa': '+ SALSA',
        'vegetal': '+ VEGETALES',
        'extra': '+ EXTRAS',
      };
    }
    return {
      'proteina': '+ PROTEÍNA',
      'legumbre': '+ LEGUMBRES',
      'carbohidrato': '+ CARBOHIDRATOS',
      'vegetal': '+ VEGETALES',
    };
  }

  Map<String, Color> get _colores {
    final tipo = widget.categoria['tipo'] ?? 'tradicional';
    if (tipo == 'rapida') {
      return {
        'pan': Colors.brown,
        'proteina': const Color(0xFFE8651A),
        'salsa': Colors.red,
        'vegetal': Colors.teal,
        'extra': Colors.purple,
      };
    }
    return {
      'proteina': const Color(0xFFE8651A),
      'legumbre': Colors.green,
      'carbohidrato': Colors.amber,
      'vegetal': Colors.teal,
    };
  }

  double get _subtotal {
    double total = 0;
    for (final item in _seleccionados.values) {
      if (item != null) {
        total += double.parse(item['precio'].toString());
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final Map<String, List<dynamic>> ingredientes = {};
      final Map<String, dynamic> seleccionados = {};

      for (final tipo in _labels.keys) {
        ingredientes[tipo] = await _service.getByTipo(tipo);
        seleccionados[tipo] = null;
      }

      setState(() {
        _ingredientes = ingredientes;
        _seleccionados = seleccionados;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _mostrarOpciones(String tipo) {
    final opciones = _ingredientes[tipo] ?? [];
    final seleccionado = _seleccionados[tipo];

    if (opciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay opciones disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Capturamos el navigator ANTES de entrar al builder
    final nav = Navigator.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetOpcionesCtx) => Column(
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
          const SizedBox(height: 16),
          Text(
            _labels[tipo] ?? tipo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (seleccionado != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar selección'),
              subtitle: const Text('Eliminar ingrediente'),
              onTap: () {
                nav.pop();
                setState(() => _seleccionados[tipo] = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrediente eliminado correctamente'),
                    backgroundColor: Color.fromARGB(255, 76, 175, 80),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
            ),
          ...opciones.map(
            (op) => ListTile(
              title: Text(op['nombre']),
              subtitle: Text(
                op['cantidad'] != null
                    ? '${double.parse(op['cantidad'].toString()).toStringAsFixed(0)}g/ml'
                    : '',
              ),
              trailing: Text(
                '\$${double.parse(op['precio'].toString()).toStringAsFixed(0)}',
                style: TextStyle(
                  color: _colores[tipo],
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                nav.pop();
                _mostrarEditorCantidad(tipo, op);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _mostrarEditorCantidad(String tipo, Map<String, dynamic> op) {
    final cantidadBase = op['cantidad'] != null
        ? double.parse(op['cantidad'].toString())
        : 0.0;
    final precioBase = double.parse(op['precio'].toString());
    final precioPorGramo = cantidadBase > 0 ? precioBase / cantidadBase : 0.0;

    double gramos = cantidadBase;

    showDialog(
      context: context,
      builder: (editorDialogCtx) => StatefulBuilder(
        builder: (editorDialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            op['nombre'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cantidad base sugerida: ${cantidadBase.toStringAsFixed(0)}g/ml',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (gramos > 10) {
                        setDialogState(() => gramos -= 10);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: gramos > 10
                            ? const Color(0xFFE8651A)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          gramos.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'g/ml',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() => gramos += 10);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8651A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio:',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Text(
                      '\$${(precioPorGramo * gramos).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(editorDialogCtx),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final opConCantidad = Map<String, dynamic>.from(op);
                opConCantidad['cantidad'] = gramos;
                opConCantidad['precio'] = (precioPorGramo * gramos)
                    .toStringAsFixed(0);
                setState(() => _seleccionados[tipo] = opConCantidad);
                Navigator.pop(editorDialogCtx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8651A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildPasos(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERSONALIZA TU MENÚ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 3,
                          color: const Color(0xFFE8651A),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE8651A),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child:
                                  _seleccionados.values.every((v) => v == null)
                                  ? Icon(
                                      Icons.restaurant_menu_outlined,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: _seleccionados.entries
                                            .where((e) => e.value != null)
                                            .map(
                                              (e) => Text(
                                                e.value!['nombre'],
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ..._labels.entries.map((entry) {
                          final tipo = entry.key;
                          final seleccionado = _seleccionados[tipo];
                          final color =
                              _colores[tipo] ?? const Color(0xFFE8651A);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _mostrarOpciones(tipo),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: seleccionado != null
                                      ? color.withValues(alpha: 0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: seleccionado != null
                                        ? color
                                        : Colors.black87,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        seleccionado != null
                                            ? '✓ ${seleccionado['nombre']} (${double.parse(seleccionado['cantidad'].toString()).toStringAsFixed(0)}g)'
                                            : entry.value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: seleccionado != null
                                              ? color
                                              : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (seleccionado != null)
                                      Row(
                                        children: [
                                          Text(
                                            '\$${double.parse(seleccionado['precio'].toString()).toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.check_circle,
                                            color: color,
                                            size: 20,
                                          ),
                                        ],
                                      )
                                    else
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey.shade400,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '\$${_subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final haySeleccionado = _seleccionados.values.any(
                        (v) => v != null,
                      );

                      if (!haySeleccionado) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selecciona al menos un ingrediente para continuar',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Paso2ComplementosScreen(
                            categoria: widget.categoria,
                            ingredientes: _seleccionados,
                            subtotal: _subtotal,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x66000000), BlendMode.darken),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildPasos() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _paso(1, 'Ingredientes', true),
          _lineaPaso(),
          _paso(2, 'Complementos', false),
          _lineaPaso(),
          _paso(3, 'Dirección', false),
          _lineaPaso(),
          _paso(4, 'Pago', false),
        ],
      ),
    );
  }

  Widget _paso(int numero, String label, bool activo) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? const Color(0xFFE8651A) : Colors.grey.shade200,
            border: Border.all(
              color: activo ? const Color(0xFFE8651A) : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              '$numero',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: activo ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: activo ? const Color(0xFFE8651A) : Colors.grey,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _lineaPaso() {
    return Container(
      width: 24,
      height: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }
}
