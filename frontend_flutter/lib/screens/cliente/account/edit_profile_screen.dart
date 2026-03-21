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

  Map<String, dynamic>? user;

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _isValidColombianPhone(String number) {
    if (!RegExp(r'^\d+$').hasMatch(number)) return false;
    if (number.startsWith('3') && number.length == 10) return true;
    if (number.length == 7 && RegExp(r'^[1245678]').hasMatch(number))
      return true;
    return false;
  }

  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasNumber && hasMinLength;
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
    String newEmail = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(newEmail)) {
      _showMessage("Correo inválido");
      return;
    }
    if (newEmail == user!["email"]) {
      _showMessage("El nuevo correo debe ser diferente al actual");
      return;
    }
    setState(() => _loading = true);
    final result = await _userService.solicitarCodigoEmail(newEmail);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result["success"]) {
      _mostrarDialogCodigoEmail(newEmail);
    } else {
      _showMessage(result["error"]);
    }
  }

  void _mostrarDialogCodigoEmail(String newEmail) {
    final codigoController = TextEditingController();
    bool loadingDialog = false;
    bool reenviando = false;
    int segundosRestantes = 30;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (segundosRestantes == 30) {
              Future.doWhile(() async {
                await Future.delayed(const Duration(seconds: 1));
                if (!context.mounted) return false;
                setStateDialog(() {
                  if (segundosRestantes > 0) segundosRestantes--;
                });
                return segundosRestantes > 0;
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Verifica tu nuevo correo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enviamos un código de 6 dígitos a $newEmail.",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Código',
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
                  const SizedBox(height: 16),
                  Center(
                    child: reenviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryOrange,
                              strokeWidth: 2,
                            ),
                          )
                        : segundosRestantes > 0
                        ? Text(
                            "Reenviar en $segundosRestantes s",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          )
                        : GestureDetector(
                            onTap: () async {
                              setStateDialog(() => reenviando = true);
                              final result = await _userService
                                  .solicitarCodigoEmail(newEmail);
                              if (!context.mounted) return;
                              setStateDialog(() {
                                reenviando = false;
                                segundosRestantes = 30;
                              });
                              if (result['success']) {
                                codigoController.clear();
                                Future.doWhile(() async {
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  if (!context.mounted) return false;
                                  setStateDialog(() {
                                    if (segundosRestantes > 0)
                                      segundosRestantes--;
                                  });
                                  return segundosRestantes > 0;
                                });
                              }
                            },
                            child: const Text(
                              '¿No recibiste el código? Reenviar',
                              style: TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: loadingDialog
                      ? null
                      : () async {
                          if (codigoController.text.trim().isEmpty) return;
                          setStateDialog(() => loadingDialog = true);
                          final result = await _userService.updateEmail(
                            user!["email"],
                            newEmail,
                            codigoController.text.trim(),
                          );
                          setStateDialog(() => loadingDialog = false);
                          if (!context.mounted) return;
                          if (result["success"]) {
                            Navigator.pop(context);
                            await _loadUser();
                            setState(() => _editingEmail = false);
                            _showMessage("Correo actualizado", ok: true);
                          } else {
                            _showMessage(result["error"]);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loadingDialog
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updatePhone() async {
    String phone = _phoneController.text.trim();
    if (!_isValidColombianPhone(phone)) {
      _showMessage("Número inválido. Celular: 10 dígitos comenzando en 3.");
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
    if (!_isPasswordStrong(_newPasswordController.text)) {
      _showMessage(
        "La contraseña debe tener mínimo 8 caracteres, una mayúscula y un número.",
      );
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

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final nombre = user!['nombre'] ?? '';
    final email = user!['email'] ?? '';
    final fotoPerfil = user!['fotoPerfil'];

    return Scaffold(
      body: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // AppBar manual
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Editar perfil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
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
                      child:
                          fotoPerfil != null && fotoPerfil.toString().isNotEmpty
                          ? Image.network(
                              fotoPerfil,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatarPlaceholder(),
                            )
                          : _avatarPlaceholder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (nombre.isNotEmpty)
                    Text(
                      nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                  const SizedBox(height: 4),

                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seccion('Información personal'),
                  const SizedBox(height: 12),

                  _editableField(
                    label: "Nombre",
                    controller: _nameController,
                    isEditing: _editingName,
                    onEditToggle: () =>
                        setState(() => _editingName = !_editingName),
                    onSave: _updateName,
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 12),

                  _editableField(
                    label: "Correo",
                    controller: _emailController,
                    isEditing: _editingEmail,
                    onEditToggle: () =>
                        setState(() => _editingEmail = !_editingEmail),
                    onSave: _updateEmail,
                    type: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 12),

                  _editableField(
                    label: "Teléfono",
                    controller: _phoneController,
                    isEditing: _editingPhone,
                    onEditToggle: () =>
                        setState(() => _editingPhone = !_editingPhone),
                    onSave: _updatePhone,
                    type: TextInputType.phone,
                    prefixWidget: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
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

                  const SizedBox(height: 24),
                  _seccion('Seguridad'),
                  const SizedBox(height: 12),

                  // Contraseña
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.lightOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.primaryOrange,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Cambiar contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: _editingPassword
                              ? Colors.grey.shade100
                              : AppTheme.lightOrange,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _editingPassword
                                ? Colors.grey.shade300
                                : const Color(0x4DE8760A),
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => setState(
                            () => _editingPassword = !_editingPassword,
                          ),
                          icon: Icon(
                            _editingPassword ? Icons.close : Icons.edit,
                            color: _editingPassword
                                ? Colors.grey.shade600
                                : AppTheme.primaryOrange,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_editingPassword) ...[
                    const SizedBox(height: 12),
                    _passwordField(
                      "Contraseña actual",
                      _currentPasswordController,
                    ),
                    const SizedBox(height: 10),
                    _passwordField("Nueva contraseña", _newPasswordController),
                    const SizedBox(height: 4),
                    const Text(
                      'Mínimo 8 caracteres, una mayúscula y un número.',
                      style: TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                    const SizedBox(height: 10),
                    _passwordField(
                      "Confirmar contraseña",
                      _confirmPasswordController,
                    ),
                    const SizedBox(height: 14),
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
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.3),
      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _seccion(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 30, height: 2, color: AppTheme.primaryOrange),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    bool enabled = true,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: enabled ? Colors.black54 : Colors.grey.shade400,
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: enabled ? AppTheme.primaryOrange : Colors.grey.shade400,
      ),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade50,
      prefixIcon:
          prefixWidget ??
          (icon != null
              ? Icon(icon, color: Colors.grey.shade500, size: 20)
              : null),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
                  fontSize: 14,
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
                color: isEditing ? Colors.grey.shade100 : AppTheme.lightOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEditing
                      ? Colors.grey.shade300
                      : const Color(0x4DE8760A),
                ),
              ),
              child: IconButton(
                onPressed: onEditToggle,
                icon: Icon(
                  isEditing ? Icons.close : Icons.edit,
                  color: isEditing
                      ? Colors.grey.shade600
                      : AppTheme.primaryOrange,
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
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    bool _obscure = true;

    return StatefulBuilder(
      builder: (context, setState) => TextField(
        controller: controller,
        obscureText: _obscure,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryOrange,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.grey.shade500,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade500,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryOrange,
              width: 1.8,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 14,
          ),
        ),
      ),
    );
  }
}
