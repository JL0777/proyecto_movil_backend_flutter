import 'package:flutter/material.dart';
import '../../../services/user_service.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final UserService _userService = UserService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  bool _editingName = false;
  bool _editingEmail = false;
  bool _editingPhone = false;
  bool _editingPassword = false;

  Map<String,dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUser();
    if (!mounted) return;
    if (u != null) {
      setState(() {
        user = u;
        _nameController.text = u['nombre'] ?? "";
        _emailController.text = u['email'] ?? "";
        _phoneController.text = u['telefono'] ?? "";
      });
    }
  }

  void _showMessage(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  /// Valida número colombiano:
  /// - Celular: empieza en 3, exactamente 10 dígitos (ej: 3001234567)
  /// - Fijo: 7 dígitos, primera cifra 1,2,4,5,6,7 u 8
  bool _isValidColombianPhone(String number) {
    if (!RegExp(r'^\d+$').hasMatch(number)) return false;
    if (number.startsWith('3') && number.length == 10) return true;
    if (number.length == 7 && RegExp(r'^[1245678]').hasMatch(number)) return true;
    return false;
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage("El nombre no puede estar vacío");
      return;
    }
    setState(() => _loading = true);
    final result = await _userService.updateName(_nameController.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (result["success"]) {
      await _loadUser();
      setState(() => _editingName = false);
      _showMessage("Nombre actualizado", ok: true);
    } else {
      _showMessage(result["error"]);
    }
  }

  Future<void> _updateEmail() async {
    String email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage("Correo inválido");
      return;
    }
    setState(() => _loading = true);
    final result = await _userService.updateEmail(user!["email"], email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result["success"]) {
      await _loadUser();
      setState(() => _editingEmail = false);
      _showMessage("Correo actualizado", ok: true);
    } else {
      _showMessage(result["error"]);
    }
  }

  Future<void> _updatePhone() async {
    String phone = _phoneController.text.trim();
    if (!_isValidColombianPhone(phone)) {
      _showMessage(
        "Número inválido. Celular: 10 dígitos comenzando en 3 (ej: 3001234567). "
        "Fijo: 7 dígitos (ej: 2345678).",
      );
      return;
    }
    setState(() => _loading = true);
    final result = await _userService.updatePhone(user!["telefono"], phone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result["success"]) {
      await _loadUser();
      setState(() => _editingPhone = false);
      _showMessage("Teléfono actualizado", ok: true);
    } else {
      _showMessage(result["error"]);
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.length < 6) {
      _showMessage("La contraseña debe tener mínimo 6 caracteres");
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showMessage("Las contraseñas no coinciden");
      return;
    }
    setState(() => _loading = true);
    final result = await _userService.updatePassword(
      _currentPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result["success"]) {
      setState(() => _editingPassword = false);
      _showMessage("Contraseña actualizada", ok: true);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      _showMessage(result["error"]);
    }
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required VoidCallback onSave,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    Widget? prefixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isEditing,
                obscureText: isPassword,
                keyboardType: type,
                decoration: InputDecoration(
                  labelText: label,
                  filled: true,
                  fillColor: isEditing ? Colors.white : Colors.grey.shade100,
                  prefixIcon: prefixWidget,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryOrange,
                      width: 1.8,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  labelStyle: TextStyle(
                    color: isEditing
                        ? AppTheme.primaryOrange
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onEditToggle,
              icon: Icon(
                isEditing ? Icons.close : Icons.edit,
                color: isEditing ? Colors.grey : AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
        if (isEditing) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Guardar"),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Editar perfil"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // Ícono de perfil naranja
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
                Icons.person,
                size: 50,
                color: AppTheme.primaryOrange,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user!['email'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 28),

            // Nombre
            _editableField(
              label: "Nombre",
              controller: _nameController,
              isEditing: _editingName,
              onEditToggle: () => setState(() => _editingName = !_editingName),
              onSave: _updateName,
            ),

            const SizedBox(height: 16),

            // Correo
            _editableField(
              label: "Correo",
              controller: _emailController,
              isEditing: _editingEmail,
              onEditToggle: () =>
                  setState(() => _editingEmail = !_editingEmail),
              onSave: _updateEmail,
              type: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Teléfono con prefijo +57 solo visual
            _editableField(
              label: "Teléfono",
              controller: _phoneController,
              isEditing: _editingPhone,
              onEditToggle: () =>
                  setState(() => _editingPhone = !_editingPhone),
              onSave: _updatePhone,
              type: TextInputType.phone,
              prefixWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Text(
                  "+57",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _editingPhone
                        ? AppTheme.primaryOrange
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            // Contraseña - fila colapsada
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Cambiar contraseña",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      setState(() => _editingPassword = !_editingPassword),
                  icon: Icon(
                    _editingPassword ? Icons.close : Icons.edit,
                    color: _editingPassword
                        ? Colors.grey
                        : AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),

            if (_editingPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña actual",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryOrange,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nueva contraseña",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryOrange,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryOrange,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Guardar contraseña"),
                ),
              ),
            ],

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: 30),

          ],

        ),

      ),

    );

  }

}