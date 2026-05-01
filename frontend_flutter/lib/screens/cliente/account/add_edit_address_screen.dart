import 'package:flutter/material.dart';
import '../../../services/address_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Map? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final AddressService _service = AddressService();
  final _formKey = GlobalKey<FormState>();

  final barrioController = TextEditingController();
  final direccionController = TextEditingController();
  final torreController = TextEditingController();
  final instruccionesController = TextEditingController();

  String tipoVivienda = 'Casa';
  bool loading = false;

  bool get editMode => widget.address != null;

  String _normalizarTipoVivienda(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'apartamento':
        return 'Apartamento';
      case 'oficina':
      case 'oficina/local comercial':
        return 'Oficina/Local comercial';
      case 'hotel':
        return 'Hotel';
      default:
        return 'Casa';
    }
  }

  @override
  void initState() {
    super.initState();
    if (editMode) {
      final a = widget.address!;
      barrioController.text = a['barrio']?.toString() ?? '';
      direccionController.text = a['direccion']?.toString() ?? '';
      torreController.text = a['torreApartamento']?.toString() ?? '';
      instruccionesController.text = a['instrucciones']?.toString() ?? '';
      tipoVivienda = _normalizarTipoVivienda(
        a['tipoVivienda']?.toString() ?? 'Casa',
      );
    }
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final data = {
      'barrio': barrioController.text.trim(),
      'direccion': direccionController.text.trim(),
      'tipoVivienda': tipoVivienda,
      'torreApartamento': torreController.text.trim(),
      'instrucciones': instruccionesController.text.trim(),
    };
    bool ok;
    if (editMode) {
      ok = await _service.updateAddress(widget.address!['id'], data);
    } else {
      ok = await _service.createAddress(data);
    }
    setState(() => loading = false);
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }

  String? validarTexto(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
    if (value.length < 3) return 'Debe tener mínimo 3 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Selector tipo vivienda ──
                    _buildSelectorTipo(),
                    const SizedBox(height: 16),

                    // ── Campos ──
                    _buildTarjeta(
                      icono: Icons.location_on_outlined,
                      color: const Color(0xFFE8651A),
                      titulo: 'Ubicación',
                      child: Column(
                        children: [
                          _campo(
                            controller: barrioController,
                            label: 'Barrio / Conjunto',
                            icono: Icons.map_outlined,
                            validator: validarTexto,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: direccionController,
                            label: 'Dirección',
                            icono: Icons.signpost_outlined,
                            validator: validarTexto,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildTarjeta(
                      icono: Icons.info_outline,
                      color: Colors.blue,
                      titulo: 'Detalles adicionales',
                      child: Column(
                        children: [
                          _campo(
                            controller: torreController,
                            label: 'Torre / Apartamento (opcional)',
                            icono: Icons.apartment_outlined,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: instruccionesController,
                            label: 'Instrucciones para el domiciliario',
                            icono: Icons.notes_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Botón guardar ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8651A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE8651A)
                              .withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    editMode
                                        ? Icons.check_circle_outline
                                        : Icons.save_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    editMode
                                        ? 'Actualizar dirección'
                                        : 'Guardar dirección',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editMode ? 'Editar dirección' : 'Nueva dirección',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                editMode
                    ? 'Modifica los datos de tu dirección'
                    : 'Completa los datos de entrega',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Selector tipo vivienda ─────────────────────────────────

  Widget _buildSelectorTipo() {
    final tipos = [
      ('Casa', Icons.home_outlined),
      ('Apartamento', Icons.apartment_outlined),
      ('Oficina/Local comercial', Icons.business_center_outlined),
      ('Hotel', Icons.hotel_outlined),
    ];

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
                  color: const Color(0xFFE8651A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home_outlined,
                    color: Color(0xFFE8651A), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tipo de vivienda',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: tipos.map((t) {
              final (label, icono) = t;
              final seleccionado = tipoVivienda == label;
              final labelCorto = label == 'Oficina/Local comercial'
                  ? 'Oficina'
                  : label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => tipoVivienda = label),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: label != 'Hotel' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? const Color(0xFFE8651A)
                              .withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: seleccionado
                            ? const Color(0xFFE8651A)
                                .withValues(alpha: 0.5)
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
    );
  }

  // ── Tarjeta de sección ─────────────────────────────────────

  Widget _buildTarjeta({
    required IconData icono,
    required Color color,
    required String titulo,
    required Widget child,
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
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── Campo de texto ─────────────────────────────────────────

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFFE8651A),
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icono, color: Colors.grey.shade400, size: 18),
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
          borderSide:
              const BorderSide(color: Color(0xFFE8651A), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 14),
      ),
    );
  }
}