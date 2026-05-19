import 'package:flutter/material.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/gamificacion_service.dart';

class NotificacionesRachaScreen extends StatefulWidget {
  const NotificacionesRachaScreen({super.key});

  @override
  State<NotificacionesRachaScreen> createState() =>
      _NotificacionesRachaScreenState();
}

class _NotificacionesRachaScreenState extends State<NotificacionesRachaScreen> {
  final NotificationService _notifService = NotificationService();
  bool _activada = false;
  TimeOfDay _hora = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = true;
  bool _guardando = false;

  static const Color _naranja = Color(0xFFE8651A);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final activada = await _notifService.rachaEstaActivada();
    final hora = await _notifService.rachaHoraGuardada();
    if (!mounted) return;
    setState(() {
      _activada = activada;
      _hora = hora;
      _loading = false;
    });
  }

  Future<void> _toggleActivar(bool valor) async {
    if (valor) {
      // Pedir permisos primero
      final permitido = await _notifService.pedirPermisos();
      if (!permitido) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Necesitas permitir las notificaciones en ajustes',
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
      await _guardar();
    } else {
      await _notifService.desactivarRacha();
      setState(() => _activada = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notificaciones de racha desactivadas'),
          backgroundColor: Colors.grey.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _seleccionarHora() async {
    final nueva = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: _naranja)),
          child: child!,
        );
      },
    );
    if (nueva != null) {
      setState(() => _hora = nueva);
      if (_activada) await _guardar();
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final estado = await GamificacionService.obtenerEstado();
    final racha = estado['racha'] as int;
    await _notifService.activarRacha(_hora.hour, _hora.minute, racha);
    if (!mounted) return;
    setState(() {
      _activada = true;
      _guardando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notificación programada a las ${_horaTexto(_hora)} cada día',
        ),
        backgroundColor: _naranja,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _horaTexto(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F1EF),
      body: Column(
        children: [
          _buildHeader(context),
          _buildBreadcrumb(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
                  )
                : _buildContenido(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x77000000), BlendMode.darken),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        22,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Recordatorio de racha',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Text(
                'Inicio',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.grey.shade300,
            ),
            GestureDetector(
              onTap: () => Navigator.popUntil(
                context,
                (r) => r.settings.name == '/plan-comidas' || r.isFirst,
              ),
              child: Text(
                'Plan de comidas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.grey.shade300,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Logros',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.grey.shade300,
            ),
            const Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFE8651A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      children: [
        // ── Ilustración ──
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _naranja.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 44)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Recordatorio de racha',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Recibe una notificación diaria para\nno olvidar completar tu plan y mantener tu racha',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ── Card toggle ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _naranja.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: _naranja,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activar recordatorio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Notificación diaria de racha',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _activada,
                onChanged: _guardando ? null : _toggleActivar,
                activeThumbColor: _naranja,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Card hora ──
        GestureDetector(
          onTap: _seleccionarHora,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: _activada
                    ? _naranja.withValues(alpha: 0.3)
                    : Colors.grey.shade100,
                width: _activada ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF6366F1),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hora del recordatorio',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Toca para cambiar la hora',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _horaTexto(_hora),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _activada ? _naranja : Colors.grey.shade400,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Info ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3ED),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _naranja.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: _naranja, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La notificación se actualiza automáticamente con tu racha actual cada vez que completas un día.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _naranja.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
