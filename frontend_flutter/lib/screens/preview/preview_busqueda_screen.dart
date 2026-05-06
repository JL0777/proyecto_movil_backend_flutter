import 'package:flutter/material.dart';
import '../../../services/menu_service.dart';

class PreviewBusquedaScreen extends StatefulWidget {
  const PreviewBusquedaScreen({super.key});

  @override
  State<PreviewBusquedaScreen> createState() => _PreviewBusquedaScreenState();
}

class _PreviewBusquedaScreenState extends State<PreviewBusquedaScreen> {
  final MenuService _menuService = MenuService();
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _resultados = [];
  bool _loading = false;
  bool _buscado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _buscado = true;
    });
    try {
      final data = await _menuService.buscarPublico(query.trim());
      setState(() => _resultados = data);
    } catch (e) {
      setState(() => _resultados = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0x55000000),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              16,
            ),
            child: Column(
              children: [
                Row(
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Buscar platillos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Campo búsqueda
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                          cursorColor: const Color(0xFFE8651A),
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
                          textInputAction: TextInputAction.search,
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
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Resultados ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
                  )
                : !_buscado
                ? _estadoInicial()
                : _resultados.isEmpty
                ? _sinResultados()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _resultados.length,
                    itemBuilder: (_, i) => _itemResultado(_resultados[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _estadoInicial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8651A).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, size: 44, color: Color(0xFFE8651A)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Busca tu platillo favorito',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Escribe el nombre y presiona Enter',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.no_meals_outlined,
              size: 44,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "${_controller.text}"',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta con otro nombre',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _itemResultado(Map<String, dynamic> menu) {
    final precio = double.tryParse(menu['precio'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
            child:
                menu['imagenUrl'] != null &&
                    menu['imagenUrl'].toString().isNotEmpty
                ? Image.network(
                    menu['imagenUrl'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (menu['descripcion'] != null &&
                      menu['descripcion'].toString().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      menu['descripcion'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE8651A),
                        ),
                      ),
                      // Badge modo invitado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE8651A,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFFE8651A,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'Inicia sesión para pedir',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8651A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.fastfood_outlined,
        color: Colors.grey.shade300,
        size: 30,
      ),
    );
  }
}
