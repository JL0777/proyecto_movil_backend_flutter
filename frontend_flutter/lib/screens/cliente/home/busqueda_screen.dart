import 'package:flutter/material.dart';
import '../../../services/menu_service.dart';
import 'menu_detail_screen.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final MenuService _service = MenuService();
  final TextEditingController _controller = TextEditingController();

  List<dynamic> _resultados = [];
  bool _loading = false;
  bool _buscado = false;

  static const _primary = Color(0xFFE8651A);
  static const _primaryLight = Color(0xFFFFF3ED);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _buscado = false;
    });
    try {
      final data = await _service.buscar(query.trim());
      setState(() {
        _resultados = data;
        _loading = false;
        _buscado = true;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _buscado = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: const Color(0xFF1A0A00),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 10,
            16,
            10,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          cursorColor: _primary,
                          decoration: InputDecoration(
                            hintText: 'Buscar menús...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: _buscar,
                          onChanged: (v) {
                            if (v.trim().length >= 3) _buscar(v);
                            setState(() {});
                          },
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() {
                              _resultados = [];
                              _buscado = false;
                            });
                          },
                          child: Icon(Icons.close,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : !_buscado
              ? _EmptyState(
                  icon: Icons.search_rounded,
                  title: 'Busca tu menú favorito',
                  subtitle: 'Escribe al menos 3 caracteres',
                )
              : _resultados.isEmpty
                  ? _EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Sin resultados',
                      subtitle: 'Intenta con otro término',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _resultados.length,
                      itemBuilder: (context, index) {
                        final menu = _resultados[index];
                        final precio =
                            double.parse(menu['precio'].toString());
                        final categoria = menu['Categoria'];

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MenuDetailScreen(menu: menu),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.black12, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                // Imagen / placeholder
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: menu['imagenUrl'] != null &&
                                          menu['imagenUrl']
                                              .toString()
                                              .isNotEmpty
                                      ? Image.network(
                                          menu['imagenUrl'],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _placeholder(),
                                        )
                                      : _placeholder(),
                                ),
                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menu['nombre'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (categoria != null) ...[
                                          const SizedBox(height: 5),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _primaryLight,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: const Color(
                                                      0xFFF0DACE),
                                                  width: 0.5),
                                            ),
                                            child: Text(
                                              categoria['nombre'],
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          '\$${precio.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: _primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(Icons.chevron_right,
                                      color: _primary, size: 20),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 90,
      color: _primaryLight,
      child: const Icon(Icons.fastfood_outlined, color: _primary, size: 32),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF0DACE), width: 0.5),
            ),
            child: Icon(icon, size: 36, color: const Color(0xFFE8651A)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}