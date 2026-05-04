import 'package:flutter/material.dart';
import '../../../services/admin_user_service.dart';

class AdminEditUserScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const AdminEditUserScreen({super.key, required this.usuario});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  final AdminUserService _service = AdminUserService();

  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKeyInfo = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();

  bool _loading = false;
  bool _cambiarPassword = false;
  bool _verPassword = false;
  bool _verConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.usuario['nombre'] ?? '');
    _emailController =
        TextEditingController(text: widget.usuario['email'] ?? '');
    _telefonoController =
        TextEditingController(text: widget.usuario['telefono'] ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String msg, {bool ok = false}) {
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

  Future<void> _guardarCambios() async {
    if (!_formKeyInfo.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _service.updateUser(
      widget.usuario['id'],
      {
        "nombre": _nombreController.text.trim(),
        "email": _emailController.text.trim(),
        "telefono": _telefonoController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _mostrarMensaje("Usuario actualizado correctamente", ok: true);
    } else {
      _mostrarMensaje(result['error']);
    }
  }

  Future<void> _cambiarContrasena() async {
    if (!_formKeyPass.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _service.updatePassword(
      widget.usuario['id'],
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() => _cambiarPassword = false);
      _mostrarMensaje("Contraseña actualizada correctamente", ok: true);
    } else {
      _mostrarMensaje(result['error']);
    }
  }

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

  String? _validarPassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validarConfirm(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final inicialNombre =
        (widget.usuario['nombre'] ?? '?')[0].toUpperCase();
    final fechaRegistro =
        widget.usuario['createdAt']?.toString().substring(0, 10) ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header con gradiente ──────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8651A), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              24,
            ),
            child: Column(
              children: [
                // Botón atrás + título
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
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editar usuario',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Modifica la información del usuario',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar + nombre + fecha
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2),
                        ),
                        child: Center(
                          child: Text(
                            inicialNombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.usuario['nombre'] ?? 'Usuario',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cliente desde $fechaRegistro',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Contenido scrollable ──────────────────────────────────────
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
                            controller: _nombreController,
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
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icono: Icons.phone_outlined,
                            tipo: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _guardarCambios,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8651A),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFFE8651A)
                                        .withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
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
                                              fontWeight: FontWeight.w700),
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

                  // ── Tarjeta: Contraseña ──
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
                              : const Color(0xFFE8651A).withValues(alpha: 0.1),
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
                              children: [
                                _campoPassword(
                                  controller: _passwordController,
                                  label: 'Nueva contraseña',
                                  ver: _verPassword,
                                  onToggle: () => setState(
                                      () => _verPassword = !_verPassword),
                                  validator: _validarPassword,
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
                                    onPressed:
                                        _loading ? null : _cambiarContrasena,
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
                                              Icon(Icons.lock_reset_outlined,
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
                                  'Toca "Cambiar" para modificar la contraseña',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
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

  // ── Tarjeta de sección ──────────────────────────────────────────────────

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

  // ── Campo de texto estándar ─────────────────────────────────────────────

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? Function(String?)? validator,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      keyboardType: tipo,
      validator: validator,
      style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFFE8651A),
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: _loading ? Colors.grey.shade100 : Colors.grey.shade50,
        prefixIcon: Icon(icono, color: Colors.grey.shade400, size: 18),
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

  // ── Campo de contraseña ─────────────────────────────────────────────────

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
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: Colors.indigo,
            fontWeight: FontWeight.w600),
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