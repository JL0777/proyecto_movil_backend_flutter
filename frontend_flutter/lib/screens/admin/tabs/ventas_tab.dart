import 'package:flutter/material.dart';
import '../../../services/ventas_service.dart';

class VentasTab extends StatefulWidget {
  const VentasTab({super.key});

  @override
  State<VentasTab> createState() => _VentasTabState();
}

class _VentasTabState extends State<VentasTab> {
  final VentasService _service = VentasService();
  Map<String, dynamic>? _reporte;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getReporte();
      setState(() {
        _reporte = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8651A)),
      );
    }

    if (_reporte == null) {
      return const Center(
        child: Text('Error cargando reporte'),
      );
    }

    final totalPedidos = _reporte!['totalPedidos'] ?? 0;
    final totalClientes = _reporte!['totalClientes'] ?? 0;
    final ingresos = _reporte!['ingresos'];
    final totalIngresos = ingresos != null && ingresos['totalIngresos'] != null
        ? double.parse(ingresos['totalIngresos'].toString())
        : 0.0;
    final totalIva = ingresos != null && ingresos['totalIva'] != null
        ? double.parse(ingresos['totalIva'].toString())
        : 0.0;

    final porEstado = _reporte!['porEstado'] as List? ?? [];
    final porTipo = _reporte!['porTipo'] as List? ?? [];
    final porMetodoPago = _reporte!['porMetodoPago'] as List? ?? [];
    final ultimosPedidos = _reporte!['ultimosPedidos'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _cargar,
      color: const Color(0xFFE8651A),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Tarjetas principales
          Row(
            children: [
              Expanded(
                child: _tarjetaStat(
                  icono: Icons.receipt_long_outlined,
                  titulo: 'Total pedidos',
                  valor: '$totalPedidos',
                  color: const Color(0xFFE8651A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tarjetaStat(
                  icono: Icons.people_outline,
                  titulo: 'Clientes',
                  valor: '$totalClientes',
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _tarjetaStat(
                  icono: Icons.attach_money,
                  titulo: 'Ingresos totales',
                  valor: '\$${totalIngresos.toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tarjetaStat(
                  icono: Icons.percent,
                  titulo: 'IVA recaudado',
                  valor: '\$${totalIva.toStringAsFixed(0)}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Por estado
          _seccion('Estado de pedidos'),
          const SizedBox(height: 8),
          ...porEstado.map((e) => _barraItem(
                label: e['estado'],
                total: int.parse(e['total'].toString()),
                totalMax: totalPedidos,
                color: e['estado'] == 'Enviado' ? Colors.blue : Colors.green,
              )),

          const SizedBox(height: 20),

          // Por tipo
          _seccion('Tipo de pedidos'),
          const SizedBox(height: 8),
          ...porTipo.map((e) => _barraItem(
                label: e['tipo'] == 'personalizado'
                    ? 'Personalizado'
                    : 'Predefinido',
                total: int.parse(e['total'].toString()),
                totalMax: totalPedidos,
                color: e['tipo'] == 'personalizado'
                    ? const Color(0xFFE8651A)
                    : Colors.blue,
              )),

          const SizedBox(height: 20),

          // Por método de pago
          _seccion('Método de pago'),
          const SizedBox(height: 8),
          ...porMetodoPago.map((e) => _barraItem(
                label: e['metodoPago'] == 'pse' ? 'PSE' : 'Contraentrega',
                total: int.parse(e['total'].toString()),
                totalMax: totalPedidos,
                color: e['metodoPago'] == 'pse' ? Colors.purple : Colors.teal,
              )),

          const SizedBox(height: 20),

          // Últimos pedidos
          _seccion('Últimos pedidos'),
          const SizedBox(height: 8),

          ...ultimosPedidos.map((p) {
            final usuario = p['Usuario'];
            final total = double.parse(p['total'].toString());
            final fecha = p['createdAt']?.toString().substring(0, 10) ?? '';
            final estado = p['estado'] ?? 'Realizado';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: Color(0xFFE8651A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          fecha,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8651A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: estado == 'Enviado'
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          estado,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: estado == 'Enviado'
                                ? Colors.blue
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _tarjetaStat({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          color: const Color(0xFFE8651A),
        ),
      ],
    );
  }

  Widget _barraItem({
    required String label,
    required int total,
    required int totalMax,
    required Color color,
  }) {
    final porcentaje = totalMax > 0 ? total / totalMax : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$total pedidos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}