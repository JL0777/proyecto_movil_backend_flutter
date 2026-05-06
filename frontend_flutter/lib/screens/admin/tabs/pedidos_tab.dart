import 'package:flutter/material.dart';
import '../../../services/pedido_service.dart';

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab> {
  final PedidoService _service = PedidoService();
  List<dynamic> _pedidos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getAll();
      setState(() {
        _pedidos = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _mostrarInfoCliente(Map<String, dynamic> pedido, int numero) {
    final usuario = pedido['Usuario'];
    final direccion = pedido['Direccion'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Info. del Cliente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE8651A),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            usuario?['fotoPerfil'] != null &&
                                usuario!['fotoPerfil'].toString().isNotEmpty
                            ? Image.network(
                                usuario['fotoPerfil'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, _) => Container(
                                  color: const Color(0xFFFFF3ED),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFFE8651A),
                                    size: 32,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFFFF3ED),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFFE8651A),
                                  size: 32,
                                ),
                              ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Pedido #$numero',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                _seccion('Contacto'),
                const SizedBox(height: 8),
                _infoChip(
                  Icons.email_outlined,
                  usuario?['email'] ?? 'Sin correo',
                ),
                const SizedBox(height: 6),
                _infoChip(
                  Icons.phone_outlined,
                  usuario?['telefono'] ?? 'Sin teléfono',
                ),

                const SizedBox(height: 16),

                _seccion('Dirección de entrega'),
                const SizedBox(height: 8),
                _infoChip(
                  Icons.location_on_outlined,
                  direccion?['direccion'] ?? 'Sin dirección',
                ),
                const SizedBox(height: 6),
                _infoChip(
                  Icons.map_outlined,
                  'Barrio: ${direccion?['barrio'] ?? 'Sin barrio'}',
                ),
                const SizedBox(height: 6),
                _infoChip(
                  Icons.home_outlined,
                  direccion?['tipoVivienda'] ?? 'No especificado',
                ),
                if (direccion?['instrucciones'] != null &&
                    direccion!['instrucciones'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _infoChip(Icons.info_outline, direccion['instrucciones']),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarInfoPedido(pedido, numero);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: const Text(
                      'Ver detalle del pedido',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarInfoPedido(Map<String, dynamic> pedido, int numero) {
    final detalles = pedido['DetallePedidos'] as List? ?? [];
    final total = double.parse(pedido['total'].toString());
    final subtotal = double.parse(pedido['subtotal'].toString());
    final iva = double.parse(pedido['iva'].toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.82,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        Navigator.pop(context);
                        _mostrarInfoCliente(pedido, numero);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pedido #$numero',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _badge(
                      pedido['tipo'] == 'personalizado'
                          ? 'Personalizado'
                          : 'Predefinido',
                      pedido['tipo'] == 'personalizado'
                          ? Icons.tune_outlined
                          : Icons.restaurant_menu_outlined,
                      const Color(0xFFE8651A),
                    ),
                    const SizedBox(width: 8),
                    _badge(
                      pedido['metodoPago'] == 'pse' ? 'PSE' : 'Contraentrega',
                      pedido['metodoPago'] == 'pse'
                          ? Icons.account_balance_outlined
                          : Icons.payments_outlined,
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _seccion('Productos'),
                const SizedBox(height: 8),

                ...detalles.map((d) {
                  final nombre = d['Menu'] != null
                      ? d['Menu']['nombre']
                      : d['Ingrediente'] != null
                      ? d['Ingrediente']['nombre']
                      : 'Producto';
                  final cantidad = d['cantidad'] ?? 1;
                  final precio = double.parse(d['precioUnitario'].toString());

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8651A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$nombre x$cantidad',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(precio * cantidad).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8651A).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _filaTotal(
                        'Subtotal',
                        '\$${subtotal.toStringAsFixed(0)}',
                        false,
                      ),
                      const SizedBox(height: 4),
                      _filaTotal(
                        'IVA (inc.)',
                        '\$${iva.toStringAsFixed(0)}',
                        false,
                      ),
                      const Divider(),
                      _filaTotal(
                        'Total',
                        '\$${total.toStringAsFixed(0)}',
                        true,
                      ),
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

  Widget _seccion(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 30, height: 2, color: const Color(0xFFE8651A)),
      ],
    );
  }

  Widget _infoChip(IconData icono, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 16, color: const Color(0xFFE8651A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _badge(String label, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaTotal(String label, String valor, bool destacado) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: destacado ? 15 : 13,
            fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
            color: destacado ? Colors.black87 : Colors.black54,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: destacado ? 16 : 13,
            fontWeight: destacado ? FontWeight.w800 : FontWeight.w500,
            color: destacado ? const Color(0xFFE8651A) : Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8651A)),
      );
    }

    if (_pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining_outlined,
                color: Colors.blue,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay pedidos enviados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Los pedidos enviados aparecerán aquí',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: const Color(0xFFE8651A),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          final pedido = _pedidos[index];
          final numero = index + 1;
          final usuario = pedido['Usuario'];
          final total = double.parse(pedido['total'].toString());
          final subtotal = double.parse(pedido['subtotal'].toString());
          final fecha = pedido['createdAt']?.toString().substring(0, 10) ?? '';
          final tipo = pedido['tipo'] ?? 'predefinido';
          final detalles = pedido['DetallePedidos'] as List? ?? [];

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.delivery_dining_outlined,
                            color: Colors.blue,
                            size: 18,
                          ),
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
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'Enviado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, _) =>
                                    _placeholder(),
                              )
                            : _placeholder(),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario?['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fecha,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Subtotal: \$${subtotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE8651A),
                            ),
                          ),
                          Text(
                            'total',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _mostrarInfoCliente(pedido, numero),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          label: Text(
                            'Cliente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _mostrarInfoPedido(pedido, numero),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8651A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(
                            Icons.receipt_outlined,
                            size: 16,
                            color: Color(0xFFE8651A),
                          ),
                          label: const Text(
                            'Ver pedido',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE8651A),
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
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.fastfood_outlined,
        color: Colors.grey.shade400,
        size: 30,
      ),
    );
  }
}
