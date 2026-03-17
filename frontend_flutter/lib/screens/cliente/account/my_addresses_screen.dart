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
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppTheme.primaryOrange),
              SizedBox(width: 8),
              Text("Eliminar dirección"),
            ],
          ),
          content: const Text("¿Seguro que deseas eliminar esta dirección?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Eliminar"),
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
        return Icons.apartment;
      case "Oficina/Local comercial":
        return Icons.store_outlined;
      case "Hotel":
        return Icons.hotel_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  Widget tarjetaDireccion(Map a) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.lightOrange,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
          ),
          child: Icon(
            _iconForTipo(a["tipoVivienda"]),
            color: AppTheme.primaryOrange,
            size: 24,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            a["direccion"],
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        subtitle: Text(
          "${a["barrio"]} • ${a["tipoVivienda"]}",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "editar",
              child: Row(
                children: const [
                  Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryOrange),
                  SizedBox(width: 10),
                  Text(
                    "Editar",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: "eliminar",
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                  const SizedBox(width: 10),
                  Text(
                    "Eliminar",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade400,
                    ),
                  ),
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

      appBar: AppBar(
        title: const Text("Mis direcciones"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: agregar,
        backgroundColor: AppTheme.primaryOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          Icons.location_off_outlined,
                          size: 44,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Sin direcciones registradas",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Agrega una para continuar",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: agregar,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Agregar dirección",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    return tarjetaDireccion(addresses[index]);
                  },
                ),
    );
  }
}