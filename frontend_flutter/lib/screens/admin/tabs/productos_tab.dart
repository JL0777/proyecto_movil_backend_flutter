import 'package:flutter/material.dart';

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
                    value: 'menu',
                    child: Text('Editar menú'),
                  ),
                  DropdownMenuItem(
                    value: 'productos',
                    child: Text('Editar productos'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() => _opcionSeleccionada = valor);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_opcionSeleccionada == 'menu')
            _seccionEnConstruccion(
              icono: Icons.menu_book_outlined,
              titulo: 'Editar menú',
            ),
          if (_opcionSeleccionada == 'productos')
            _seccionEnConstruccion(
              icono: Icons.fastfood_outlined,
              titulo: 'Editar productos',
            ),
          if (_opcionSeleccionada == null)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 60),
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

  Widget _seccionEnConstruccion({
    required IconData icono,
    required String titulo,
  }) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE8651A),
                width: 2,
              ),
            ),
            child: Icon(icono, size: 40, color: const Color(0xFFE8651A)),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'En construcción 🚧',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}