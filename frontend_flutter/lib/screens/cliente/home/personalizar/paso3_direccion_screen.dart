import 'package:flutter/material.dart';
import '../../../../services/address_service.dart';
import 'paso4_pago_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';

class Paso3DireccionScreen extends StatefulWidget {
  final Map<String, dynamic> categoria;
  final Map<String, dynamic> ingredientes;
  final Map<String, dynamic> bebida;
  final Map<String, Map<String, dynamic>> complementos;
  final double subtotal;

  const Paso3DireccionScreen({
    super.key,
    required this.categoria,
    required this.ingredientes,
    required this.bebida,
    required this.complementos,
    required this.subtotal,
  });

  @override
  State<Paso3DireccionScreen> createState() => _Paso3DireccionScreenState();
}

class _Paso3DireccionScreenState extends State<Paso3DireccionScreen> {
  final AddressService _service = AddressService();

  List<dynamic> _direcciones = [];
  Map<String, dynamic>? _direccionSeleccionada;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getAddresses();
      setState(() {
        _direcciones = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _mostrarFormularioNuevaDireccion() {
    final barrioController = TextEditingController();
    final direccionController = TextEditingController();
    final instruccionesController = TextEditingController();
    String tipoVivienda = 'Casa';

    final tipos = [
      ('Casa', Icons.home_outlined),
      ('Apartamento', Icons.apartment_outlined),
      ('Oficina/Local comercial', Icons.business_center_outlined),
      ('Hotel', Icons.hotel_outlined),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Mini header naranja ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nueva dirección',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Completa los datos de entrega',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Selector tipo vivienda ──
                      Container(
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
                                    color: const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.home_outlined,
                                    color: Color(0xFFE8651A),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tipo de vivienda',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: tipos.map((t) {
                                final (label, icono) = t;
                                final seleccionado = tipoVivienda == label;
                                final labelCorto =
                                    label == 'Oficina/Local comercial'
                                    ? 'Oficina'
                                    : label;
                                final isLast = label == 'Hotel';
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setModalState(
                                      () => tipoVivienda = label,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: isLast ? 0 : 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: seleccionado
                                            ? const Color(
                                                0xFFE8651A,
                                              ).withValues(alpha: 0.08)
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: seleccionado
                                              ? const Color(
                                                  0xFFE8651A,
                                                ).withValues(alpha: 0.5)
                                              : Colors.grey.shade200,
                                          width: seleccionado ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            icono,
                                            size: 20,
                                            color: seleccionado
                                                ? const Color(0xFFE8651A)
                                                : Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            labelCorto,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: seleccionado
                                                  ? const Color(0xFFE8651A)
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Campos ubicación ──
                      Container(
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
                                    color: const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFFE8651A),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ubicación',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _campo(
                              barrioController,
                              'Barrio / Conjunto',
                              icono: Icons.map_outlined,
                            ),
                            const SizedBox(height: 12),
                            _campo(
                              direccionController,
                              'Dirección',
                              icono: Icons.signpost_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Instrucciones ──
                      Container(
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
                                    Icons.notes_outlined,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detalles adicionales',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
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
                            const SizedBox(height: 14),
                            _campo(
                              instruccionesController,
                              'Instrucciones para el domiciliario',
                              icono: Icons.info_outline,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Botón guardar ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (barrioController.text.trim().isEmpty ||
                                direccionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Barrio y dirección son requeridos',
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

                            final nav = Navigator.of(sheetCtx);
                            final messenger = ScaffoldMessenger.of(context);

                            final ok = await _service.createAddress({
                              'barrio': barrioController.text.trim(),
                              'direccion': direccionController.text.trim(),
                              'instrucciones': instruccionesController.text
                                  .trim(),
                              'tipoVivienda': tipoVivienda,
                            });

                            nav.pop();

                            if (ok) {
                              await _cargar();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Dirección agregada correctamente',
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8651A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Guardar dirección',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _agregarAlCarrito() {
    if (_direccionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona una dirección primero'),
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

    final cart = context.read<CartProvider>();

    widget.ingredientes.forEach((key, value) {
      if (value != null) cart.agregarIngrediente(value, 1);
    });

    if (widget.bebida.isNotEmpty) {
      cart.agregarIngrediente(widget.bebida, 1);
    }

    widget.complementos.forEach((key, value) {
      final cantidad = int.tryParse(value['cantidad'].toString()) ?? 1;
      cart.agregarIngrediente(value, cantidad);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Combo agregado al carrito!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    IconData? icono,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
        prefixIcon: icono != null
            ? Icon(icono, color: Colors.grey.shade400, size: 18)
            : null,
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
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
                        _buildResumenAnterior(),
                        const SizedBox(height: 16),
                        _buildSeccionDireccion(),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _direccionSeleccionada != null
                        ? _agregarAlCarrito
                        : null,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text(
                      'Añadir al carrito',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8651A),
                      disabledForegroundColor: Colors.grey.shade400,
                      side: BorderSide(
                        color: _direccionSeleccionada != null
                            ? const Color(0xFFE8651A)
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _direccionSeleccionada != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Paso4PagoScreen(
                                  categoria: widget.categoria,
                                  ingredientes: widget.ingredientes,
                                  bebida: widget.bebida,
                                  complementos: widget.complementos,
                                  direccion: _direccionSeleccionada!,
                                  subtotal: widget.subtotal,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
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

  // ── Resumen pasos anteriores ───────────────────────────────

  Widget _buildResumenAnterior() {
    final ingredientesNombres = widget.ingredientes.values
        .map((i) => i['nombre'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');

    final tieneBebida = widget.bebida.isNotEmpty;
    final totalComplementos = widget.complementos.values.fold<int>(0, (sum, c) {
      return sum + (int.tryParse(c['cantidad'].toString()) ?? 1);
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8651A).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFFE8651A),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tu pedido hasta ahora',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8651A),
                ),
              ),
              const Spacer(),
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
          if (ingredientesNombres.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              ingredientesNombres,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFFE8651A).withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
          if (tieneBebida || totalComplementos > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (tieneBebida)
                  _chipResumen(
                    Icons.local_drink_outlined,
                    widget.bebida['nombre'] ?? 'Bebida',
                    Colors.blue,
                  ),
                if (tieneBebida && totalComplementos > 0)
                  const SizedBox(width: 6),
                if (totalComplementos > 0)
                  _chipResumen(
                    Icons.add_circle_outline,
                    '$totalComplementos complemento(s)',
                    Colors.green,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chipResumen(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección dirección ──────────────────────────────────────

  Widget _buildSeccionDireccion() {
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
                  color: const Color(0xFFE8651A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFE8651A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Dirección de envío',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_direcciones.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _direccionSeleccionada != null
                        ? const Color(0xFFE8651A).withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _direccionSeleccionada != null
                        ? '1 seleccionada'
                        : '${_direcciones.length} guardada(s)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _direccionSeleccionada != null
                          ? const Color(0xFFE8651A)
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: _mostrarFormularioNuevaDireccion,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8651A).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8651A).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_location_alt_outlined,
                    color: Color(0xFFE8651A),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Agregar nueva dirección',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFFE8651A), size: 20),
                ],
              ),
            ),
          ),

          if (_direcciones.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_off_outlined,
                      size: 30,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No tienes direcciones guardadas',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca el botón de arriba para agregar una',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),
            Text(
              'MIS DIRECCIONES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ..._direcciones.map((dir) {
              final seleccionada = _direccionSeleccionada?['id'] == dir['id'];
              return GestureDetector(
                onTap: () => setState(() => _direccionSeleccionada = dir),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? const Color(0xFFE8651A).withValues(alpha: 0.06)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: seleccionada
                          ? const Color(0xFFE8651A).withValues(alpha: 0.4)
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
                          color: seleccionada
                              ? const Color(0xFFE8651A).withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: seleccionada
                              ? const Color(0xFFE8651A)
                              : Colors.grey.shade400,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dir['barrio'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: seleccionada
                                    ? const Color(0xFFE8651A)
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              dir['direccion'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (seleccionada)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFE8651A),
                          size: 18,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey.shade300,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
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
                  'Paso 3 de 4',
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
          _paso(2, 'Complementos', false, completado: true),
          _lineaPaso(completado: true),
          _paso(3, 'Dirección', true),
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
