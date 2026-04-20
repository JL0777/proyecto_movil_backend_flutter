import 'package:flutter/material.dart';
import '../../../services/address_service.dart';
import '../../../core/theme/app_theme.dart';
import 'add_edit_address_screen.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final AddressService _service = AddressService();

  List addresses = [];
  bool loading = true;

  void mensaje(String texto, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: ok ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  Future<void> cargar() async {
    try {
      final data = await _service.getAddresses();
      setState(() {
        addresses = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      mensaje("Error cargando direcciones", false);
    }
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> agregar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
    );
    if (result == true) {
      mensaje("Dirección agregada correctamente", true);
      cargar();
    }
  }

  Future<void> editar(Map address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: address)),
    );
    if (result == true) {
      mensaje("Dirección actualizada correctamente", true);
      cargar();
    }
  }

  Future<void> eliminar(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text("¿Eliminar?", style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: const Text(
            "Esta dirección se eliminará permanentemente de tu cuenta.",
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _service.deleteAddress(id);
        mensaje("Dirección eliminada correctamente", true);
        cargar();
      } catch (e) {
        mensaje("No se pudo eliminar la dirección", false);
      }
    }
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case "Apartamento":
        return Icons.apartment_rounded;
      case "Oficina/Local comercial":
        return Icons.business_center_rounded;
      case "Hotel":
        return Icons.hotel_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  Widget tarjetaDireccion(Map a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF2F2F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            _iconForTipo(a["tipoVivienda"]),
            color: AppTheme.primaryOrange,
            size: 28,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            a["direccion"],
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
        subtitle: Text(
          "${a["barrio"]} • ${a["tipoVivienda"]}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
          elevation: 4,
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "editar",
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 20, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  const Text("Editar", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            PopupMenuItem(
              value: "eliminar",
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade400),
                  const SizedBox(width: 12),
                  Text("Eliminar", 
                    style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == "editar") editar(a);
            if (value == "eliminar") eliminar(a["id"]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryOrange, size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              "Mis direcciones",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: agregar,
        backgroundColor: AppTheme.primaryOrange,
        elevation: 6,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          "",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : addresses.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            size: 60,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "¡No has agregado ninguna dirección!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Agrega una para que podamos\nllevarte tu comida favorita.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton.icon(
                          onPressed: agregar,
                          icon: const Icon(Icons.add_rounded, size: 22),
                          label: const Text("AGREGAR DIRECCIÓN", style: TextStyle(fontWeight: FontWeight.w900)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 110),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    return tarjetaDireccion(addresses[index]);
                  },
                ),
    );
  }
}