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

  void _mostrarFormularioNuevaDireccion() {
    final barrioController = TextEditingController();
    final direccionController = TextEditingController();
    final instruccionesController = TextEditingController();
    String tipoVivienda = 'Casa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (nuevaDirSheetCtx) => StatefulBuilder(
        builder: (nuevaDirSheetCtx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(nuevaDirSheetCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nueva dirección',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                _campo(barrioController, 'Barrio'),
                const SizedBox(height: 12),
                _campo(direccionController, 'Dirección'),
                const SizedBox(height: 12),
                _campo(instruccionesController, 'Instrucciones (opcional)',
                    maxLines: 2),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tipoVivienda,
                      isExpanded: true,
                      items: ['Casa', 'Apartamento', 'Oficina/Local comercial', 'Hotel']
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => tipoVivienda = v ?? tipoVivienda),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (barrioController.text.trim().isEmpty ||
                          direccionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(nuevaDirSheetCtx).showSnackBar(
                          const SnackBar(
                            content: Text('Barrio y dirección son requeridos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Capturamos nav y messenger ANTES del await
                      final nav = Navigator.of(nuevaDirSheetCtx);
                      final messenger = ScaffoldMessenger.of(context);

                      final ok = await _service.createAddress({
                        'barrio': barrioController.text.trim(),
                        'direccion': direccionController.text.trim(),
                        'instrucciones': instruccionesController.text.trim(),
                        'tipoVivienda': tipoVivienda,
                      });

                      nav.pop();

                      if (ok) {
                        await _cargar();
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Dirección agregada correctamente'),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Guardar dirección',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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

  Widget _campo(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE8651A),
            width: 1.8,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
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

                        GestureDetector(
                          onTap: _mostrarFormularioNuevaDireccion,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8651A),
                                width: 1.5,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.add_location_alt_outlined,
                                  color: Color(0xFFE8651A),
                                  size: 22,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Agregar nueva dirección',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE8651A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

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
                                  'Toca el botón de arriba para agregar una',
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
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 26,
            ),
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