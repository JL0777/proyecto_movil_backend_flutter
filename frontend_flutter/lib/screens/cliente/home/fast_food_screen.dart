import 'package:flutter/material.dart';
import '../../../services/categoria_service.dart';
import 'categoria_screen.dart';

class FastFoodScreen extends StatefulWidget {
  const FastFoodScreen({super.key});

  @override
  State<FastFoodScreen> createState() => _FastFoodScreenState();
}

class _FastFoodScreenState extends State<FastFoodScreen> {
  final CategoriaService _service = CategoriaService();
  List<dynamic> _categorias = [];
  bool _loading = true;

  static const _primary = Color(0xFFE8651A);
  static const _primaryLight = Color(0xFFFFF3ED);

  final Map<String, _CatConfig> _config = {
    'hamburguesas': _CatConfig(
      icono: Icons.lunch_dining_outlined,
      descripcion: 'Jugosas y recién preparadas',
      accentColor: Color(0xFFE8651A),
    ),
    'perros': _CatConfig(
      icono: Icons.fastfood_outlined,
      descripcion: 'Clásicos al estilo colombiano',
      accentColor: Color(0xFFD85A30),
    ),
    'salchipapas': _CatConfig(
      icono: Icons.food_bank_outlined,
      descripcion: 'El favorito de siempre',
      accentColor: Color(0xFF993C1D),
    ),
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await _service.getByTipo('rapida');
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
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_categorias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay categorías disponibles',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Text(
                'CATEGORÍAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  border: Border.all(
                    color: const Color(0xFFF0DACE),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_categorias.length} disponibles',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: _categorias.length,
            itemBuilder: (context, index) {
              final cat = _categorias[index];
              final nombre = cat['nombre'] as String;
              final cfg =
                  _config[nombre.toLowerCase()] ??
                  _CatConfig(
                    icono: Icons.fastfood_outlined,
                    descripcion: '',
                    accentColor: _primary,
                  );

              return _CategoriaCard(
                nombre: nombre,
                config: cfg,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoriaScreen(categoria: cat),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatConfig {
  final IconData icono;
  final String descripcion;
  final Color accentColor;

  const _CatConfig({
    required this.icono,
    required this.descripcion,
    required this.accentColor,
  });
}

class _CategoriaCard extends StatelessWidget {
  const _CategoriaCard({
    required this.nombre,
    required this.config,
    required this.onTap,
  });

  final String nombre;
  final _CatConfig config;
  final VoidCallback onTap;

  static const _primaryLight = Color(0xFFFFF3ED);
  static const _primary = Color(0xFFE8651A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          config.accentColor,
                          config.accentColor.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(config.icono, color: _primary, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre[0].toUpperCase() +
                                    nombre.substring(1).toLowerCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (config.descripcion.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  config.descripcion,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: _primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: _primary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
