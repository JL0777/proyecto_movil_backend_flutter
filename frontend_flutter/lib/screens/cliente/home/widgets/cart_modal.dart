import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/providers/cart_provider.dart';
import '../../../../../services/pedido_service.dart';
import '../../../../../services/address_service.dart';

class CartModal extends StatefulWidget {
  const CartModal({super.key});

  @override
  State<CartModal> createState() => _CartModalState();
}

class _CartModalState extends State<CartModal> {
  final PedidoService _pedidoService = PedidoService();
  final AddressService _addressService = AddressService();

  List<dynamic> _direcciones = [];
  Map<String, dynamic>? _direccionSeleccionada;
  String _metodoPago = 'contraentrega';
  bool _loading = false;
  bool _mostrarCheckout = false;

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  Future<void> _cargarDirecciones() async {
    try {
      final data = await _addressService.getAddresses();
      setState(() => _direcciones = data);
    } catch (e) {
      // silencioso
    }
  }

  void _mostrarFormularioNuevaDireccion() {
    final barrioController = TextEditingController();
    final direccionController = TextEditingController();
    final instruccionesController = TextEditingController();
    String tipoVivienda = 'Casa';

    final tipos = [
      ('Casa', Icons.home_outlined),
      ('Apartamento', Icons.apartment_outlined),
      ('Oficina/Local comercial', Icons.business_center_outlined),
      ('Hotel', Icons.hotel_outlined),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Mini header naranja ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nueva dirección',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Completa los datos de entrega',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Selector tipo vivienda ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.home_outlined,
                                    color: Color(0xFFE8651A),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tipo de vivienda',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: tipos.map((t) {
                                final (label, icono) = t;
                                final seleccionado = tipoVivienda == label;
                                final labelCorto =
                                    label == 'Oficina/Local comercial'
                                    ? 'Oficina'
                                    : label;
                                final isLast = label == 'Hotel';
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setModalState(
                                      () => tipoVivienda = label,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: isLast ? 0 : 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: seleccionado
                                            ? const Color(
                                                0xFFE8651A,
                                              ).withValues(alpha: 0.08)
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: seleccionado
                                              ? const Color(
                                                  0xFFE8651A,
                                                ).withValues(alpha: 0.5)
                                              : Colors.grey.shade200,
                                          width: seleccionado ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            icono,
                                            size: 20,
                                            color: seleccionado
                                                ? const Color(0xFFE8651A)
                                                : Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            labelCorto,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: seleccionado
                                                  ? const Color(0xFFE8651A)
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Campos ubicación ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFFE8651A),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ubicación',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _campoDir(
                              barrioController,
                              'Barrio / Conjunto',
                              icono: Icons.map_outlined,
                            ),
                            const SizedBox(height: 12),
                            _campoDir(
                              direccionController,
                              'Dirección',
                              icono: Icons.signpost_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Instrucciones ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.notes_outlined,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detalles adicionales',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Opcional',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _campoDir(
                              instruccionesController,
                              'Instrucciones para el domiciliario',
                              icono: Icons.info_outline,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Botón guardar ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (barrioController.text.trim().isEmpty ||
                                direccionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Barrio y dirección son requeridos',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                              return;
                            }

                            final nav = Navigator.of(sheetCtx);
                            final messenger = ScaffoldMessenger.of(context);

                            final ok = await _addressService.createAddress({
                              'barrio': barrioController.text.trim(),
                              'direccion': direccionController.text.trim(),
                              'instrucciones': instruccionesController.text
                                  .trim(),
                              'tipoVivienda': tipoVivienda,
                            });

                            nav.pop();

                            if (ok) {
                              await _cargarDirecciones();
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Dirección agregada correctamente',
                                    ),
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8651A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Guardar dirección',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _campoDir(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    IconData? icono,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFE8651A),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: icono != null
            ? Icon(icono, color: Colors.grey.shade400, size: 18)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8651A), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
      ),
    );
  }

  Future<void> _confirmarPedido() async {
    if (_direccionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona una dirección'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final cart = context.read<CartProvider>();

    final result = await _pedidoService.create({
      'direccionId': _direccionSeleccionada!['id'],
      'tipo': 'predefinido',
      'metodoPago': _metodoPago,
      'items': cart.buildItems(),
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      cart.limpiar();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Pedido creado con éxito!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al crear el pedido'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (consumerCtx, cart, child) {
        return Container(
          height: MediaQuery.of(consumerCtx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle + Header ──
              _buildSheetHeader(cart),

              // ── Contenido ──
              Expanded(
                child: cart.isEmpty
                    ? _carritoVacio()
                    : _mostrarCheckout
                    ? _vistaCheckout(cart)
                    : _listaItems(cart),
              ),

              // ── Footer ──
              if (!cart.isEmpty) _footer(cart),
            ],
          ),
        );
      },
    );
  }

  // ── Header del sheet ───────────────────────────────────────

  Widget _buildSheetHeader(CartProvider cart) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8651A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFFE8651A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Mi carrito',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_mostrarCheckout)
                  GestureDetector(
                    onTap: () => setState(() => _mostrarCheckout = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Carrito',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (!cart.isEmpty)
                  GestureDetector(
                    onTap: () => cart.limpiar(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Vaciar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Indicador de vista
          if (!cart.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _tabIndicador('Productos', !_mostrarCheckout),
                  const SizedBox(width: 8),
                  _tabIndicador('Confirmar pedido', _mostrarCheckout),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _tabIndicador(String label, bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: activo
            ? const Color(0xFFE8651A).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activo
              ? const Color(0xFFE8651A).withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: activo ? const Color(0xFFE8651A) : Colors.grey.shade400,
        ),
      ),
    );
  }

  // ── Carrito vacío ──────────────────────────────────────────

  Widget _carritoVacio() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFE8651A).withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE8651A).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFFE8651A),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tu carrito está vacío',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Agrega productos para continuar',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ── Lista de items ─────────────────────────────────────────

  Widget _listaItems(CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: cart.items.length,
      itemBuilder: (cartListCtx, index) {
        final item = cart.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8651A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  color: Color(0xFFE8651A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${item.precio.toStringAsFixed(0)} c/u',
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
                  GestureDetector(
                    onTap: () => cart.decrementar(index),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.red,
                        size: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${item.cantidad}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cart.incrementar(index),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8651A),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                '\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8651A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Vista checkout ─────────────────────────────────────────

  Widget _vistaCheckout(CartProvider cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del pedido
          _buildTarjeta(
            icono: Icons.receipt_long_outlined,
            color: const Color(0xFFE8651A),
            titulo: 'Resumen del pedido',
            child: Column(
              children: [
                // Cabecera tabla
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Producto',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8651A),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Subtotal',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8651A),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${item.nombre} ×${item.cantidad}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade100),
                const SizedBox(height: 6),
                _filaTotalRow('Subtotal', cart.subtotal),
                const SizedBox(height: 4),
                _filaTotalRow('IVA (inc.)', cart.iva),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE8651A).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '\$${cart.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE8651A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dirección
          _buildTarjeta(
            icono: Icons.location_on_outlined,
            color: const Color(0xFFE8651A),
            titulo: 'Dirección de entrega',
            accion: GestureDetector(
              onTap: _mostrarFormularioNuevaDireccion,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE8651A).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_location_alt_outlined,
                      color: Color(0xFFE8651A),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Nueva',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE8651A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: _direcciones.isEmpty
                ? GestureDetector(
                    onTap: _mostrarFormularioNuevaDireccion,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8651A).withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8651A).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: Color(0xFFE8651A),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Agrega tu primera dirección',
                            style: TextStyle(
                              color: Color(0xFFE8651A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFFE8651A),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: _direcciones.map((dir) {
                      final seleccionada =
                          _direccionSeleccionada?['id'] == dir['id'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _direccionSeleccionada = dir),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: seleccionada
                                ? const Color(
                                    0xFFE8651A,
                                  ).withValues(alpha: 0.06)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: seleccionada
                                  ? const Color(
                                      0xFFE8651A,
                                    ).withValues(alpha: 0.4)
                                  : Colors.grey.shade200,
                              width: seleccionada ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: seleccionada
                                      ? const Color(
                                          0xFFE8651A,
                                        ).withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: seleccionada
                                      ? const Color(0xFFE8651A)
                                      : Colors.grey.shade400,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dir['barrio'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: seleccionada
                                            ? const Color(0xFFE8651A)
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      dir['direccion'] ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
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
                                )
                              else
                                Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey.shade300,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 14),

          // Método de pago
          _buildTarjeta(
            icono: Icons.payment_outlined,
            color: Colors.purple,
            titulo: 'Método de pago',
            child: Column(
              children: [
                _metodoPagoTile(
                  valor: 'contraentrega',
                  label: 'Pago contraentrega',
                  descripcion: 'Paga en efectivo al recibir tu pedido',
                  icono: Icons.payments_outlined,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _metodoPagoTile(
                  valor: 'pse',
                  label: 'PSE',
                  descripcion: 'Transferencia bancaria en línea',
                  icono: Icons.account_balance_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _buildTarjeta({
    required IconData icono,
    required Color color,
    required String titulo,
    required Widget child,
    Widget? accion,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (accion != null) ...[const Spacer(), accion],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _metodoPagoTile({
    required String valor,
    required String label,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    final seleccionado = _metodoPago == valor;
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado
                ? color.withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: seleccionado
                    ? color.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                color: seleccionado ? color : Colors.grey.shade400,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: seleccionado ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    descripcion,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seleccionado ? color : Colors.transparent,
                border: Border.all(
                  color: seleccionado ? color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: seleccionado
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaTotalRow(String label, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────

  Widget _footer(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Text(
                '\$${cart.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8651A),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      if (!_mostrarCheckout) {
                        setState(() => _mostrarCheckout = true);
                      } else {
                        _confirmarPedido();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8651A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(
                  0xFFE8651A,
                ).withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _mostrarCheckout
                              ? Icons.check_circle_outline
                              : Icons.arrow_forward,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _mostrarCheckout ? 'Confirmar pedido' : 'Ir a pagar',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
