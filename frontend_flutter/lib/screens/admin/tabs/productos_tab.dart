import 'package:flutter/material.dart';
import 'gestion_menus_screen.dart';
import 'gestion_ingredientes_screen.dart';

class ProductosTab extends StatefulWidget {
  const ProductosTab({super.key});

  @override
  State<ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends State<ProductosTab> {
  String? _opcionSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué deseas gestionar?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _opcionSeleccionada,
                hint: const Text(
                  'Selecciona una opción',
                  style: TextStyle(color: Colors.grey),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFE8651A),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'menus',
                    child: Text('Gestión de menú'),
                  ),
                  DropdownMenuItem(
                    value: 'ingredientes',
                    child: Text('Gestión de productos'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() => _opcionSeleccionada = valor);
                  if (valor == 'menus') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GestionMenusScreen(),
                      ),
                    );
                  } else if (valor == 'ingredientes') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GestionIngredientesScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Selecciona una opción para continuar',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}