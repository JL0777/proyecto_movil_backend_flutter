import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/logout_helper.dart';
import '../../services/pedido_service.dart';
import 'voice/cocina_voice_handler.dart';
import 'voice/cocina_voice_commands.dart';
import 'widgets/cocina_header.dart';
import 'widgets/cocina_tab_chip.dart';
import 'widgets/pedido_card.dart';
import '../../services/socket_service.dart';

class CocinaHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const CocinaHomeScreen({super.key, required this.user});

  @override
  State<CocinaHomeScreen> createState() => _CocinaHomeScreenState();
}

class _CocinaHomeScreenState extends State<CocinaHomeScreen>
    with SingleTickerProviderStateMixin {
  final PedidoService _service = PedidoService();
  final SocketService _socket = SocketService();
  late TabController _tabController;
  late CocinaVoiceHandler _voice;
  bool _dialogAbierto = false;

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
    _tabController.addListener(() => setState(() {}));

    _voice = CocinaVoiceHandler(
      onFeedback: _mostrarFeedback,
      onEstadoChanged: () {
        if (mounted) setState(() {});
      },
      onComando: _procesarComando,
    );

    _cargar();
    _voice.inicializar();
    _conectarSocket();
  }

  @override
  void dispose() {
    _socket.dejarDeEscuchar('nuevo_pedido');
    _socket.dejarDeEscuchar('estado_actualizado');
    _tabController.dispose();
    _voice.dispose();
    super.dispose();
  }

  // ── Socket ─────────────────────────────────────────────────

  void _conectarSocket() {
    _socket.conectar();

    _socket.escuchar('nuevo_pedido', (data) {
      if (!mounted) return;
      _cargar();
      _mostrarNotificacionNuevoPedido(data);
    });

    _socket.escuchar('estado_actualizado', (data) {
      if (!mounted) return;
      _cargar();
    });
  }

  void _mostrarNotificacionNuevoPedido(dynamic data) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Nuevo pedido!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pedido #${data['id']} — ${data['tipo'] ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE8651A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () => _tabController.animateTo(1),
        ),
      ),
    );
  }

  // ── Carga de datos ─────────────────────────────────────────

  Future<void> _cargar() async {
    try {
      final data = await _service.getPedidosCocina();
      if (!mounted) return;
      setState(() {
        _pedidos = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    final result = await _service.updateEstadoCocina(id, nuevoEstado);
    if (!mounted) return;
    if (result['success']) {
      _cargar();
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

  // ── Comandos de voz ────────────────────────────────────────

  void _procesarComando(String texto) {
    texto = texto.toLowerCase().trim();
    texto = CocinaVoiceCommands.convertirNumeros(texto);

    // Cerrar dialog
    if (_dialogAbierto &&
        (texto.contains('cerrar') ||
            texto.contains('cierra') ||
            texto.contains('salir') ||
            texto.contains('volver') ||
            texto.contains('atrás') ||
            texto.contains('atras'))) {
      Navigator.of(context).pop();
      _dialogAbierto = false;
      _mostrarFeedback('Cerrado ✓', Colors.grey);
      return;
    }

    // Navegación tabs
    final tabIndex = CocinaVoiceCommands.detectarNavegacion(texto);
    if (tabIndex >= 0) {
      _tabController.animateTo(tabIndex);
      final nombres = ['En preparación', 'Nuevos', 'Realizados'];
      _mostrarFeedback('Mostrando: ${nombres[tabIndex]} ✓', Colors.purple);
      return;
    }

    // Lista del tab activo
    final List<dynamic> listaActiva;
    switch (_tabController.index) {
      case 0:
        listaActiva = _enPreparacion;
        break;
      case 1:
        listaActiva = _nuevos;
        break;
      case 2:
        listaActiva = _realizados;
        break;
      default:
        listaActiva = _pedidos;
    }

    CocinaVoiceCommands.procesarPedido(
      texto: texto,
      pedidos: listaActiva,
      onCambiarEstado: (id, estado) => _cambiarEstado(id, estado),
      onVerPedido: (pedido, _) {
        final numero = listaActiva.indexOf(pedido) + 1;
        _verPedido(pedido, numero);
      },
      onVerCliente: (pedido, _) {
        final numero = listaActiva.indexOf(pedido) + 1;
        _verInfoCliente(pedido, numero);
      },
      onFeedback: _mostrarFeedback,
    );
  }

  void _mostrarFeedback(String mensaje, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────

  void _verInfoCliente(Map<String, dynamic> pedido, int numero) {
    _dialogAbierto = true;
    final usuario = pedido['Usuario'];
    final direccion = pedido['Direccion'];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.9,
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
                      onPressed: () => Navigator.pop(ctx),
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
                _seccion('Información del Cliente'),
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
                const SizedBox(height: 8),
                _seccion('Dirección de entrega'),
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
                      Navigator.pop(ctx);
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
    ).whenComplete(() => _dialogAbierto = false);
  }

  void _verPedido(Map<String, dynamic> pedido, int numero) {
    _dialogAbierto = true;
    final detalles = pedido['DetallePedidos'] as List? ?? [];
    final menus = detalles.where((d) => d['Menu'] != null).toList();
    final ingredientes = detalles
        .where((d) => d['Ingrediente'] != null)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.9,
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
                // Encabezado
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(ctx),
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

                // Menú Predefinido
                if (menus.isNotEmpty) ...[
                  _seccionTitulo(
                    Icons.restaurant_menu_outlined,
                    'Menú Predefinido',
                    const Color(0xFFE8651A),
                    const Color(0xFFFFF3ED),
                  ),
                  const SizedBox(height: 12),
                  ...menus.map((d) {
                    final menu = d['Menu'];
                    final cantidad = d['cantidad'] ?? 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                menu['nombre'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (cantidad > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3ED),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  'x$cantidad',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE8651A),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                // Separador
                if (menus.isNotEmpty && ingredientes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // Menú Personalizado
                if (ingredientes.isNotEmpty) ...[
                  _seccionTitulo(
                    Icons.tune_outlined,
                    'Menú Personalizado',
                    Colors.purple,
                    Colors.purple.shade50,
                  ),
                  const SizedBox(height: 12),
                  ...ingredientes.map((d) {
                    final ing = d['Ingrediente'];
                    final tipo = ing['tipo'] ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _iconoIngrediente(tipo),
                              size: 16,
                              color: Colors.purple.shade400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _labelIngrediente(
                                tipo,
                                ing['nombre'] ?? '',
                                d['cantidad'] ?? 1,
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

                if (detalles.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Sin detalles disponibles',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() => _dialogAbierto = false);
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _seccionTitulo(
    IconData icono,
    String titulo,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconoIngrediente(String tipo) {
    switch (tipo) {
      case 'proteina':
        return Icons.set_meal_outlined;
      case 'legumbre':
        return Icons.grass_outlined;
      case 'carbohidrato':
        return Icons.rice_bowl_outlined;
      case 'vegetal':
        return Icons.eco_outlined;
      case 'bebida':
        return Icons.local_drink_outlined;
      case 'complemento':
        return Icons.add_circle_outline;
      case 'pan':
        return Icons.breakfast_dining_outlined;
      case 'salsa':
        return Icons.water_drop_outlined;
      case 'extra':
        return Icons.add_outlined;
      default:
        return Icons.circle_outlined;
    }
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
        Container(width: 50, height: 3, color: const Color(0xFFE8651A)),
        const SizedBox(height: 12),
      ],
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

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      floatingActionButton: _voice.speechDisponible
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_voice.modoContinuo)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🎙 Escuchando...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                FloatingActionButton(
                  onPressed: () {
                    _voice.toggle();
                    setState(() {});
                  },
                  backgroundColor: _voice.modoContinuo
                      ? Colors.red
                      : const Color(0xFFE8651A),
                  child: Icon(
                    _voice.modoContinuo ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          CocinaHeader(
            onLogout: () => LogoutHelper.confirmarCierreSesion(context),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CocinaTabChip(
                  index: 0,
                  label: 'En preparación',
                  icono: Icons.restaurant_outlined,
                  count: _enPreparacion.length,
                  color: const Color(0xFFE8651A),
                  tabController: _tabController,
                ),
                const SizedBox(width: 8),
                CocinaTabChip(
                  index: 1,
                  label: 'Nuevos',
                  icono: Icons.fiber_new_outlined,
                  count: _nuevos.length,
                  color: Colors.red,
                  tabController: _tabController,
                ),
                const SizedBox(width: 8),
                CocinaTabChip(
                  index: 2,
                  label: 'Realizados',
                  icono: Icons.check_circle_outline,
                  count: _realizados.length,
                  color: Colors.green,
                  tabController: _tabController,
                ),
              ],
            ),
          ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: pedidos.length,
        itemBuilder: (ctx, index) {
          final pedido = pedidos[index];
          final numero = index + 1;
          return PedidoCard(
            pedido: pedido,
            numero: numero,
            onCambiarEstado: (id, estado) => _cambiarEstado(id, estado),
            onVerPedido: _verPedido,
            onVerCliente: _verInfoCliente,
          );
        },
      ),
    );
  }
}
