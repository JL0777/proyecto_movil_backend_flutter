import 'package:flutter/material.dart';
import '../../services/categoria_service.dart';
import 'preview_categoria_screen.dart';

class PreviewFastFoodScreen extends StatefulWidget {
  const PreviewFastFoodScreen({super.key});

  @override
  State<PreviewFastFoodScreen> createState() => _PreviewFastFoodScreenState();
}

class _PreviewFastFoodScreenState extends State<PreviewFastFoodScreen> {
  final CategoriaService _service = CategoriaService();
  List<dynamic> _categorias = [];
  bool _loading = true;

  final Map<String, IconData> _iconos = {
    'hamburguesas': Icons.lunch_dining_outlined,
    'perros': Icons.fastfood_outlined,
    'salchipapas': Icons.food_bank_outlined,
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getByTipoPublico('rapida');
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
        final icono =
            _iconos[nombre.toLowerCase()] ?? Icons.fastfood_outlined;

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
                builder: (_) => PreviewCategoriaScreen(categoria: cat),
              ),
            );
          },
        );
      },
    );
  }
}