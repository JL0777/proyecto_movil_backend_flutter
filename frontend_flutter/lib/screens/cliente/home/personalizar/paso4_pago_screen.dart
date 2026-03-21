import 'package:flutter/material.dart';
import '../../../../services/pedido_service.dart';

class Paso4PagoScreen extends StatefulWidget {
  final Map<String, dynamic> categoria;
  final Map<String, dynamic> ingredientes;
  final Map<String, dynamic> bebida;
  final Map<String, Map<String, int>> complementos;
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

  double get _iva => widget.subtotal - (widget.subtotal / 1.19);
  double get _total => widget.subtotal;

  List<Map<String, dynamic>> _buildItems() {
    final items = <Map<String, dynamic>>[];

    for (final entry in widget.ingredientes.entries) {
      if (entry.value != null) {
        items.add({'ingredienteId': entry.value!['id'], 'cantidad': 1});
      }
    }

    items.add({'ingredienteId': widget.bebida['id'], 'cantidad': 1});

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
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
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
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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
      body: Column(
        children: [
          _buildHeader(),
          _buildPasos(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAGO',
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

                  // Resumen
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Producto',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE8651A),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Cant.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE8651A),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Total',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE8651A),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),

                        ...widget.ingredientes.entries
                            .where((e) => e.value != null)
                            .map(
                              (e) => _filaResumen(
                                '${e.value!['nombre']} (${e.value!['cantidad'] ?? ''})',
                                1,
                                double.parse(e.value!['precio'].toString()),
                              ),
                            ),

                        _filaResumen(
                          '${widget.bebida['nombre']} (${widget.bebida['cantidad'] ?? ''})',
                          1,
                          double.parse(widget.bebida['precio'].toString()),
                        ),

                        ...widget.complementos.entries.map(
                          (e) => _filaResumen(
                            'Complemento',
                            e.value['cantidad'] ?? 1,
                            0,
                          ),
                        ),

                        const Divider(),
                        _filaTotal('Subtotal', widget.subtotal),
                        const SizedBox(height: 4),
                        _filaTotal('IVA (inc.)', _iva),
                        const SizedBox(height: 4),
                        _filaTotal('Total', _total, destacado: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'El domicilio no va incluido en tu pedido',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Método de pago
                  const Text(
                    'Escoge el método de pago',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8651A),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _metodoPagoOption('pse', 'PSE'),
                  const SizedBox(height: 8),
                  _metodoPagoOption('contraentrega', 'Pago contraentrega'),

                  // Datos PSE — solo info bancaria y aviso
                  if (_metodoPago == 'pse') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Datos para transferencia PSE',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 3,
                      color: const Color(0xFFE8651A),
                    ),
                    const SizedBox(height: 16),

                    // Info banco destino
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8651A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFFE8651A),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Datos de transferencia',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE8651A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _datosBanco('Banco:', 'Bancolombia'),
                          _datosBanco('Tipo de cuenta:', 'Ahorros'),
                          _datosBanco('Número de cuenta:', '123-456789-00'),
                          _datosBanco('Titular:', 'MyMeal S.A.S'),
                          _datosBanco('NIT:', '900.123.456-7'),
                          const SizedBox(height: 8),
                          Text(
                            'Total a transferir: \$${_total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE8651A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Aviso comprobante
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Recuerda mostrar el comprobante al domiciliario. De lo contrario el pedido no será entregado.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8651A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(
                    0xFFE8651A,
                  ).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datosBanco(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valor,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(String nombre, int cantidad, double precio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              nombre,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              precio == 0 ? '\$0' : '\$${precio.toStringAsFixed(0)}',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaTotal(String label, double valor, {bool destacado = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: destacado ? 15 : 13,
            fontWeight: destacado ? FontWeight.w800 : FontWeight.w500,
            color: destacado ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        Text(
          '\$${valor.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: destacado ? 15 : 13,
            fontWeight: destacado ? FontWeight.w800 : FontWeight.w500,
            color: destacado ? const Color(0xFFE8651A) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _metodoPagoOption(String valor, String label) {
    final seleccionado = _metodoPago == valor;
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = valor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seleccionado
                  ? const Color(0xFFE8651A)
                  : Colors.grey.shade200,
              border: Border.all(
                color: seleccionado
                    ? const Color(0xFFE8651A)
                    : Colors.grey.shade400,
              ),
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
          _paso(2, 'Complementos', false),
          _lineaPaso(),
          _paso(3, 'Dirección', false),
          _lineaPaso(),
          _paso(4, 'Pago', true),
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
