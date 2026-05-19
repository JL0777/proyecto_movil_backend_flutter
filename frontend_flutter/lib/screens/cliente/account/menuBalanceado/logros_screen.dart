import 'package:flutter/material.dart';
import '../../../../services/gamificacion_service.dart';
import 'notificaciones_racha_screen.dart';

class LogrosScreen extends StatefulWidget {
  const LogrosScreen({super.key});

  @override
  State<LogrosScreen> createState() => _LogrosScreenState();
}

class _LogrosScreenState extends State<LogrosScreen> {
  Map<String, dynamic>? _estado;
  bool _loading = true;

  static const Color _naranja = Color(0xFFE8651A);
  static const Color _verde = Color(0xFF10B981);
  static const Color _dorado = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final estado = await GamificacionService.obtenerEstado();
    if (!mounted) return;
    setState(() {
      _estado = estado;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F1EF),
      body: Column(
        children: [
          _buildHeader(context),
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
        // <-- agrega "child:" aquí
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis logros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Racha y progreso',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificacionesRachaScreen(),
              ),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    final racha = _estado!['racha'] as int;
    final totalDias = _estado!['totalDias'] as int;
    final totalScans = _estado!['totalScans'] as int;
    final logros = _estado!['logros'] as List<Logro>;
    final desbloqueados = logros.where((l) => l.desbloqueado).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // ── Card racha principal ──
        _cardRacha(racha),
        const SizedBox(height: 14),

        // ── Estadísticas ──
        _cardEstadisticas(totalDias, totalScans, desbloqueados, logros.length),
        const SizedBox(height: 20),

        // ── Logros desbloqueados ──
        if (desbloqueados > 0) ...[
          _tituloSeccion('🏅 Desbloqueados', '$desbloqueados logros'),
          const SizedBox(height: 10),
          ...logros
              .where((l) => l.desbloqueado)
              .map((l) => _cardLogro(l, desbloqueado: true)),
          const SizedBox(height: 16),
        ],

        // ── Logros bloqueados ──
        _tituloSeccion(
          '🔒 Por desbloquear',
          '${logros.length - desbloqueados} logros',
        ),
        const SizedBox(height: 10),
        ...logros
            .where((l) => !l.desbloqueado)
            .map((l) => _cardLogro(l, desbloqueado: false)),
      ],
    );
  }

  Widget _cardRacha(int racha) {
    final color = racha >= 7
        ? _verde
        : racha >= 3
        ? _dorado
        : _naranja;
    final mensaje = racha == 0
        ? 'Completa el plan de hoy para empezar tu racha'
        : racha == 1
        ? '¡Buen comienzo! Sigue mañana'
        : racha < 7
        ? '¡Vas muy bien! No pares ahora'
        : '¡Increíble racha! Eres imparable';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            '$racha',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
              letterSpacing: -2,
            ),
          ),
          Text(
            racha == 1 ? 'día en racha' : 'días en racha',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              mensaje,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Barra próximo hito
          if (racha < 30) ...[
            const SizedBox(height: 16),
            _barraProximoHito(racha),
          ],
        ],
      ),
    );
  }

  Widget _barraProximoHito(int racha) {
    final hitos = [3, 7, 14, 30];
    final proximoHito = hitos.firstWhere((h) => h > racha, orElse: () => 30);
    final hitoAnterior = hitos.lastWhere((h) => h <= racha, orElse: () => 0);
    final progreso = proximoHito > hitoAnterior
        ? (racha - hitoAnterior) / (proximoHito - hitoAnterior)
        : 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximo hito: $proximoHito días',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
            Text(
              '${proximoHito - racha} días restantes',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _cardEstadisticas(
    int totalDias,
    int totalScans,
    int desbloqueados,
    int totalLogros,
  ) {
    return Container(
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
          _statItem('$totalDias', 'Días en\nmeta', _verde),
          _divider(),
          _statItem('$totalScans', 'Alimentos\nescaneados', _naranja),
          _divider(),
          _statItem(
            '$desbloqueados/$totalLogros',
            'Logros\nobtenidos',
            _dorado,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String valor, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: Colors.grey.shade100);
  }

  Widget _tituloSeccion(String texto, String subtexto) {
    return Row(
      children: [
        Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          subtexto,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _cardLogro(Logro logro, {required bool desbloqueado}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: desbloqueado ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: desbloqueado
              ? _dorado.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: desbloqueado ? 1.5 : 1,
        ),
        boxShadow: desbloqueado
            ? [
                BoxShadow(
                  color: _dorado.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: desbloqueado
                  ? _dorado.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                desbloqueado ? logro.emoji : '🔒',
                style: TextStyle(fontSize: desbloqueado ? 24 : 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logro.titulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: desbloqueado ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  logro.descripcion,
                  style: TextStyle(
                    fontSize: 11,
                    color: desbloqueado
                        ? Colors.grey.shade500
                        : Colors.grey.shade300,
                  ),
                ),
                if (desbloqueado && logro.fechaDesbloqueo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Obtenido el ${_fechaLegible(logro.fechaDesbloqueo!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: _dorado,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (desbloqueado)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _dorado.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star_rounded, color: _dorado, size: 16),
            ),
        ],
      ),
    );
  }

  String _fechaLegible(String fecha) {
    final partes = fecha.split('-');
    if (partes.length < 3) return fecha;
    final meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    try {
      final mes = int.parse(partes[1]);
      return '${partes[2]} ${meses[mes]} ${partes[0]}';
    } catch (_) {
      return fecha;
    }
  }
}
