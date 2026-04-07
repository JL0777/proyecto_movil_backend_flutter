import 'package:flutter/material.dart';
import '../../../services/ventas_service.dart';

class HistorialPedidosScreen extends StatefulWidget {
  const HistorialPedidosScreen({super.key});

  @override
  State<HistorialPedidosScreen> createState() =>
      _HistorialPedidosScreenState();
}

class _HistorialPedidosScreenState extends State<HistorialPedidosScreen> {
  final VentasService _service = VentasService();

  List<dynamic> _pedidos = [];
  Map<String, dynamic>? _resumen;
  bool _loading = false;
  bool _buscado = false;

  // Filtros
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _estado;
  String? _tipo;
  String? _metodoPago;

  final List<String> _estados = [
    'Todos', 'Pendiente', 'Activo', 'Realizado', 'Enviado'
  ];
  final List<String> _tipos = ['Todos', 'predefinido', 'personalizado'];
  final List<String> _metodos = ['Todos', 'pse', 'contraentrega'];

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return Colors.grey;
      case 'Activo': return Colors.orange;
      case 'Realizado': return Colors.green;
      case 'Enviado': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Future<void> _buscar() async {
    setState(() {
      _loading = true;
      _buscado = true;
    });

    try {
      final data = await _service.getHistorial(
        fechaInicio: _fechaInicio != null
            ? '${_fechaInicio!.year}-${_fechaInicio!.month.toString().padLeft(2, '0')}-${_fechaInicio!.day.toString().padLeft(2, '0')}'
            : null,
        fechaFin: _fechaFin != null
            ? '${_fechaFin!.year}-${_fechaFin!.month.toString().padLeft(2, '0')}-${_fechaFin!.day.toString().padLeft(2, '0')}'
            : null,
        estado: _estado == 'Todos' ? null : _estado,
        tipo: _tipo == 'Todos' ? null : _tipo,
        metodoPago: _metodoPago == 'Todos' ? null : _metodoPago,
      );

      setState(() {
        _pedidos = data['pedidos'] ?? [];
        _resumen = data['resumen'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE8651A),
          ),
        ),
        child: child!,
      ),
    );

