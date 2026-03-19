import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/providers/cart_provider.dart';
import '../../../../../core/theme/app_theme.dart';
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

  Future<void> _confirmarPedido() async {
    if (_direccionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una dirección'),
          backgroundColor: Colors.red,
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mi carrito',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    if (!cart.isEmpty)
                      TextButton(
                        onPressed: () => cart.limpiar(),
                        child: const Text(
                          'Vaciar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: cart.isEmpty
                    ? _carritoVacio()
                    : _mostrarCheckout
                        ? _vistaCheckout(cart)
                        : _listaItems(cart),
              ),
              if (!cart.isEmpty) _footer(cart),
            ],
          ),
        );
      },
    );
  }

  Widget _carritoVacio() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.lightOrange,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryOrange, width: 2),
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: AppTheme.primaryOrange,
            size: 30,
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
        const Text(
          'Agrega productos para continuar',
          style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _listaItems(CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${item.precio.toStringAsFixed(0)} c/u',
                      style: TextStyle(
                        fontSize: 12,
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8651A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.cantidad}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cart.incrementar(index),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8651A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                '\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8651A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vistaCheckout(CartProvider cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen
          const Text(
            'Resumen del pedido',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...cart.items.map((item) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.nombre} x${item.cantidad}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: TextStyle(color: Colors.grey.shade600)),
              Text('\$${cart.subtotal.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IVA (19%):', style: TextStyle(color: Colors.grey.shade600)),
              Text('\$${cart.iva.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Text(
                '\$${cart.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFFE8651A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dirección
          const Text(
            'Dirección de entrega',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          if (_direcciones.isEmpty)
            Text(
              'No tienes direcciones guardadas. Ve a tu perfil y agrega una.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            )
          else
            ..._direcciones.map((dir) {
              final seleccionada =
                  _direccionSeleccionada?['id'] == dir['id'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _direccionSeleccionada = dir),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? const Color(0xFFFFF3ED)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: seleccionada
                          ? const Color(0xFFE8651A)
                          : Colors.grey.shade300,
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
                        child: Text(
                          '${dir['barrio']} - ${dir['direccion']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: seleccionada
                                ? const Color(0xFFE8651A)
                                : Colors.black87,
                            fontWeight: seleccionada
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
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
          const Text(
            'Método de pago',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _metodoPagoOption('pse', 'PSE'),
          const SizedBox(height: 8),
          _metodoPagoOption('contraentrega', 'Pago contraentrega'),
        ],
      ),
    );
  }

  Widget _metodoPagoOption(String valor, String label) {
    final seleccionado = _metodoPago == valor;
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = valor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seleccionado
                  ? const Color(0xFFE8651A)
                  : Colors.grey.shade200,
              border: Border.all(
                color: seleccionado
                    ? const Color(0xFFE8651A)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Text(
                'Total:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '\$${cart.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
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
                disabledBackgroundColor:
                    const Color(0xFFE8651A).withValues(alpha: 0.6),
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
                  : Text(
                      _mostrarCheckout ? 'Confirmar pedido' : 'Ir a pagar',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}