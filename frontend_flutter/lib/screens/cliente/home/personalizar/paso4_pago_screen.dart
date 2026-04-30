import 'package:flutter/material.dart';
import '../../../../services/pedido_service.dart';

class Paso4PagoScreen extends StatefulWidget {
  final Map<String, dynamic> categoria;
  final Map<String, dynamic> ingredientes;
  final Map<String, dynamic> bebida;
  final Map<String, Map<String, dynamic>> complementos;
  final Map<String, dynamic> direccion;
  final double subtotal;

  const Paso4PagoScreen({
    super.key,
    required this.categoria,
    required this.ingredientes,
    required this.bebida,
    required this.complementos,
    required this.direccion,
    required this.subtotal,
  });

  @override
  State<Paso4PagoScreen> createState() => _Paso4PagoScreenState();
}

class _Paso4PagoScreenState extends State<Paso4PagoScreen> {
  final PedidoService _service = PedidoService();

  String _metodoPago = 'contraentrega';
  bool _loading = false;

  double get _subtotal => widget.subtotal / 1.19;
  double get _iva => widget.subtotal - _subtotal;
  double get _total => widget.subtotal;

  List<Map<String, dynamic>> _buildItems() {
    final items = <Map<String, dynamic>>[];

    for (final entry in widget.ingredientes.entries) {
      if (entry.value != null) {
        items.add({'ingredienteId': entry.value!['id'], 'cantidad': 1});
      }
    }

    if (widget.bebida.isNotEmpty && widget.bebida['id'] != null) {
      items.add({'ingredienteId': widget.bebida['id'], 'cantidad': 1});
    }

    for (final entry in widget.complementos.entries) {
      items.add({
        'ingredienteId': int.parse(entry.key),
        'cantidad': entry.value['cantidad'],
      });
    }

    return items;
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _confirmar() async {
    setState(() => _loading = true);

    final result = await _service.create({
      'direccionId': widget.direccion['id'],
      'tipo': 'personalizado',
      'metodoPago': _metodoPago,
      'items': _buildItems(),
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _mostrarExito();
    } else {
      _mostrarError(result['error'] ?? 'Error al crear el pedido');
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡HEMOS CREADO TU\nORDEN CON ÉXITO!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puedes revisar su estado en la pestaña',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text(
                  'Mis órdenes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE8651A),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFE8651A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
          _buildHeader(),
          _buildPasos(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Resumen del pedido ──
                  _buildResumenPedido(),
                  const SizedBox(height: 16),

                  // ── Dirección seleccionada ──
                  _buildResumenDireccion(),
                  const SizedBox(height: 16),

                  // ── Método de pago ──
                  _buildSeccionMetodoPago(),
                  const SizedBox(height: 16),

                  // ── Datos PSE ──
                  if (_metodoPago == 'pse') ...[
                    _buildSeccionPSE(),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 80),
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
                    Text('Total',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    Text(
                      '\$${_total.toStringAsFixed(0)}',
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
                    onPressed: _loading ? null : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFE8651A).withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Confirmar pedido',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
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

  // ── Resumen del pedido ─────────────────────────────────────

  Widget _buildResumenPedido() {
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
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8651A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    color: Color(0xFFE8651A), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Resumen del pedido',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cabecera tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Producto',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8651A),
                          fontSize: 11)),
                ),
                Expanded(
                  child: Text('Cant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8651A),
                          fontSize: 11)),
                ),
                Expanded(
                  child: Text('Total',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8651A),
                          fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Ingredientes
          ...widget.ingredientes.entries
              .where((e) => e.value != null)
              .map((e) => _filaResumen(
                    '${e.value!['nombre']} (${e.value!['cantidad'] ?? ''})',
                    1,
                    double.parse(e.value!['precio'].toString()),
                  )),

          // Bebida
          if (widget.bebida.isNotEmpty && widget.bebida['nombre'] != null)
            _filaResumen(
              '${widget.bebida['nombre']} (${widget.bebida['cantidad'] ?? ''})',
              1,
              double.parse(widget.bebida['precio'].toString()),
            ),

          // Complementos
          ...widget.complementos.entries.map((e) => _filaResumen(
                e.value['nombre']?.toString() ?? 'Complemento',
                e.value['cantidad'] ?? 1,
                0,
              )),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 8),

          // Totales
          _filaTotalRow('Subtotal', _subtotal),
          const SizedBox(height: 4),
          _filaTotalRow('IVA', _iva),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFE8651A).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87)),
                Text(
                  '\$${_total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE8651A)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 13, color: Colors.orange.shade600),
              const SizedBox(width: 5),
              Text(
                'El domicilio no va incluido en tu pedido',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Resumen dirección ──────────────────────────────────────

  Widget _buildResumenDireccion() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFE8651A).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFE8651A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: Color(0xFFE8651A), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dirección de envío',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8651A)),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.direccion['barrio'] ?? '',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                Text(
                  widget.direccion['direccion'] ?? '',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle,
              color: Color(0xFFE8651A), size: 18),
        ],
      ),
    );
  }

  // ── Sección método de pago ─────────────────────────────────

  Widget _buildSeccionMetodoPago() {
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
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment_outlined,
                    color: Colors.purple, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Método de pago',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _metodoPagoTile(
            valor: 'contraentrega',
            label: 'Pago contraentrega',
            descripcion: 'Paga en efectivo al recibir tu pedido',
            icono: Icons.payments_outlined,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _metodoPagoTile(
            valor: 'pse',
            label: 'PSE',
            descripcion: 'Transferencia bancaria en línea',
            icono: Icons.account_balance_outlined,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _metodoPagoTile({
    required String valor,
    required String label,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    final seleccionado = _metodoPago == valor;
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado
                ? color.withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: seleccionado
                    ? color.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono,
                  color: seleccionado ? color : Colors.grey.shade400,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: seleccionado ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    descripcion,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seleccionado ? color : Colors.transparent,
                border: Border.all(
                  color:
                      seleccionado ? color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: seleccionado
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sección PSE ────────────────────────────────────────────

  Widget _buildSeccionPSE() {
    return Column(
      children: [
        // Datos bancarios
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
                    child: const Icon(Icons.account_balance_outlined,
                        color: Colors.blue, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Datos para transferencia',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _datosBancoTile('Banco', 'Bancolombia'),
              _datosBancoTile('Tipo de cuenta', 'Ahorros'),
              _datosBancoTile('Número de cuenta', '123-456789-00'),
              _datosBancoTile('Titular', 'MyMeal S.A.S'),
              _datosBancoTile('NIT', '900.123.456-7'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          const Color(0xFFE8651A).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a transferir',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    Text('\$${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE8651A))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Aviso comprobante
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Recuerda mostrar el comprobante al domiciliario. De lo contrario el pedido no será entregado.',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _datosBancoTile(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(String nombre, int cantidad, double precio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(nombre,
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ),
          Expanded(
            child: Text('$cantidad',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              precio == 0 ? 'Gratis' : '\$${precio.toStringAsFixed(0)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: precio == 0
                      ? Colors.green
                      : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaTotalRow(String label, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
          Text('\$${valor.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

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
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
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
                  'Paso 4 de 4',
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
          _paso(3, 'Dirección', false, completado: true),
          _lineaPaso(completado: true),
          _paso(4, 'Pago', true),
        ],
      ),
    );
  }

  Widget _paso(int numero, String label, bool activo,
      {bool completado = false}) {
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
            fontWeight:
                activo || completado ? FontWeight.w700 : FontWeight.normal,
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