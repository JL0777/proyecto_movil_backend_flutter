import 'package:flutter/material.dart';
import '../../../services/pedido_service.dart';
import '../../../services/address_service.dart';

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
        return const Color(0xFFE8651A);
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

  Future<void> _cancelarPedido(Map<String, dynamic> pedido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '¿Cancelar?',
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Esta acción no se puede deshacer. ¿Estás seguro?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'No, mantener',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _service.cancelarPedido(pedido['id']);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success']
              ? 'Pedido cancelado correctamente'
              : result['error'] ?? 'Error al cancelar',
        ),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );

    if (result['success']) _cargar();
  }

  Future<void> _editarPedido(Map<String, dynamic> pedido) async {
    final AddressService addressService = AddressService();
    final List<dynamic> direcciones = await addressService.getAddresses();
    if (!mounted) return;

    final detalles = pedido['DetallePedidos'] as List? ?? [];

    Map<String, dynamic>? direccionSeleccionada = direcciones.firstWhere(
      (d) => d['id'] == pedido['direccionId'],
      orElse: () => direcciones.isNotEmpty ? direcciones.first : null,
    );
    String metodoPago = pedido['metodoPago'] ?? 'contraentrega';
    List<Map<String, dynamic>> items = detalles.map((d) {
      if (d['Menu'] != null) {
        return {
          'menuId': d['menuId'],
          'nombre': d['Menu']?['nombre'] ?? '',
          'precio': double.parse(d['precioUnitario'].toString()),
          'cantidad': d['cantidad'] ?? 1,
        };
      } else {
        return {
          'ingredienteId': d['ingredienteId'],
          'nombre': d['Ingrediente']?['nombre'] ?? '',
          'precio': double.parse(d['precioUnitario'].toString()),
          'cantidad': d['cantidad'] ?? 1,
        };
      }
    }).toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) {
          double calcularTotal() =>
              items.fold(0, (sum, i) => sum + (i['precio'] * i['cantidad']));

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3ED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFE8651A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Editar pedido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Productos
                  _seccionLabel('PRODUCTOS'),
                  const SizedBox(height: 8),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nombre'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '\$${item['precio'].toStringAsFixed(0)} c/u',
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
                              _botonCantidad(
                                icono: Icons.remove,
                                onTap: () => setModalState(() {
                                  if (item['cantidad'] > 1) {
                                    items[index]['cantidad']--;
                                  } else {
                                    items.removeAt(index);
                                  }
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '${item['cantidad']}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _botonCantidad(
                                icono: Icons.add,
                                onTap: () => setModalState(
                                  () => items[index]['cantidad']++,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\$${(item['precio'] * item['cantidad']).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE8651A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Debes tener al menos un producto',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Dirección
                  _seccionLabel('DIRECCIÓN DE ENTREGA'),
                  const SizedBox(height: 8),
                  if (direcciones.isEmpty)
                    Text(
                      'No tienes direcciones guardadas',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    )
                  else
                    ...direcciones.map((dir) {
                      final seleccionada =
                          direccionSeleccionada?['id'] == dir['id'];
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => direccionSeleccionada = dir),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: seleccionada
                                ? const Color(0xFFFFF3ED)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: seleccionada
                                  ? const Color(0xFFE8651A)
                                  : Colors.grey.shade200,
                              width: seleccionada ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: seleccionada
                                    ? const Color(0xFFE8651A)
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dir['barrio'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: seleccionada
                                            ? const Color(0xFFE8651A)
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      dir['direccion'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
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
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // Método de pago
                  _seccionLabel('MÉTODO DE PAGO'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['pse', 'contraentrega'].map((m) {
                      final sel = metodoPago == m;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => metodoPago = m),
                          child: Container(
                            margin: EdgeInsets.only(right: m == 'pse' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF3ED)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFFE8651A)
                                    : Colors.grey.shade200,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  m == 'pse'
                                      ? Icons.account_balance_outlined
                                      : Icons.payments_outlined,
                                  color: sel
                                      ? const Color(0xFFE8651A)
                                      : Colors.grey,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m == 'pse' ? 'PSE' : 'Contraentrega',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? const Color(0xFFE8651A)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nuevo total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '\$${calcularTotal().toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: items.isEmpty || direccionSeleccionada == null
                          ? null
                          : () async {
                              final data = {
                                'direccionId': direccionSeleccionada!['id'],
                                'metodoPago': metodoPago,
                                'items': items.map((i) {
                                  if (i['menuId'] != null) {
                                    return {
                                      'menuId': i['menuId'],
                                      'cantidad': i['cantidad'],
                                    };
                                  }
                                  return {
                                    'ingredienteId': i['ingredienteId'],
                                    'cantidad': i['cantidad'],
                                  };
                                }).toList(),
                              };

                              final result = await _service.editarPedido(
                                pedido['id'],
                                data,
                              );
                              if (!sheetCtx.mounted) return;
                              Navigator.pop(sheetCtx);
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['success']
                                        ? 'Pedido actualizado correctamente'
                                        : result['error'] ?? 'Error al editar',
                                  ),
                                  backgroundColor: result['success']
                                      ? Colors.green
                                      : Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );

                              if (result['success']) _cargar();
                            },
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
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header con gradiente ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0x66000000),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mis Ordenes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Historial y seguimiento',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tabs dentro del header
                  Container(
                    color: Colors.white.withValues(alpha: 0.0),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                      indicator: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
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
                            : _pedidos.where((p) => p['estado'] == tab).length;
                        return Tab(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tab),
                                if (count > 0) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Contenido ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
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
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF3ED),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: Color(0xFFE8651A),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tab == 'Todos'
                                    ? 'No tienes pedidos aún'
                                    : 'No hay pedidos $tab',
                                style: const TextStyle(
                                  fontSize: 16,
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            return _pedidoCard(
                              lista[index],
                              _pedidos.indexOf(lista[index]) + 1,
                            );
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
    final esPendiente = estado == 'Pendiente';

    String? imagenUrl;
    if (tipo == 'predefinido' && detalles.isNotEmpty) {
      imagenUrl = detalles.first['Menu']?['imagenUrl'];
    }

    final productosAMostrar = expandido ? detalles : detalles.take(3).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header de la card ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(_iconoEstado(estado), color: colorEstado, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pedido #$numero',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  fecha,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorEstado.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorEstado,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info principal ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imagenUrl != null && imagenUrl.isNotEmpty
                          ? Image.network(
                              imagenUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _miniPlaceholder(),
                            )
                          : _miniPlaceholder(),
                    ),
                    const SizedBox(width: 12),

                    // Info chips
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoChip(
                            tipo == 'personalizado'
                                ? Icons.tune_outlined
                                : Icons.restaurant_menu_outlined,
                            tipo == 'personalizado'
                                ? 'Personalizado'
                                : 'Predefinido',
                            Colors.purple,
                          ),
                          const SizedBox(height: 5),
                          _infoChip(
                            metodoPago == 'pse'
                                ? Icons.account_balance_outlined
                                : Icons.payments_outlined,
                            metodoPago == 'pse' ? 'PSE' : 'Contraentrega',
                            Colors.teal,
                          ),
                          if (direccion != null) ...[
                            const SizedBox(height: 5),
                            _infoChip(
                              Icons.location_on_outlined,
                              '${direccion['barrio']}',
                              const Color(0xFFE8651A),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Precio — ancho fijo para no chocar con la info
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE8651A),
                              ),
                            ),
                          ),
                          Text(
                            'total',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sub: \$${subtotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'IVA: \$${iva.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100),
                const SizedBox(height: 8),

                // ── Productos ──
                if (detalles.isNotEmpty) ...[
                  ...productosAMostrar.map((d) {
                    final nombre = d['Menu'] != null
                        ? d['Menu']['nombre']
                        : d['Ingrediente'] != null
                        ? d['Ingrediente']['nombre']
                        : 'Producto';
                    final cantidad = d['cantidad'] ?? 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (detalles.length > 3)
                    GestureDetector(
                      onTap: () => setState(() {
                        if (expandido) {
                          _expandidos.remove(numero);
                        } else {
                          _expandidos.add(numero);
                        }
                      }),
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

                // ── Botones si está pendiente ──
                if (esPendiente) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Puedes editar o cancelar este pedido mientras esté Pendiente.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editarPedido(pedido),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8651A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFE8651A),
                            size: 16,
                          ),
                          label: const Text(
                            'Editar',
                            style: TextStyle(
                              color: Color(0xFFE8651A),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelarPedido(pedido),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 16,
                          ),
                          label: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _infoChip(IconData icono, String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 12, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _seccionLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _botonCantidad({
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFE8651A),
          shape: BoxShape.circle,
        ),
        child: Icon(icono, color: Colors.white, size: 16),
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
