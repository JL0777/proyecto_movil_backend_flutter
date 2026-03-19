import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/logout_helper.dart';
import '../../services/pedido_service.dart';

class CocinaHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const CocinaHomeScreen({super.key, required this.user});

  @override
  State<CocinaHomeScreen> createState() => _CocinaHomeScreenState();
}

class _CocinaHomeScreenState extends State<CocinaHomeScreen>
    with SingleTickerProviderStateMixin {
  final PedidoService _service = PedidoService();
  late TabController _tabController;

  List<dynamic> _pedidos = [];
  bool _loading = true;

  List<dynamic> get _enPreparacion =>
      _pedidos.where((p) => p['estado'] == 'Activo').toList();

  List<dynamic> get _nuevos =>
      _pedidos.where((p) => p['estado'] == 'Pendiente').toList();

  List<dynamic> get _realizados =>
      _pedidos.where((p) => p['estado'] == 'Realizado').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getPedidosCocina();
      setState(() {
        _pedidos = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    final result = await _service.updateEstadoCocina(id, nuevoEstado);
    if (result['success']) {
      _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a "$nuevoEstado" ✓'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _verPedido(Map<String, dynamic> pedido, int numero) {
    final detalles = pedido['DetallePedidos'] as List? ?? [];
    final tipo = pedido['tipo'] ?? 'predefinido';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pedido #$numero',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8651A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (tipo == 'predefinido' && detalles.isNotEmpty) ...[
                  if (detalles.first['Menu'] != null &&
                      detalles.first['Menu']['imagenUrl'] != null &&
                      detalles.first['Menu']['imagenUrl']
                          .toString()
                          .isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        detalles.first['Menu']['imagenUrl'],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imagenPlaceholder(),
                      ),
                    )
                  else
                    _imagenPlaceholder(),
                  const SizedBox(height: 16),
                  Text(
                    detalles.first['Menu']?['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detalles.first['Menu']?['descripcion'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],

                if (tipo == 'personalizado') ...[
                  const Text(
                    'Menú Personalizado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...detalles.map((d) {
                    if (d['Ingrediente'] == null) return const SizedBox();
                    final ing = d['Ingrediente'];
                    final cantidad = d['cantidad'] ?? 1;
                    final tipoIng = ing['tipo'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: Color(0xFFE8651A),
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _labelIngrediente(tipoIng, ing['nombre'],
                                  cantidad, ing['cantidad']),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _labelIngrediente(
      String tipo, String nombre, int cantidad, dynamic cantidadBase) {
    switch (tipo) {
      case 'proteina':
        return 'Base: $nombre (${cantidadBase ?? cantidad}g)';
      case 'legumbre':
        return 'Legumbre: $nombre (${cantidadBase ?? cantidad}g)';
      case 'carbohidrato':
        return 'Carbohidrato: $nombre (${cantidadBase ?? cantidad}g)';
      case 'vegetal':
        return 'Vegetal: $nombre (${cantidadBase ?? cantidad}g)';
      case 'bebida':
        return 'Bebida: $nombre (${cantidadBase ?? cantidad}ml)';
      case 'complemento':
        return 'Complemento: $nombre x$cantidad';
      default:
        return '$nombre x$cantidad';
    }
  }

  Widget _imagenPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.fastfood_outlined, color: Colors.grey, size: 60),
      ),
    );
  }

  List<String> _estadosDisponibles(String estadoActual) {
    switch (estadoActual) {
      case 'Pendiente':
        return ['Pendiente', 'Activo'];
      case 'Activo':
        return ['Activo', 'Realizado'];
      default:
        return [estadoActual];
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Activo':
        return const Color(0xFFE8651A);
      case 'Realizado':
        return Colors.green;
      case 'Pendiente':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLista(List<dynamic> pedidos) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No hay pedidos aquí',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
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
          final usuario = pedido['Usuario'];
          final estado = pedido['estado'];
          final tipo = pedido['tipo'] ?? 'predefinido';
          final detalles = pedido['DetallePedidos'] as List? ?? [];
          final estadosDisponibles = _estadosDisponibles(estado);

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
                  Expanded(
                    child: Text(
                      usuario?['nombre'] ?? 'Sin nombre',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Text('Tipo: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Text(
                      tipo == 'personalizado'
                          ? 'Personalizado'
                          : detalles.isNotEmpty &&
                                  detalles.first['Menu'] != null
                              ? detalles.first['Menu']['nombre']
                              : 'Predefinido',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: tipo == 'predefinido' &&
                            detalles.isNotEmpty &&
                            detalles.first['Menu'] != null &&
                            detalles.first['Menu']['imagenUrl'] != null &&
                            detalles.first['Menu']['imagenUrl']
                                .toString()
                                .isNotEmpty
                        ? Image.network(
                            detalles.first['Menu']['imagenUrl'],
                            width: 80,
                            height: 80,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Text('Estado: ',
                                  style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: estadosDisponibles.length > 1
                                    ? DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: estado,
                                          isDense: true,
                                          isExpanded: true,
                                          style: TextStyle(
                                            color: _colorEstado(estado),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          items: estadosDisponibles
                                              .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(
                                                      e,
                                                      style: TextStyle(
                                                        color:
                                                            _colorEstado(e),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (nuevoEstado) async {
                                            if (nuevoEstado != null &&
                                                nuevoEstado != estado) {
                                              await _cambiarEstado(
                                                  pedido['id'],
                                                  nuevoEstado);
                                            }
                                          },
                                        ),
                                      )
                                    : Text(
                                        estado,
                                        style: TextStyle(
                                          color: _colorEstado(estado),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _colorEstado(estado),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _verPedido(pedido, numero),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFE8651A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                            ),
                            child: const Text(
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
              const Divider(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _miniPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 230,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned.fill(
                  child: Container(color: const Color(0x66000000)),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Image.asset(
                            'assets/images/logo_mymeal.png',
                            width: 200,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BIENVENIDO AL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'PANEL DE COCINA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    LogoutHelper.confirmarCierreSesion(
                                        context),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
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
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('En preparación'),
                      const SizedBox(width: 4),
                      if (_enPreparacion.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8651A)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_enPreparacion.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE8651A),
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
                      const Text('Nuevos'),
                      const SizedBox(width: 4),
                      if (_nuevos.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_nuevos.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
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
                      const Text('Realizados'),
                      const SizedBox(width: 4),
                      if (_realizados.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_realizados.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE8651A),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLista(_enPreparacion),
                      _buildLista(_nuevos),
                      _buildLista(_realizados),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}