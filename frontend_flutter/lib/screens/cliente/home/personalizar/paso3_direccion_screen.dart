import 'package:flutter/material.dart';
import '../../../../services/address_service.dart';
import 'paso4_pago_screen.dart';

class Paso3DireccionScreen extends StatefulWidget {
  final Map<String, dynamic> categoria;
  final Map<String, dynamic> ingredientes;
  final Map<String, dynamic> bebida;
  final Map<String, Map<String, int>> complementos;
  final double subtotal;

  const Paso3DireccionScreen({
    super.key,
    required this.categoria,
    required this.ingredientes,
    required this.bebida,
    required this.complementos,
    required this.subtotal,
  });

  @override
  State<Paso3DireccionScreen> createState() => _Paso3DireccionScreenState();
}

class _Paso3DireccionScreenState extends State<Paso3DireccionScreen> {
  final AddressService _service = AddressService();

  List<dynamic> _direcciones = [];
  Map<String, dynamic>? _direccionSeleccionada;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getAddresses();
      setState(() {
        _direcciones = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildPasos(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE8651A),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATOS DE ENVÍO',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 3,
                          color: const Color(0xFFE8651A),
                        ),
                        const SizedBox(height: 24),

                        if (_direcciones.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_off_outlined,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No tienes direcciones guardadas',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ve a tu perfil y agrega una dirección',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          const Text(
                            'Mis Direcciones',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE8651A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._direcciones.map((dir) {
                            final seleccionada =
                                _direccionSeleccionada?['id'] == dir['id'];

                            return GestureDetector(
                              onTap: () => setState(
                                () => _direccionSeleccionada = dir,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: seleccionada
                                      ? const Color(0xFFFFF3ED)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
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
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dir['barrio'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: seleccionada
                                                  ? const Color(0xFFE8651A)
                                                  : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            dir['direccion'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (seleccionada)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFE8651A),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
          ),

          // Footer
          Container(
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _direccionSeleccionada != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Paso4PagoScreen(
                              categoria: widget.categoria,
                              ingredientes: widget.ingredientes,
                              bebida: widget.bebida,
                              complementos: widget.complementos,
                              direccion: _direccionSeleccionada!,
                              subtotal: widget.subtotal,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8651A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildPasos() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _paso(1, 'Ingredientes', false),
          _lineaPaso(),
          _paso(2, 'Complementos', false),
          _lineaPaso(),
          _paso(3, 'Dirección', true),
          _lineaPaso(),
          _paso(4, 'Pago', false),
        ],
      ),
    );
  }

  Widget _paso(int numero, String label, bool activo) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? const Color(0xFFE8651A) : Colors.grey.shade200,
            border: Border.all(
              color: activo ? const Color(0xFFE8651A) : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              '$numero',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: activo ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: activo ? const Color(0xFFE8651A) : Colors.grey,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _lineaPaso() {
    return Container(
      width: 24,
      height: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }
}