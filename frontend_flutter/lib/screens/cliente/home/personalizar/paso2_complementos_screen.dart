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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_drink_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Elige tu bebida',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                children: [
                  // Opción ninguna
                  GestureDetector(
                    onTap: () {
                      setState(() => _bebidaSeleccionada = null);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _bebidaSeleccionada == null
                            ? Colors.grey.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _bebidaSeleccionada == null
                              ? Colors.grey.shade400
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.no_drinks_outlined,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Sin bebida',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          if (_bebidaSeleccionada == null)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.grey,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                  ..._bebidas.map((b) {
                    final seleccionada = _bebidaSeleccionada?['id'] == b['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _bebidaSeleccionada = b);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: seleccionada
                              ? Colors.blue.withValues(alpha: 0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: seleccionada
                                ? Colors.blue.withValues(alpha: 0.4)
                                : Colors.grey.shade200,
                            width: seleccionada ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_drink_outlined,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b['nombre'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: seleccionada
                                          ? Colors.blue
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (b['cantidad'] != null)
                                    Text(
                                      '${double.parse(b['cantidad'].toString()).toStringAsFixed(0)}ml',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${double.parse(b['precio'].toString()).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: seleccionada
                                    ? Colors.blue
                                    : const Color(0xFFE8651A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (seleccionada)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                                size: 18,
                              )
                            else
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
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
        'id': comp['id'],
        'cantidad': cantidad,
        'nombre': comp['nombre'] ?? 'Complemento',
        'precio': comp['precio'] ?? '0',
      };
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Resumen del paso 1 ──
                        _buildResumenIngredientes(),
                        const SizedBox(height: 16),

                        // ── Bebidas ──
                        _buildSeccionBebidas(),
                        const SizedBox(height: 16),

                        // ── Complementos ──
                        _buildSeccionComplementos(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),

          // ── Footer ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '\$${_subtotalTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE8651A),
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Siguiente',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
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

  // ── Resumen ingredientes paso 1 ────────────────────────────

  Widget _buildResumenIngredientes() {
    final items = widget.ingredientes.values.toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8651A).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFE8651A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingredientes seleccionados',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8651A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items.map((i) => i['nombre']).join(', '),
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFE8651A).withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Text(
            '\$${widget.subtotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE8651A),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección bebidas ────────────────────────────────────────

  Widget _buildSeccionBebidas() {
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_drink_outlined,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bebida',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Opcional',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _mostrarBebidas,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _bebidaSeleccionada != null
                    ? Colors.blue.withValues(alpha: 0.06)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _bebidaSeleccionada != null
                      ? Colors.blue.withValues(alpha: 0.4)
                      : Colors.grey.shade200,
                  width: _bebidaSeleccionada != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _bebidaSeleccionada != null
                        ? Icons.local_drink_outlined
                        : Icons.add_circle_outline,
                    color: _bebidaSeleccionada != null
                        ? Colors.blue
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _bebidaSeleccionada != null
                          ? _bebidaSeleccionada!['nombre']
                          : 'Selecciona una bebida',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _bebidaSeleccionada != null
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _bebidaSeleccionada != null
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  if (_bebidaSeleccionada != null) ...[
                    Text(
                      '\$${double.parse(_bebidaSeleccionada!['precio'].toString()).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: _bebidaSeleccionada != null
                        ? Colors.blue
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección complementos ───────────────────────────────────

  Widget _buildSeccionComplementos() {
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.green,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Complementos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Contador
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _totalComplementos > 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalComplementos / $_maxComplementosGratis gratis',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _totalComplementos > 0
                        ? Colors.green
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),

          // Barra de progreso
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _totalComplementos / _maxComplementosGratis,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),

          // Lista de complementos
          ..._complementos.map((comp) {
            final id = comp['id'].toString();
            final cantidad = _complementosSeleccionados[id] ?? 0;
            final seleccionado = cantidad > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: seleccionado
                    ? Colors.green.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: seleccionado
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: seleccionado ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: seleccionado ? Colors.green : Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comp['nombre'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: seleccionado
                                ? Colors.green.shade700
                                : Colors.black87,
                          ),
                        ),
                        if (comp['cantidad'] != null)
                          Text(
                            '${double.parse(comp['cantidad'].toString()).toStringAsFixed(0)}g',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (cantidad > 0) {
                            setState(() {
                              if (cantidad == 1) {
                                _complementosSeleccionados.remove(id);
                              } else {
                                _complementosSeleccionados[id] = cantidad - 1;
                              }
                            });
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cantidad > 0
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: cantidad > 0
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: cantidad > 0
                                ? Colors.red
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$cantidad',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: seleccionado ? Colors.green : Colors.black54,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_totalComplementos < _maxComplementosGratis) {
                            setState(() {
                              _complementosSeleccionados[id] = cantidad + 1;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Máximo $_maxComplementosGratis complementos gratis',
                                ),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
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
    );
  }

  // ── Header ──────────────────────────────────────────────────

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
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
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
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personaliza tu menú',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Paso 2 de 4',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pasos ────────────────────────────────────────────────────

  Widget _buildPasos() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _paso(1, 'Ingredientes', false, completado: true),
          _lineaPaso(completado: true),
          _paso(2, 'Complementos', true),
          _lineaPaso(),
          _paso(3, 'Dirección', false),
          _lineaPaso(),
          _paso(4, 'Pago', false),
        ],
      ),
    );
  }

  Widget _paso(
    int numero,
    String label,
    bool activo, {
    bool completado = false,
  }) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo
                ? const Color(0xFFE8651A)
                : completado
                ? Colors.green
                : Colors.grey.shade100,
            border: Border.all(
              color: activo
                  ? const Color(0xFFE8651A)
                  : completado
                  ? Colors.green
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: completado
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    '$numero',
                    style: TextStyle(
                      fontSize: 13,
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
            fontSize: 9,
            color: activo
                ? const Color(0xFFE8651A)
                : completado
                ? Colors.green
                : Colors.grey,
            fontWeight: activo || completado
                ? FontWeight.w700
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _lineaPaso({bool completado = false}) {
    return Container(
      width: 22,
      height: 1,
      color: completado ? Colors.green.shade200 : Colors.grey.shade200,
      margin: const EdgeInsets.only(bottom: 18),
    );
  }
}
