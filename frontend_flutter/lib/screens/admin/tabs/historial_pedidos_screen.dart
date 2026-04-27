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
      case 'Activo':    return const Color(0xFFE8651A);
      case 'Realizado': return Colors.green;
      case 'Enviado':   return Colors.blue;
      default:          return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return Icons.hourglass_empty_outlined;
      case 'Activo':    return Icons.restaurant_outlined;
      case 'Realizado': return Icons.check_circle_outline;
      case 'Enviado':   return Icons.delivery_dining_outlined;
      default:          return Icons.receipt_outlined;
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
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE8651A),
        foregroundColor: Colors.white,
        title: const Text(
          'Historial de Pedidos',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (_buscado)
            TextButton.icon(
              onPressed: _limpiarFiltros,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: const Text(
                'Limpiar',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Panel de filtros ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título filtros
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3ED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.filter_list,
                            color: Color(0xFFE8651A), size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filtros de búsqueda',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fechas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _fechaSelector(
                          label: _fechaInicio != null
                              ? _formatFecha(_fechaInicio!)
                              : 'Fecha inicio',
                          activo: _fechaInicio != null,
                          onTap: () => _seleccionarFecha(true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward,
                            size: 14, color: Colors.grey.shade400),
                      ),
                      Expanded(
                        child: _fechaSelector(
                          label: _fechaFin != null
                              ? _formatFecha(_fechaFin!)
                              : 'Fecha fin',
                          activo: _fechaFin != null,
                          onTap: () => _seleccionarFecha(false),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Dropdowns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _dropdown(
                          value: _estado ?? 'Todos',
                          items: _estados,
                          onChanged: (v) => setState(() => _estado = v),
                          hint: 'Estado',
                          icono: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dropdown(
                          value: _tipo ?? 'Todos',
                          items: _tipos,
                          onChanged: (v) => setState(() => _tipo = v),
                          hint: 'Tipo',
                          icono: Icons.restaurant_menu_outlined,
                          labelMap: {
                            'predefinido': 'Predef.',
                            'personalizado': 'Person.',
                            'Todos': 'Todos',
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dropdown(
                          value: _metodoPago ?? 'Todos',
                          items: _metodos,
                          onChanged: (v) => setState(() => _metodoPago = v),
                          hint: 'Pago',
                          icono: Icons.payment_outlined,
                          labelMap: {
                            'pse': 'PSE',
                            'contraentrega': 'Contrent.',
                            'Todos': 'Todos',
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Botón buscar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _buscar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8651A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFE8651A).withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Buscar pedidos',
                                  style: TextStyle(
                                    fontSize: isSmall ? 13 : 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Resumen ──
          if (_resumen != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8651A).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _resumenItem(
                    '${_resumen!['totalPedidos']}',
                    'Pedidos',
                    Icons.receipt_long_outlined,
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3)),
                  _resumenItem(
                    '\$${double.parse(_resumen!['totalIngresos'].toString()).toStringAsFixed(0)}',
                    'Ingresos',
                    Icons.attach_money,
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3)),
                  _resumenItem(
                    '\$${double.parse(_resumen!['totalIva'].toString()).toStringAsFixed(0)}',
                    'IVA',
                    Icons.percent,
                  ),
                ],
              ),
            ),

          // ── Lista ──
          Expanded(
            child: !_buscado
                ? _estadoVacio(
                    icono: Icons.manage_search_outlined,
                    titulo: 'Busca tus pedidos',
                    subtitulo: 'Aplica filtros y toca Buscar',
                  )
                : _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFE8651A)),
                      )
                    : _pedidos.isEmpty
                        ? _estadoVacio(
                            icono: Icons.inbox_outlined,
                            titulo: 'Sin resultados',
                            subtitulo: 'No hay pedidos con esos filtros',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 24),
                            itemCount: _pedidos.length,
                            itemBuilder: (context, index) =>
                                _pedidoCard(_pedidos[index], isSmall),
                          ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────

  Widget _pedidoCard(Map<String, dynamic> p, bool isSmall) {
    final usuario = p['Usuario'];
    final total = double.parse(p['total'].toString());
    final fecha = p['createdAt']?.toString().substring(0, 10) ?? '';
    final estado = p['estado'] ?? '';
    final tipo = p['tipo'] ?? '';
    final metodoPago = p['metodoPago'] ?? '';
    final colorEstado = _colorEstado(estado);
    final fotoPerfil = usuario?['fotoPerfil'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con estado
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_iconoEstado(estado),
                        size: 14, color: colorEstado),
                    const SizedBox(width: 5),
                    Text(
                      estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      fecha,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Cuerpo
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: isSmall ? 38 : 44,
                  height: isSmall ? 38 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          const Color(0xFFE8651A).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: fotoPerfil != null &&
                            fotoPerfil.toString().isNotEmpty
                        ? Image.network(
                            fotoPerfil,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                const SizedBox(width: 12),

                // Info usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario?['nombre'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _tag(
                            tipo == 'personalizado'
                                ? 'Personalizado'
                                : 'Predefinido',
                            tipo == 'personalizado'
                                ? Icons.tune_outlined
                                : Icons.restaurant_menu_outlined,
                            Colors.purple,
                          ),
                          _tag(
                            metodoPago == 'pse' ? 'PSE' : 'Contraentrega',
                            metodoPago == 'pse'
                                ? Icons.account_balance_outlined
                                : Icons.payments_outlined,
                            Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isSmall ? 14 : 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE8651A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'total',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fechaSelector({
    required String label,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: activo
              ? const Color(0xFFFFF3ED)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo
                ? const Color(0xFFE8651A)
                : Colors.grey.shade300,
            width: activo ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: activo
                  ? const Color(0xFFE8651A)
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: activo
                      ? const Color(0xFFE8651A)
                      : Colors.grey.shade500,
                  fontWeight: activo
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoVacio({
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              shape: BoxShape.circle,
            ),
            child: Icon(icono,
                size: 40, color: const Color(0xFFE8651A)),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitulo,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFFF3ED),
      child:
          const Icon(Icons.person, color: Color(0xFFE8651A), size: 24),
    );
  }

  Widget _resumenItem(String valor, String label, IconData icono) {
    return Column(
      children: [
        Icon(icono, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
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
    required IconData icono,
    Map<String, String>? labelMap,
  }) {
    final activo = value != 'Todos';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: activo
            ? const Color(0xFFFFF3ED)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: activo
              ? const Color(0xFFE8651A)
              : Colors.grey.shade300,
          width: activo ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: activo
                ? const Color(0xFFE8651A)
                : Colors.grey.shade400,
          ),
          style: TextStyle(
            fontSize: 11,
            color: activo
                ? const Color(0xFFE8651A)
                : Colors.black87,
            fontWeight:
                activo ? FontWeight.w700 : FontWeight.normal,
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      labelMap != null ? (labelMap[e] ?? e) : e,
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