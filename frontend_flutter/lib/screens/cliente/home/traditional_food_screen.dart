import 'package:flutter/material.dart';
import '../../../services/categoria_service.dart';
import 'categoria_screen.dart';

class TraditionalFoodScreen extends StatefulWidget {
  const TraditionalFoodScreen({super.key});

  @override
  State<TraditionalFoodScreen> createState() => _TraditionalFoodScreenState();
}

class _TraditionalFoodScreenState extends State<TraditionalFoodScreen> {
  final CategoriaService _service = CategoriaService();
  List<dynamic> _categorias = [];
  bool _loading = true;

  final Map<String, IconData> _iconos = {
    'desayuno': Icons.free_breakfast_outlined,
    'almuerzo': Icons.restaurant_outlined,
    'cena': Icons.dinner_dining_outlined,
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getByTipo('tradicional');
      setState(() {
        _categorias = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8651A)),
      );
    }

    if (_categorias.isEmpty) {
      return const Center(
        child: Text(
          'No hay categorías disponibles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _categorias.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final cat = _categorias[index];
        final nombre = cat['nombre'] as String;
        final icono = _iconos[nombre.toLowerCase()] ??
            Icons.restaurant_outlined;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: const Color(0xFFE8651A), size: 30),
          ),
          title: Text(
            nombre.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFFE8651A),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoriaScreen(categoria: cat),
              ),
            );
          },
        );
      },
    );
  }
}