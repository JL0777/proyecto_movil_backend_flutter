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

  final _formKeyInfo = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();

  bool _loading = false;
  bool _cambiarPassword = false;
  bool _verCurrentPassword = false;
  bool _verNewPassword = false;
  bool _verConfirmPassword = false;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final u = await SessionManager.getUser();
    if (!mounted) return;
    if (u != null) {
      setState(() {
        user = u;
        _nameController.text = u['nombre'] ?? '';
        _emailController.text = u['email'] ?? '';
        _phoneController.text = u['telefono'] ?? '';
      });
    }
  }

  void _showMessage(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _isValidColombianPhone(String number) {
    if (!RegExp(r'^\d+$').hasMatch(number)) return false;
    if (number.startsWith('3') && number.length == 10) return true;
    if (number.length == 7 && RegExp(r'^[1245678]').hasMatch(number)) {
      return true;
    }
    return false;
  }

  bool _isPasswordStrong(String password) {
    return password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.length >= 8;
  }

  // ── Guardar información personal ─────────────────────────────────────────

  Future<void> _guardarInfo() async {
    if (!_formKeyInfo.currentState!.validate()) return;
    setState(() => _loading = true);

    // Nombre
    final resultNombre =
        await _userService.updateName(_nameController.text.trim());
    if (!mounted) return;

    if (!resultNombre['success']) {
      setState(() => _loading = false);
      _showMessage(resultNombre['error']);
      return;
    }

    // Email (solo si cambió)
    if (_emailController.text.trim() != user!['email']) {
      final resultEmail =
          await _userService.solicitarCodigoEmail(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _loading = false);
      if (resultEmail['success']) {
        _mostrarDialogCodigoEmail(_emailController.text.trim());
      } else {
        _showMessage(resultEmail['error']);
      }
      return;
    }

    // Teléfono (solo si cambió)
    if (_phoneController.text.trim() != (user!['telefono'] ?? '')) {
      if (!_isValidColombianPhone(_phoneController.text.trim())) {
        setState(() => _loading = false);
        _showMessage('Número inválido. Celular: 10 dígitos comenzando en 3.');
        return;
      }
      final resultPhone = await _userService.updatePhone(
        user!['telefono'],
        _phoneController.text.trim(),
      );
      if (!mounted) return;
      if (!resultPhone['success']) {
        setState(() => _loading = false);
        _showMessage(resultPhone['error']);
        return;
      }
    }

    await _loadUser();
    if (!mounted) return;
    setState(() => _loading = false);
    _showMessage('Información actualizada correctamente', ok: true);
  }

  // ── Cambiar contraseña ────────────────────────────────────────────────────

  Future<void> _actualizarContrasena() async {
    if (!_formKeyPass.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await _userService.updatePassword(
      _currentPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _cambiarPassword = false);
      _showMessage('Contraseña actualizada correctamente', ok: true);
    } else {
      _showMessage(result['error']);
    }
  }

  // ── Diálogo verificación email ────────────────────────────────────────────

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
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Verifica tu nuevo correo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enviamos un código de 6 dígitos a $newEmail.',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54),
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
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryOrange, width: 1.8),
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
                                color: AppTheme.primaryOrange, strokeWidth: 2),
                          )
                        : segundosRestantes > 0
                            ? Text(
                                'Reenviar en $segundosRestantes s',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black45),
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
                                          const Duration(seconds: 1));
                                      if (!context.mounted) return false;
                                      setStateDialog(() {
                                        if (segundosRestantes > 0) {
                                          segundosRestantes--;
                                        }
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
                  child: Text('Cancelar',
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: loadingDialog
                      ? null
                      : () async {
                          if (codigoController.text.trim().isEmpty) return;
                          setStateDialog(() => loadingDialog = true);
                          final result = await _userService.updateEmail(
                            user!['email'],
                            newEmail,
                            codigoController.text.trim(),
                          );
                          setStateDialog(() => loadingDialog = false);
                          if (!context.mounted) return;
                          if (result['success']) {
                            Navigator.pop(context);
                            await _loadUser();
                            _showMessage('Correo actualizado', ok: true);
                          } else {
                            _showMessage(result['error']);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: loadingDialog
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Validadores ───────────────────────────────────────────────────────────

  String? _validarNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (v.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }

  String? _validarEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Correo inválido';
    return null;
  }

  String? _validarPasswordActual(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  String? _validarPasswordNueva(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (!_isPasswordStrong(v)) {
      return 'Mínimo 8 caracteres, una mayúscula y un número';
    }
    return null;
  }

  String? _validarConfirm(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (v != _newPasswordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final nombre = user!['nombre'] ?? '';
    final email = user!['email'] ?? '';
    final fotoPerfil = user!['fotoPerfil'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header original ────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: SafeArea(
                child: Column(
                  children: [
                    // AppBar manual
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
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
                        child: fotoPerfil != null &&
                                fotoPerfil.toString().isNotEmpty
                            ? Image.network(
                                fotoPerfil,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, _) =>
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
          ),

          // ── Contenido scrollable ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  // ── Tarjeta: Información personal ──
                  _buildTarjeta(
                    icono: Icons.person_outline,
                    color: const Color(0xFFE8651A),
                    titulo: 'Información personal',
                    child: Form(
                      key: _formKeyInfo,
                      child: Column(
                        children: [
                          _campo(
                            controller: _nameController,
                            label: 'Nombre completo',
                            icono: Icons.badge_outlined,
                            validator: _validarNombre,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            icono: Icons.email_outlined,
                            tipo: TextInputType.emailAddress,
                            validator: _validarEmail,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _phoneController,
                            label: 'Teléfono',
                            icono: Icons.phone_outlined,
                            tipo: TextInputType.phone,
                            prefijo: '+57',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _guardarInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8651A),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFFE8651A)
                                        .withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Guardar cambios',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Tarjeta: Seguridad ──
                  _buildTarjeta(
                    icono: Icons.lock_outline,
                    color: Colors.indigo,
                    titulo: 'Seguridad',
                    trailing: GestureDetector(
                      onTap: _loading
                          ? null
                          : () => setState(
                              () => _cambiarPassword = !_cambiarPassword),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _cambiarPassword
                              ? Colors.grey.shade100
                              : const Color(0xFFE8651A)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _cambiarPassword
                                  ? Icons.close
                                  : Icons.edit_outlined,
                              size: 13,
                              color: _cambiarPassword
                                  ? Colors.grey
                                  : const Color(0xFFE8651A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _cambiarPassword ? 'Cancelar' : 'Cambiar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _cambiarPassword
                                    ? Colors.grey
                                    : const Color(0xFFE8651A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: _cambiarPassword
                        ? Form(
                            key: _formKeyPass,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _campoPassword(
                                  controller: _currentPasswordController,
                                  label: 'Contraseña actual',
                                  ver: _verCurrentPassword,
                                  onToggle: () => setState(() =>
                                      _verCurrentPassword =
                                          !_verCurrentPassword),
                                  validator: _validarPasswordActual,
                                ),
                                const SizedBox(height: 12),
                                _campoPassword(
                                  controller: _newPasswordController,
                                  label: 'Nueva contraseña',
                                  ver: _verNewPassword,
                                  onToggle: () => setState(
                                      () => _verNewPassword = !_verNewPassword),
                                  validator: _validarPasswordNueva,
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    'Mínimo 8 caracteres, una mayúscula y un número.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _campoPassword(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar contraseña',
                                  ver: _verConfirmPassword,
                                  onToggle: () => setState(() =>
                                      _verConfirmPassword =
                                          !_verConfirmPassword),
                                  validator: _validarConfirm,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading
                                        ? null
                                        : _actualizarContrasena,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.indigo.withValues(alpha: 0.6),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  Icons.lock_reset_outlined,
                                                  size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                'Actualizar contraseña',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(Icons.shield_outlined,
                                    size: 16, color: Colors.grey.shade400),
                                const SizedBox(width: 8),
                                Text(
                                  'Toca "Cambiar" para modificar',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _avatarPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.3),
      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _buildTarjeta({
    required IconData icono,
    required Color color,
    required String titulo,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? Function(String?)? validator,
    TextInputType tipo = TextInputType.text,
    String? prefijo,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      keyboardType: tipo,
      validator: validator,
      style: const TextStyle(
          fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFFE8651A),
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: _loading ? Colors.grey.shade100 : Colors.grey.shade50,
        prefixIcon: prefijo != null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                child: Text(
                  prefijo,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE8651A)),
                ),
              )
            : Icon(icono, color: Colors.grey.shade400, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE8651A), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  Widget _campoPassword({
    required TextEditingController controller,
    required String label,
    required bool ver,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      obscureText: !ver,
      validator: validator,
      style: const TextStyle(
          fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
            fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: _loading ? Colors.grey.shade100 : Colors.grey.shade50,
        prefixIcon:
            Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 18),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            ver
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade400,
            size: 18,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}