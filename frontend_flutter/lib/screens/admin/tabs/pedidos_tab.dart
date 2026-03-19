import 'package:flutter/material.dart';
import '../../../services/pedido_service.dart';

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab>
    with SingleTickerProviderStateMixin {
  final PedidoService _service = PedidoService();
  List<dynamic> _pedidos = [];
  bool _loading = true;
  late TabController _tabController;

  List<dynamic> get _realizados =>
      _pedidos.where((p) => p['estado'] == 'Realizado').toList();

  List<dynamic> get _enviados =>
      _pedidos.where((p) => p['estado'] == 'Enviado').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Información del\nCliente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8651A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _infoRow('Cliente:', usuario?['nombre'] ?? 'Sin nombre'),
                const SizedBox(height: 12),
                _infoRow('Correo:', usuario?['email'] ?? 'Sin correo'),
                const SizedBox(height: 12),
                _infoRow('Teléfono:',
                    usuario?['telefono'] ?? 'Sin teléfono'),
                const SizedBox(height: 12),
                _infoRow('Dirección:',
                    direccion?['direccion'] ?? 'Sin dirección'),
                const SizedBox(height: 12),
                _infoRow('Barrio:', direccion?['barrio'] ?? 'Sin barrio'),
                const SizedBox(height: 12),
                _infoRow('Tipo de vivienda:',
                    direccion?['tipoVivienda'] ?? 'No especificado'),
                const SizedBox(height: 12),
                _infoRow('Instrucciones:',
                    direccion?['instrucciones'] ?? 'Sin instrucciones'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarInfoPedido(pedido, numero);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Ver pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black87),
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarInfoCliente(pedido, numero);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Información del\nPedido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8651A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _infoRow('Número:', '#$numero'),
                const SizedBox(height: 12),
                _infoRow(
                    'Tipo:',
                    pedido['tipo'] == 'personalizado'
                        ? 'Menú personalizado'
                        : 'Menú predefinido'),
                const SizedBox(height: 12),
                _infoRow(
                    'Método de pago:',
                    pedido['metodoPago'] == 'pse'
                        ? 'PSE'
                        : 'Pago contraentrega'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Productos:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...detalles.map((d) {
                  final nombre = d['Menu'] != null
                      ? d['Menu']['nombre']
                      : d['Ingrediente'] != null
                          ? '${d['Ingrediente']['nombre']} (${d['Ingrediente']['cantidad'] ?? ''})'
                          : 'Producto';
                  final cantidad = d['cantidad'] ?? 1;
                  final precio =
                      double.parse(d['precioUnitario'].toString());

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• $nombre x$cantidad',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          precio == 0
                              ? 'Gratis'
                              : '\$${(precio * cantidad).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:',
                        style: TextStyle(color: Colors.grey.shade600)),
                    Text('\$${subtotal.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IVA (19%):',
                        style: TextStyle(color: Colors.grey.shade600)),
                    Text('\$${iva.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLista(List<dynamic> pedidos) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long,
                size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No hay pedidos aquí',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
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
        padding: const EdgeInsets.all(16),
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          final numero = _pedidos.indexOf(pedido) + 1;
          final estado = pedido['estado'] ?? 'Realizado';
          final usuario = pedido['Usuario'];
          final total = double.parse(pedido['total'].toString());

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #$numero:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Cliente: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(usuario?['nombre'] ?? 'Sin nombre'),
                  const SizedBox(width: 16),
                  const Text('Tipo: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Text(
                      pedido['tipo'] == 'personalizado'
                          ? 'Personalizado'
                          : 'Predefinido',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Total: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFE8651A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fastfood,
                        color: Colors.grey, size: 36),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Estado con dropdown solo si es Realizado
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: estado == 'Realizado'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Estado: ',
                                        style: TextStyle(fontSize: 12)),
                                    DropdownButton<String>(
                                      value: estado,
                                      underline: const SizedBox(),
                                      isDense: true,
                                      style: TextStyle(
                                        color: _colorEstado(estado),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Realizado',
                                          child: Text('Realizado'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Enviado',
                                          child: Text('Enviado'),
                                        ),
                                      ],
                                      onChanged: (nuevoEstado) async {
                                        if (nuevoEstado != null) {
                                          final result =
                                              await _service.updateEstado(
                                            pedido['id'],
                                            nuevoEstado,
                                          );
                                          if (result['success']) {
                                            _cargar();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Estado cambiado a "$nuevoEstado" ✓',
                                                    textAlign:
                                                        TextAlign.center,
                                                  ),
                                                  backgroundColor:
                                                      Colors.green,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  behavior: SnackBarBehavior
                                                      .floating,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  margin:
                                                      const EdgeInsets.all(
                                                          16),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Estado: ',
                                        style: TextStyle(fontSize: 12)),
                                    Text(
                                      estado,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _colorEstado(estado),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _mostrarInfoCliente(pedido, numero),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8651A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                            ),
                            child: const Text(
                              'Info. Cliente y pedido',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          );
        },
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Enviado':
        return Colors.blue;
      case 'Realizado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8651A)),
      );
    }

    return Column(
      children: [
        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFE8651A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFE8651A),
            indicatorWeight: 3,
            dividerColor: const Color(0xFFEEEEEE),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Realizados'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_realizados.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Enviados'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_enviados.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Contenido
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLista(_realizados),
              _buildLista(_enviados),
            ],
          ),
        ),
      ],
    );
  }
}