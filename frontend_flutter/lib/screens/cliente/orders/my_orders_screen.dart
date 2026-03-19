import 'package:flutter/material.dart';
import '../../../services/pedido_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  final PedidoService _service = PedidoService();
  List<dynamic> _pedidos = [];
  bool _loading = true;
  late TabController _tabController;
  final Set<int> _expandidos = {};

  final List<String> _tabs = [
    'Todos',
    'Pendiente',
    'Activo',
    'Realizado',
    'Enviado',
  ];

  List<dynamic> _filtrados(String tab) {
    if (tab == 'Todos') return _pedidos;
    return _pedidos.where((p) => p['estado'] == tab).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getMisPedidos();
      setState(() {
        _pedidos = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.grey;
      case 'Activo':
        return Colors.orange;
      case 'Realizado':
        return Colors.green;
      case 'Enviado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Icons.hourglass_empty_outlined;
      case 'Activo':
        return Icons.restaurant_outlined;
      case 'Realizado':
        return Icons.check_circle_outline;
      case 'Enviado':
        return Icons.delivery_dining_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Pedidos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 3,
                  color: const Color(0xFFE8651A),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFFE8651A),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFE8651A),
              indicatorWeight: 3,
              dividerColor: const Color(0xFFEEEEEE),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs.map((tab) {
                final count = tab == 'Todos'
                    ? _pedidos.length
                    : _pedidos
                        .where((p) => p['estado'] == tab)
                        .length;
                return Tab(
                  child: Row(
                    children: [
                      Text(tab),
                      if (count > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: tab == 'Todos'
                                ? const Color(0xFFE8651A)
                                    .withValues(alpha: 0.15)
                                : _colorEstado(tab)
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: tab == 'Todos'
                                  ? const Color(0xFFE8651A)
                                  : _colorEstado(tab),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Contenido
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE8651A),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      final lista = _filtrados(tab);
                      if (lista.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tab == 'Todos'
                                    ? 'No tienes pedidos aún'
                                    : 'No hay pedidos $tab',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Haz tu primer pedido desde el menú',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _cargar,
                        color: const Color(0xFFE8651A),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            return _pedidoCard(
                                lista[index],
                                _pedidos.indexOf(lista[index]) + 1);
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _pedidoCard(Map<String, dynamic> pedido, int numero) {
    final estado = pedido['estado'] ?? 'Pendiente';
    final tipo = pedido['tipo'] ?? 'personalizado';
    final total = double.parse(pedido['total'].toString());
    final subtotal = double.parse(pedido['subtotal'].toString());
    final iva = double.parse(pedido['iva'].toString());
    final fecha = pedido['createdAt']?.toString().substring(0, 10) ?? '';
    final direccion = pedido['Direccion'];
    final detalles = pedido['DetallePedidos'] as List? ?? [];
    final metodoPago = pedido['metodoPago'] ?? 'contraentrega';
    final colorEstado = _colorEstado(estado);
    final expandido = _expandidos.contains(numero);

    String? imagenUrl;
    if (tipo == 'predefinido' && detalles.isNotEmpty) {
      imagenUrl = detalles.first['Menu']?['imagenUrl'];
    }

    final productosAMostrar =
        expandido ? detalles : detalles.take(3).toList();

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
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _iconoEstado(estado),
                      color: colorEstado,
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
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorEstado.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorEstado,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen + info principal
                Row(
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
                              errorBuilder: (_, __, ___) =>
                                  _miniPlaceholder(),
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
                              Icon(Icons.calendar_today_outlined,
                                  size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(fecha,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                tipo == 'personalizado'
                                    ? Icons.tune_outlined
                                    : Icons.restaurant_menu_outlined,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tipo == 'personalizado'
                                    ? 'Personalizado'
                                    : 'Predefinido',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                metodoPago == 'pse'
                                    ? Icons.account_balance_outlined
                                    : Icons.payments_outlined,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                metodoPago == 'pse'
                                    ? 'PSE'
                                    : 'Contraentrega',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE8651A),
                          ),
                        ),
                        Text(
                          'total',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Productos
                if (detalles.isNotEmpty) ...[
                  ...productosAMostrar.map((d) {
                    final nombre = d['Menu'] != null
                        ? d['Menu']['nombre']
                        : d['Ingrediente'] != null
                            ? d['Ingrediente']['nombre']
                            : 'Producto';
                    final cantidad = d['cantidad'] ?? 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                color: Color(0xFFE8651A),
                                fontWeight: FontWeight.w700,
                              )),
                          Expanded(
                            child: Text(
                              '$nombre x$cantidad',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Botón ver más / ver menos
                  if (detalles.length > 3)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (expandido) {
                            _expandidos.remove(numero);
                          } else {
                            _expandidos.add(numero);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(
                              expandido
                                  ? 'Ver menos'
                                  : '+ ${detalles.length - 3} producto(s) más',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE8651A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              expandido
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: const Color(0xFFE8651A),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 10),

                // Dirección
                if (direccion != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${direccion['barrio']} - ${direccion['direccion']}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                // Subtotal e IVA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal: \$${subtotal.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    Text(
                      'IVA: \$${iva.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
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

  Widget _miniPlaceholder() {
    return Container(
      width: 70,
      height: 70,
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