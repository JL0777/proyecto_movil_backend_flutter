import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/utils/logout_helper.dart';
import '../../../services/upload_service.dart';
import '../../../services/user_service.dart';
import 'edit_profile_screen.dart';
import 'my_addresses_screen.dart';
import 'help_screen.dart';

class MyAccountScreen extends StatefulWidget {
  final String email;

  const MyAccountScreen({super.key, required this.email});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  Map<String, dynamic>? user;
  final UploadService _uploadService = UploadService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  bool _subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUser();
    setState(() => user = u);
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _loadUser());
  }

  Future<void> _cambiarFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cambiar foto de perfil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFFE8651A),
                ),
              ),
              title: const Text('Seleccionar de la galería'),
              onTap: () async {
                Navigator.pop(context);
                await _seleccionarFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFFE8651A),
                ),
              ),
              title: const Text('Tomar una foto'),
              onTap: () async {
                Navigator.pop(context);
                await _seleccionarFoto(ImageSource.camera);
              },
            ),
            if (user?['fotoPerfil'] != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text(
                  'Eliminar foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _eliminarFoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFoto(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (imagen == null) return;

    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Subir esta foto?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagen.path),
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8651A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sí, subir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _subiendoFoto = true);

    final fotoAnterior = user?['fotoPerfil'];
    if (fotoAnterior != null && fotoAnterior.toString().isNotEmpty) {
      await _uploadService.eliminarImagen(fotoAnterior);
    }

    final url = await _uploadService.subirImagen(File(imagen.path));

    if (url != null) {
      final result = await _userService.updateFotoPerfil(url);
      if (result['success']) {
        await _loadUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto actualizada correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir la imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _subiendoFoto = false);
  }

  Future<void> _eliminarFoto() async {
    setState(() => _subiendoFoto = true);

    final fotoAnterior = user?['fotoPerfil'];
    if (fotoAnterior != null && fotoAnterior.toString().isNotEmpty) {
      await _uploadService.eliminarImagen(fotoAnterior);
    }

    final result = await _userService.updateFotoPerfil('');
    if (result['success']) {
      await _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto eliminada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    setState(() => _subiendoFoto = false);
  }

  @override
  Widget build(BuildContext context) {
    final email = user?["email"] ?? widget.email;
    final nombre = user?["nombre"] ?? "";
    final fotoPerfil = user?["fotoPerfil"];
    // Altura de la status bar para que el naranja la cubra
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header naranja que cubre desde el borde superior
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            // El padding superior incluye la status bar
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 30),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _cambiarFoto,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _subiendoFoto
                              ? Container(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFE8651A),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : fotoPerfil != null &&
                                    fotoPerfil.toString().isNotEmpty
                              ? Image.network(
                                fotoPerfil,
                                fit: BoxFit.cover,
                                key: ValueKey(fotoPerfil),
                                errorBuilder: (errContext, errObj, errStack) =>
                                    _avatarPlaceholder(),
                              )
                              : _avatarPlaceholder(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _cambiarFoto,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE8651A),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFFE8651A),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (nombre.isNotEmpty)
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menú
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi cuenta',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _menuItem(
                  icon: Icons.person_outline,
                  title: 'Editar información personal',
                  subtitle: 'Nombre, correo y teléfono',
                  onTap: () => _navigate(context, const EditProfileScreen()),
                ),
                _menuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Mis direcciones',
                  subtitle: 'Gestiona tus direcciones de entrega',
                  onTap: () => _navigate(context, MyAddressesScreen()),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Soporte',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _menuItem(
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  subtitle: 'Preguntas frecuentes y soporte',
                  onTap: () => _navigate(context, const HelpScreen()),
                ),

                const SizedBox(height: 16),
                _menuItem(
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de tu cuenta',
                  iconColor: Colors.red,
                  iconBg: const Color(0xFFFEF2F2),
                  titleColor: Colors.red,
                  onTap: () => LogoutHelper.confirmarCierreSesion(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: const Color(0xFFFFF3ED),
      child: const Icon(Icons.person, size: 55, color: Color(0xFFE8651A)),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primaryOrange,
    Color iconBg = AppTheme.lightOrange,
    Color titleColor = const Color(0xFF1A1A1A),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.chevron_right, color: iconColor, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }
}