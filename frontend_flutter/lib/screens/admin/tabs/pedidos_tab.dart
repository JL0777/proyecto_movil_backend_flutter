import 'package:flutter/material.dart';

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab> {

  final List<Map<String, dynamic>> _pedidos = [
    {
      'id': 1,
      'cliente': 'Juan Pérez',
      'telefono': '3001234567',
      'nombrePedido': 'Bandeja Paisa',
      'descripcion': 'Sin frijoles, extra arroz',
      'valor': 25000,
      'estado': 'Realizado',
      'direccion': 'Calle 5 # 10-20',
      'barrio': 'El Poblado',
      'tipoVivienda': 'Apartamento',
      'instrucciones': 'Timbre 302',
      'imagenUrl': '',
    },
  ];

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Enviado':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  void _mostrarInfoCliente(Map<String, dynamic> pedido, int numero) {
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
                _infoRow('Cliente:', pedido['cliente']),
                const SizedBox(height: 12),
                _infoRow('Teléfono:', pedido['telefono']),
                const SizedBox(height: 12),
                _infoRow('Dirección:', pedido['direccion']),
                const SizedBox(height: 12),
                _infoRow('Barrio:', pedido['barrio']),
                const SizedBox(height: 12),
                _infoRow('Tipo de vivienda:', pedido['tipoVivienda']),
                const SizedBox(height: 12),
                _infoRow('Instrucciones:', pedido['instrucciones']),
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
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                Center(
                  child: Container(
                    width: 150,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _infoRow('Número del pedido:', '#$numero'),
                const SizedBox(height: 12),
                _infoRow('Nombre del pedido:', pedido['nombrePedido']),
                const SizedBox(height: 12),
                _infoRow('Descripción:', pedido['descripcion']),
                const SizedBox(height: 12),
                _infoRow('Valor:', '\$${pedido['valor']}'),
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

  @override
  Widget build(BuildContext context) {
    if (_pedidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No hay pedidos aún',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pedidos.length,
      itemBuilder: (context, index) {
        final pedido = _pedidos[index];
        final numero = index + 1;

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
                Text(pedido['cliente']),
                const SizedBox(width: 16),
                const Text('Tipo: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Expanded(child: Text(pedido['nombrePedido'])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Valor: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '\$${pedido['valor']}',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Estado: ',
                                style: TextStyle(fontSize: 12)),
                            DropdownButton<String>(
                              value: pedido['estado'],
                              underline: const SizedBox(),
                              isDense: true,
                              style: TextStyle(
                                color: _colorEstado(pedido['estado']),
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
                              onChanged: (nuevoEstado) {
                                if (nuevoEstado != null) {
                                  setState(() {
                                    _pedidos[index]['estado'] = nuevoEstado;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Estado cambiado a "$nuevoEstado" ✓',
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              },
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
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
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
    );
  }
}