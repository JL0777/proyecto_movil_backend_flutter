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

  bool _loading = false;
  bool _cambiarPassword = false;
  bool _verPassword = false;
  bool _verConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.usuario['nombre'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.usuario['email'] ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.usuario['telefono'] ?? '',
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (_nombreController.text.trim().isEmpty) {
      _mostrarMensaje("El nombre no puede estar vacío");
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _mostrarMensaje("Correo inválido");
      return;
    }

    setState(() => _loading = true);

    final result = await _service.updateUser(widget.usuario['id'], {
      "nombre": _nombreController.text.trim(),
      "email": _emailController.text.trim(),
      "telefono": _telefonoController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      _mostrarMensaje("Usuario actualizado correctamente", ok: true);
    } else {
      _mostrarMensaje(result['error']);
    }
  }

  Future<void> _cambiarContrasena() async {
    if (_passwordController.text.length < 6) {
      _mostrarMensaje("La contraseña debe tener mínimo 6 caracteres");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarMensaje("Las contraseñas no coinciden");
      return;
    }

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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8651A), width: 1.8),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar usuario"),
        backgroundColor: const Color(0xFFE8651A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar e info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFE8651A),
                    child: Text(
                      (widget.usuario['nombre'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cliente desde ${widget.usuario['createdAt']?.toString().substring(0, 10) ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Información personal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _nombreController,
              decoration: _inputDecoration(
                "Nombre",
                icon: Icons.person_outline,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                "Correo",
                icon: Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                "Teléfono",
                icon: Icons.phone_outlined,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8651A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Cambiar contraseña
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _cambiarPassword = !_cambiarPassword),
                  icon: Icon(
                    _cambiarPassword ? Icons.close : Icons.edit,
                    color: _cambiarPassword
                        ? Colors.grey
                        : const Color(0xFFE8651A),
                  ),
                ),
              ],
            ),

            if (_cambiarPassword) ...[
              const SizedBox(height: 12),

              // Nueva contraseña
              TextField(
                controller: _passwordController,
                obscureText: !_verPassword,
                decoration: InputDecoration(
                  labelText: "Nueva contraseña",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _verPassword = !_verPassword),
                    icon: Icon(
                      _verPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE8651A),
                      width: 1.8,
                    ),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 12),

              // Confirmar contraseña
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_verConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _verConfirmPassword = !_verConfirmPassword,
                    ),
                    icon: Icon(
                      _verConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE8651A),
                      width: 1.8,
                    ),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _cambiarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8651A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Actualizar contraseña',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
