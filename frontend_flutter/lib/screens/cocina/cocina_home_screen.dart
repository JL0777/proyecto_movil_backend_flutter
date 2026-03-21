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

  void _verInfoCliente(Map<String, dynamic> pedido, int numero) {
    final usuario = pedido['Usuario'];
    final direccion = pedido['Direccion'];

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
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                const Text(
                  'Información del Cliente',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(width: 50, height: 3, color: const Color(0xFFE8651A)),
                const SizedBox(height: 16),
                _infoRow(
                  Icons.person_outline,
                  usuario?['nombre'] ?? 'Sin nombre',
                ),
                _infoRow(
                  Icons.email_outlined,
                  usuario?['email'] ?? 'Sin correo',
                ),
                _infoRow(
                  Icons.phone_outlined,
                  usuario?['telefono'] ?? 'Sin teléfono',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dirección de entrega',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(width: 50, height: 3, color: const Color(0xFFE8651A)),
                const SizedBox(height: 16),
                _infoRow(
                  Icons.location_on_outlined,
                  direccion?['direccion'] ?? 'Sin dirección',
                ),
                _infoRow(
                  Icons.map_outlined,
                  direccion?['barrio'] ?? 'Sin barrio',
                ),
                _infoRow(
                  Icons.home_outlined,
                  direccion?['tipoVivienda'] ?? 'No especificado',
                ),
                if (direccion?['instrucciones'] != null &&
                    direccion!['instrucciones'].toString().isNotEmpty)
                  _infoRow(Icons.info_outline, direccion['instrucciones']),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _verPedido(pedido, numero);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8651A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Ver detalle del pedido',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Detalle del pedido #$numero',
                      style: const TextStyle(
                        fontSize: 18,
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
                      detalles.first['Menu']['imagenUrl'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        detalles.first['Menu']['imagenUrl'],
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagenPlaceholder(),
                      ),
                    )
                  else
                    _imagenPlaceholder(),
                  const SizedBox(height: 12),
                  Text(
                    detalles.first['Menu']?['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (detalles.first['Menu']?['descripcion'] != null &&
                      detalles.first['Menu']['descripcion']
                          .toString()
                          .isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      detalles.first['Menu']['descripcion'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],

                if (tipo == 'personalizado') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tune_outlined,
                          color: Color(0xFFE8651A),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Menú Personalizado',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8651A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...detalles.map((d) {
                    if (d['Ingrediente'] == null) return const SizedBox();
                    final ing = d['Ingrediente'];
                    final cantidad = d['cantidad'] ?? 1;
                    final tipoIng = ing['tipo'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8651A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _labelIngrediente(
                                tipoIng,
                                ing['nombre'],
                                cantidad,
                                ing['cantidad'],
                              ),
                              style: const TextStyle(
                                fontSize: 13,
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

  Widget _infoRow(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16, color: const Color(0xFFE8651A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _labelIngrediente(
    String tipo,
    String nombre,
    int cantidad,
    dynamic cantidadBase,
  ) {
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
      case 'pan':
        return 'Pan: $nombre';
      case 'salsa':
        return 'Salsa: $nombre';
      case 'extra':
        return 'Extra: $nombre';
      default:
        return '$nombre x$cantidad';
    }
  }

  Widget _imagenPlaceholder() {
    return Container(
      height: 160,
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
      case 'Realizado':
        return ['Realizado', 'Enviado'];
      default:
        return [estadoActual];
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

  Widget _buildLista(List<dynamic> pedidos) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay pedidos aquí',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
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
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          final numero = _pedidos.indexOf(pedido) + 1;
          final usuario = pedido['Usuario'];
          final estado = pedido['estado'];
          final tipo = pedido['tipo'] ?? 'predefinido';
          final detalles = pedido['DetallePedidos'] as List? ?? [];
          final estadosDisponibles = _estadosDisponibles(estado);
          final colorEstado = _colorEstado(estado);

          // Imagen del menú
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
                // Header con estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                      // Select de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorEstado.withValues(alpha: 0.4),
                          ),
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
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: colorEstado,
                                    size: 16,
                                  ),
                                  items: estadosDisponibles
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                              color: _colorEstado(e),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (nuevoEstado) async {
                                    if (nuevoEstado != null &&
                                        nuevoEstado != estado) {
                                      await _cambiarEstado(
                                        pedido['id'],
                                        nuevoEstado,
                                      );
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

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
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
                                errorBuilder: (_, __, ___) =>
                                    _miniPlaceholder(),
                              )
                            : _miniPlaceholder(),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cliente
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
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

                            // Tipo
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
                                      color: Colors.grey.shade600,
                                    ),
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

                // Botones
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _verInfoCliente(pedido, numero),
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
                          onPressed: () => _verPedido(pedido, numero),
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
        size: 32,
      ),
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
          // Header
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    LogoutHelper.confirmarCierreSesion(context),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabChip(
                  0,
                  'En preparación',
                  Icons.restaurant_outlined,
                  _enPreparacion.length,
                  const Color(0xFFE8651A),
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  1,
                  'Nuevos',
                  Icons.fiber_new_outlined,
                  _nuevos.length,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  2,
                  'Realizados',
                  Icons.check_circle_outline,
                  _realizados.length,
                  Colors.green,
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
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

  Widget _buildTabChip(
    int index,
    String label,
    IconData icono,
    int count,
    Color color,
  ) {
    final activo = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _tabController.animateTo(index));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activo ? color : color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 18, color: activo ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: activo ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
              ),
              if (count > 0) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: activo
                        ? Colors.white.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: activo ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