    if (fecha != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = fecha;
        } else {
          _fechaFin = fecha;
        }
      });
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _estado = null;
      _tipo = null;
      _metodoPago = null;
      _pedidos = [];
      _resumen = null;
      _buscado = false;
    });
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de pedidos'),
        backgroundColor: const Color(0xFFE8651A),
        foregroundColor: Colors.white,
        actions: [
          if (_buscado)
            TextButton(
              onPressed: _limpiarFiltros,
              child: const Text(
                'Limpiar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _seleccionarFecha(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _fechaInicio != null
                                  ? const Color(0xFFE8651A)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: _fechaInicio != null
                                    ? const Color(0xFFE8651A)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _fechaInicio != null
                                    ? _formatFecha(_fechaInicio!)
                                    : 'Fecha inicio',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _fechaInicio != null
                                      ? const Color(0xFFE8651A)
                                      : Colors.grey,
                                  fontWeight: _fechaInicio != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('—',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _seleccionarFecha(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _fechaFin != null
                                  ? const Color(0xFFE8651A)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: _fechaFin != null
                                    ? const Color(0xFFE8651A)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _fechaFin != null
                                    ? _formatFecha(_fechaFin!)
                                    : 'Fecha fin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _fechaFin != null
                                      ? const Color(0xFFE8651A)
                                      : Colors.grey,
                                  fontWeight: _fechaFin != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Dropdowns en fila
                Row(
                  children: [
                    Expanded(child: _dropdown(
                      value: _estado ?? 'Todos',
                      items: _estados,
                      onChanged: (v) => setState(() => _estado = v),
                      hint: 'Estado',
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdown(
                      value: _tipo ?? 'Todos',
                      items: _tipos,
                      onChanged: (v) => setState(() => _tipo = v),
                      hint: 'Tipo',
                      labelMap: {
                        'predefinido': 'Predefinido',
                        'personalizado': 'Personalizado',
                        'Todos': 'Todos',
                      },
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdown(
                      value: _metodoPago ?? 'Todos',
                      items: _metodos,
                      onChanged: (v) => setState(() => _metodoPago = v),
                      hint: 'Pago',
                      labelMap: {
                        'pse': 'PSE',
                        'contraentrega': 'Contraentrega',
                        'Todos': 'Todos',
                      },
                    )),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _buscar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search, size: 18),
                    label: Text(_loading ? 'Buscando...' : 'Buscar'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Resumen si hay resultados
          if (_resumen != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              color: const Color(0xFFFFF3ED),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resumenItem(
                    '${_resumen!['totalPedidos']}',
                    'Pedidos',
                    Icons.receipt_long_outlined,
                    const Color(0xFFE8651A),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFE8651A).withValues(alpha: 0.2),
                  ),
                  _resumenItem(
                    '\$${double.parse(_resumen!['totalIngresos'].toString()).toStringAsFixed(0)}',
                    'Ingresos',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFE8651A).withValues(alpha: 0.2),
                  ),
                  _resumenItem(
                    '\$${double.parse(_resumen!['totalIva'].toString()).toStringAsFixed(0)}',
                    'IVA',
                    Icons.percent,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Lista de pedidos
          Expanded(
            child: !_buscado
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Aplica filtros y toca Buscar',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFE8651A)),
                      )
                    : _pedidos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 60,
                                    color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay pedidos con esos filtros',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 20),
                            itemCount: _pedidos.length,
                            itemBuilder: (context, index) {
                              final p = _pedidos[index];
                              final usuario = p['Usuario'];
                              final total = double.parse(
                                  p['total'].toString());
                              final fecha = p['createdAt']
                                      ?.toString()
                                      .substring(0, 10) ??
                                  '';
                              final estado = p['estado'] ?? '';
                              final tipo = p['tipo'] ?? '';
                              final metodoPago =
                                  p['metodoPago'] ?? '';
                              final colorEstado =
                                  _colorEstado(estado);
                              final fotoPerfil =
                                  usuario?['fotoPerfil'];

                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFE8651A)
                                              .withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: fotoPerfil != null &&
                                                fotoPerfil
                                                    .toString()
                                                    .isNotEmpty
                                            ? Image.network(
                                                fotoPerfil,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_,
                                                        __,
                                                        ___) =>
                                                    _placeholder(),
                                              )
                                            : _placeholder(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            usuario?['nombre'] ??
                                                'Sin nombre',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 11,
                                                color:
                                                    Colors.grey.shade400,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                fecha,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      Colors.grey.shade500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                tipo == 'personalizado'
                                                    ? Icons.tune_outlined
                                                    : Icons.restaurant_menu_outlined,
                                                size: 11,
                                                color:
                                                    Colors.grey.shade400,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                tipo == 'personalizado'
                                                    ? 'Personal.'
                                                    : 'Predef.',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      Colors.grey.shade500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                metodoPago == 'pse'
                                                    ? Icons.account_balance_outlined
                                                    : Icons.payments_outlined,
                                                size: 11,
                                                color:
                                                    Colors.grey.shade400,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                metodoPago == 'pse'
                                                    ? 'PSE'
                                                    : 'Contrent.',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Total y estado
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${total.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFE8651A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: colorEstado
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: colorEstado
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            estado,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: colorEstado,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFFF3ED),
      child: const Icon(Icons.person,
          color: Color(0xFFE8651A), size: 24),
    );
  }

  Widget _resumenItem(
      String valor, String label, IconData icono, Color color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
    Map<String, String>? labelMap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value != 'Todos'
              ? const Color(0xFFE8651A)
              : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          style: TextStyle(
            fontSize: 11,
            color: value != 'Todos'
                ? const Color(0xFFE8651A)
                : Colors.black87,
            fontWeight: value != 'Todos'
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      labelMap != null
                          ? (labelMap[e] ?? e)
                          : e,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}