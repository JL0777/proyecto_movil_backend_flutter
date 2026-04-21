import 'package:flutter/material.dart';

class PedidoCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final int numero;
  final Function(int, String) onCambiarEstado;
  final Function(Map<String, dynamic>, int) onVerPedido;
  final Function(Map<String, dynamic>, int) onVerCliente;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.numero,
    required this.onCambiarEstado,
    required this.onVerPedido,
    required this.onVerCliente,
  });

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

  List<String> _estadosDisponibles(String estadoActual) {
    switch (estadoActual) {
      case 'Pendiente': return ['Pendiente', 'Activo'];
      case 'Activo':    return ['Activo', 'Realizado'];
      case 'Realizado': return ['Realizado', 'Enviado'];
      default:          return [estadoActual];
    }
  }

  Widget _miniPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.fastfood_outlined,
          color: Colors.grey.shade400, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = pedido['estado'];
    final tipo = pedido['tipo'] ?? 'predefinido';
    final detalles = pedido['DetallePedidos'] as List? ?? [];
    final usuario = pedido['Usuario'];
    final colorEstado = _colorEstado(estado);
    final estadosDisponibles = _estadosDisponibles(estado);

    String? imagenUrl;
    if (tipo == 'predefinido' &&
        detalles.isNotEmpty &&
        detalles.first['Menu'] != null) {
      imagenUrl = detalles.first['Menu']['imagenUrl'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // ── Header ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_iconoEstado(estado),
                        color: colorEstado, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pedido #$numero',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: colorEstado.withValues(alpha: 0.4)),
                  ),
                  child: estadosDisponibles.length > 1
                      ? DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: estado,
                            isDense: true,
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: colorEstado, size: 16),
                            items: estadosDisponibles
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          color: _colorEstado(e),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (nuevoEstado) {
                              if (nuevoEstado != null &&
                                  nuevoEstado != estado) {
                                onCambiarEstado(pedido['id'], nuevoEstado);
                              }
                            },
                          ),
                        )
                      : Text(
                          estado,
                          style: TextStyle(
                            color: colorEstado,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── Cuerpo ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imagenUrl != null && imagenUrl.isNotEmpty
                      ? Image.network(
                          imagenUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _miniPlaceholder(),
                        )
                      : _miniPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              usuario?['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            tipo == 'personalizado'
                                ? Icons.tune_outlined
                                : Icons.restaurant_menu_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tipo == 'personalizado'
                                  ? 'Personalizado'
                                  : detalles.isNotEmpty &&
                                          detalles.first['Menu'] != null
                                      ? detalles.first['Menu']['nombre']
                                      : 'Predefinido',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Botones ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onVerCliente(pedido, numero),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: Icon(Icons.person_outline,
                        size: 16, color: Colors.grey.shade600),
                    label: Text('Cliente',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onVerPedido(pedido, numero),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE8651A)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.receipt_outlined,
                        size: 16, color: Color(0xFFE8651A)),
                    label: const Text('Ver pedido',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFFE8651A))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}