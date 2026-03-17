import 'package:flutter/material.dart';
import '../../../services/address_service.dart';
import '../../../core/theme/app_theme.dart';

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

  String tipoVivienda = "Casa";
  bool loading = false;

  bool get editMode => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (editMode) {
      final a = widget.address!;
      barrioController.text = a["barrio"];
      direccionController.text = a["direccion"];
      torreController.text = a["torreApartamento"] ?? "";
      instruccionesController.text = a["instrucciones"] ?? "";
      tipoVivienda = a["tipoVivienda"];
    }
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final data = {
      "barrio": barrioController.text.trim(),
      "direccion": direccionController.text.trim(),
      "tipoVivienda": tipoVivienda,
      "torreApartamento": torreController.text.trim(),
      "instrucciones": instruccionesController.text.trim(),
    };
    bool ok;
    if (editMode) {
      ok = await _service.updateAddress(widget.address!["id"], data);
    } else {
      ok = await _service.createAddress(data);
    }
    setState(() => loading = false);
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }

  String? validarTexto(String? value) {
    if (value == null || value.trim().isEmpty) return "Campo obligatorio";
    if (value.length < 3) return "Debe tener mínimo 3 caracteres";
    return null;
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 17,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 15,
        color: AppTheme.primaryOrange,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.grey.shade600, size: 22)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppTheme.primaryOrange,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? "Editar dirección" : "Nueva dirección"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryOrange,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 44,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      editMode ? "Editar dirección" : "Nueva dirección",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: barrioController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  "Barrio / Conjunto",
                  icon: Icons.map_outlined,
                ),
                validator: validarTexto,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: direccionController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  "Dirección",
                  icon: Icons.signpost_outlined,
                ),
                validator: validarTexto,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: tipoVivienda,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  "Tipo de vivienda",
                  icon: Icons.home_outlined,
                ),
                borderRadius: BorderRadius.circular(10),
                items: const [
                  DropdownMenuItem(value: "Casa", child: Text("Casa")),
                  DropdownMenuItem(
                    value: "Apartamento",
                    child: Text("Apartamento"),
                  ),
                  DropdownMenuItem(
                    value: "Oficina/Local comercial",
                    child: Text("Oficina / Local comercial"),
                  ),
                  DropdownMenuItem(value: "Hotel", child: Text("Hotel")),
                ],
                onChanged: (v) => setState(() => tipoVivienda = v!),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: torreController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  "Torre / Apartamento (opcional)",
                  icon: Icons.apartment_outlined,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: instruccionesController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  "Instrucciones adicionales",
                  icon: Icons.notes_outlined,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primaryOrange.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          editMode
                              ? "Actualizar dirección"
                              : "Guardar dirección",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}