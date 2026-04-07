import 'package:flutter/material.dart';
import '../../../../services/ingrediente_service.dart';
import 'paso3_direccion_screen.dart';

class Paso2ComplementosScreen extends StatefulWidget {
  final Map<String, dynamic> categoria;
  final Map<String, dynamic> ingredientes;
  final double subtotal;

  const Paso2ComplementosScreen({
    super.key,
    required this.categoria,
    required this.ingredientes,
    required this.subtotal,
  });

  @override
  State<Paso2ComplementosScreen> createState() =>
      _Paso2ComplementosScreenState();
}

class _Paso2ComplementosScreenState extends State<Paso2ComplementosScreen> {
  final IngredienteService _service = IngredienteService();

  List<dynamic> _bebidas = [];
  List<dynamic> _complementos = [];

  Map<String, dynamic>? _bebidaSeleccionada;
  final Map<String, int> _complementosSeleccionados = {};

  bool _loading = true;

  static const int _maxComplementosGratis = 3;

  int get _totalComplementos =>
      _complementosSeleccionados.values.fold(0, (sum, c) => sum + c);

  double get _subtotalBebida => _bebidaSeleccionada != null
      ? double.parse(_bebidaSeleccionada!['precio'].toString())
      : 0;

  double get _subtotalTotal => widget.subtotal + _subtotalBebida;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final bebidas = await _service.getByTipo('bebida');
      final complementos = await _service.getByTipo('complemento');
      setState(() {
        _bebidas = bebidas;
        _complementos = complementos;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _mostrarBebidas() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
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
          const Text(
            'Bebidas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ..._bebidas.map(
            (b) => ListTile(
              title: Text(b['nombre']),
              subtitle: Text(
                b['cantidad'] != null
                    ? '${double.parse(b['cantidad'].toString()).toStringAsFixed(0)}ml'
                    : '',
              ),
              trailing: Text(
                '\$${double.parse(b['precio'].toString()).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFE8651A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                setState(() => _bebidaSeleccionada = b);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Map<String, Map<String, dynamic>> _buildComplementosParaPaso3() {
    final result = <String, Map<String, dynamic>>{};
    _complementosSeleccionados.forEach((id, cantidad) {
      final comp = _complementos.firstWhere(
        (c) => c['id'].toString() == id,
        orElse: () => {'nombre': 'Complemento'},
      );
      result[id] = {
        'cantidad': cantidad,
        'nombre': comp['nombre'] ?? 'Complemento',
      };
    });
    return result;
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

                        // Bebidas
                        const Text(
                          'Bebidas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8651A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _mostrarBebidas,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _bebidaSeleccionada != null
                                  ? const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _bebidaSeleccionada != null
                                    ? const Color(0xFFE8651A)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _bebidaSeleccionada != null
                                      ? '${_bebidaSeleccionada!['nombre']} - \$${double.parse(_bebidaSeleccionada!['precio'].toString()).toStringAsFixed(0)}'
                                      : 'Selecciona una bebida (opcional)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _bebidaSeleccionada != null
                                        ? const Color(0xFFE8651A)
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: _bebidaSeleccionada != null
                                      ? const Color(0xFFE8651A)
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Complementos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Complementos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE8651A),
                              ),
                            ),
                            Text(
                              'Hasta $_maxComplementosGratis gratis',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ..._complementos.map((comp) {
                          final id = comp['id'].toString();
                          final cantidad = _complementosSeleccionados[id] ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${comp['nombre']} (${comp['cantidad'] != null ? double.parse(comp['cantidad'].toString()).toStringAsFixed(0) : ''}g)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (cantidad > 0) {
                                          setState(() {
                                            if (cantidad == 1) {
                                              _complementosSeleccionados.remove(
                                                id,
                                              );
                                            } else {
                                              _complementosSeleccionados[id] =
                                                  cantidad - 1;
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '$cantidad',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (_totalComplementos <
                                            _maxComplementosGratis) {
                                          setState(() {
                                            _complementosSeleccionados[id] =
                                                cantidad + 1;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Máximo 3 complementos gratis',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE8651A),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),

          // Footer
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
                      '\$${_subtotalTotal.toStringAsFixed(0)}',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Paso3DireccionScreen(
                            categoria: widget.categoria,
                            ingredientes: widget.ingredientes,
                            bebida: _bebidaSeleccionada ?? {},
                            complementos: _buildComplementosParaPaso3(),
                            subtotal: _subtotalTotal,
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
          _paso(1, 'Ingredientes', false),
          _lineaPaso(),
          _paso(2, 'Complementos', true),
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
