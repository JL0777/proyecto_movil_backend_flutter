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

  // Decoración reutilizable consistente con AddEditAddressScreen
  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    bool enabled = true,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: enabled ? Colors.black54 : Colors.grey.shade400,
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: enabled ? AppTheme.primaryOrange : Colors.grey.shade400,
      ),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
      prefixIcon: prefixWidget ??
          (icon != null
              ? Icon(icon, color: Colors.grey.shade600, size: 22)
              : null),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    );
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required VoidCallback onSave,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    IconData? icon,
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
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  label,
                  icon: icon,
                  enabled: isEditing,
                  prefixWidget: prefixWidget,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: isEditing
                    ? Colors.grey.shade100
                    : AppTheme.lightOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEditing
                      ? Colors.grey.shade300
                      : AppTheme.primaryOrange.withOpacity(0.3),
                ),
              ),
              child: IconButton(
                onPressed: onEditToggle,
                icon: Icon(
                  isEditing ? Icons.close : Icons.edit,
                  color: isEditing ? Colors.grey.shade600 : AppTheme.primaryOrange,
                  size: 20,
                ),
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
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Campo de contraseña individual con el mismo estilo
  Widget _passwordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(label, icon: Icons.lock_outline),
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
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
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            // Correo
            _editableField(
              label: "Correo",
              controller: _emailController,
              isEditing: _editingEmail,
              onEditToggle: () => setState(() => _editingEmail = !_editingEmail),
              onSave: _updateEmail,
              type: TextInputType.emailAddress,
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),

            // Teléfono con prefijo +57 solo visual
            _editableField(
              label: "Teléfono",
              controller: _phoneController,
              isEditing: _editingPhone,
              onEditToggle: () => setState(() => _editingPhone = !_editingPhone),
              onSave: _updatePhone,
              type: TextInputType.phone,
              prefixWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _inputDecoration(
                      "Cambiar contraseña",
                      icon: Icons.lock_outline,
                      enabled: false,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _editingPassword
                        ? Colors.grey.shade100
                        : AppTheme.lightOrange,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _editingPassword
                          ? Colors.grey.shade300
                          : AppTheme.primaryOrange.withOpacity(0.3),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        setState(() => _editingPassword = !_editingPassword),
                    icon: Icon(
                      _editingPassword ? Icons.close : Icons.edit,
                      color: _editingPassword
                          ? Colors.grey.shade600
                          : AppTheme.primaryOrange,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            if (_editingPassword) ...[
              const SizedBox(height: 16),
              _passwordField("Contraseña actual", _currentPasswordController),
              const SizedBox(height: 12),
              _passwordField("Nueva contraseña", _newPasswordController),
              const SizedBox(height: 12),
              _passwordField("Confirmar contraseña", _confirmPasswordController),
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Guardar contraseña",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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