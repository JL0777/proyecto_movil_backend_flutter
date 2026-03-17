import 'package:flutter/material.dart';
import '../../../services/admin_user_service.dart';
import 'admin_edit_user_screen.dart';

class UsuariosTab extends StatefulWidget {
  const UsuariosTab({super.key});

  @override
  State<UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  final AdminUserService _service = AdminUserService();

  List<dynamic> _usuarios = [];
  List<dynamic> _filtrados = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _searchController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    try {
      final data = await _service.getAllUsers();
      setState(() {
        _usuarios = data;
        _filtrados = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error cargando usuarios"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrar() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtrados = _usuarios.where((u) {
        final nombre = (u['nombre'] ?? '').toLowerCase();
        final email = (u['email'] ?? '').toLowerCase();
        return nombre.contains(query) || email.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8651A)),
      );
    }

    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o correo...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Lista de usuarios
        Expanded(
          child: _filtrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No se encontraron usuarios',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarUsuarios,
                  color: const Color(0xFFE8651A),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtrados.length,
                    itemBuilder: (context, index) {
                      final u = _filtrados[index];
                      return _usuarioCard(u);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _usuarioCard(Map<String, dynamic> u) {
    final nombre = u['nombre'] ?? 'Sin nombre';
    final email = u['email'] ?? '';
    final telefono = u['telefono'] ?? 'Sin teléfono';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8651A),
          child: Text(
            inicial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Text(
              telefono,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3ED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: Color(0xFFE8651A),
            size: 18,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminEditUserScreen(usuario: u),
            ),
          ).then((_) => _cargarUsuarios());
        },
      ),
    );
  }
}