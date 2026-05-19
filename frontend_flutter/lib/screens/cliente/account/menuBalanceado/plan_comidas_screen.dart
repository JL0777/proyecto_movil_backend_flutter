import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/ia_service.dart';
import 'food_scan_screen.dart';
import '../../../../services/gamificacion_service.dart';
import 'logros_screen.dart';
import '../../../../services/notification_service.dart';

class PlanComidasScreen extends StatefulWidget {
  final Map<String, dynamic> perfil;

  const PlanComidasScreen({super.key, required this.perfil});

  @override
  State<PlanComidasScreen> createState() => _PlanComidasScreenState();
}

class _PlanComidasScreenState extends State<PlanComidasScreen>
    with SingleTickerProviderStateMixin {
  final IaService _iaService = IaService();

  String? _plan;
  bool _loading = false;
  String? _error;
  bool _mostrandoLogro = false;

  // Progreso del día: claves son los títulos de sección
  Map<String, bool> _completados = {};
  int _caloriasEscaneadas = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  static const String _prefKeyPlan = 'plan_comidas_hoy';
  static const String _prefKeyFecha = 'plan_comidas_fecha';
  static const String _prefKeyCompletados = 'plan_comidas_completados';
  static const String _prefKeyCalScan = 'plan_calorias_scan';

  static const Color _naranja = Color(0xFFE8651A);
  static const Color _verde = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _cargarOGenerarPlan();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // ── Persistencia ──────────────────────────────────────────

  Future<void> _cargarOGenerarPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final fechaGuardada = prefs.getString(_prefKeyFecha) ?? '';
    final hoy = _fechaHoy();
    final planGuardado = prefs.getString(_prefKeyPlan);

    // Cargar completados del día
    final completadosJson = prefs.getString(_prefKeyCompletados) ?? '{}';
    Map<String, bool> completados = {};
    try {
      final decoded = jsonDecode(completadosJson) as Map<String, dynamic>;
      completados = decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {}

    // Si el plan es de hoy, cargarlo directamente
    if (fechaGuardada == hoy &&
        planGuardado != null &&
        planGuardado.isNotEmpty) {
      final calScan = prefs.getInt(_prefKeyCalScan) ?? 0;
      setState(() {
        _plan = planGuardado;
        _completados = completados;
        _caloriasEscaneadas = calScan;
        _loading = false;
      });
      _animarProgreso();
      return;
    }

    // Si es un día nuevo, resetear completados y generar nuevo plan
    await _generarPlan(resetearCompletados: true);
  }

  Future<void> _generarPlan({bool resetearCompletados = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _iaService.generarPlanComidas();

    if (!mounted) return;

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyPlan, result['plan']);
      await prefs.setString(_prefKeyFecha, _fechaHoy());

      if (resetearCompletados) {
        await prefs.setString(_prefKeyCompletados, '{}');
        await prefs.setInt(_prefKeyCalScan, 0);
      }

      final completadosJson = prefs.getString(_prefKeyCompletados) ?? '{}';
      Map<String, bool> completados = {};
      try {
        final decoded = jsonDecode(completadosJson) as Map<String, dynamic>;
        completados = decoded.map((k, v) => MapEntry(k, v as bool));
      } catch (_) {}

      setState(() {
        _plan = result['plan'];
        _completados = resetearCompletados ? {} : completados;
        _caloriasEscaneadas = resetearCompletados ? 0 : _caloriasEscaneadas;
        _loading = false;
      });
      _animarProgreso();
    } else {
      setState(() {
        _error = result['error'];
        _loading = false;
      });
    }
  }

  Future<void> _abrirScan() async {
    final tdee = (widget.perfil['tdee'] as num?)?.toInt() ?? 2000;
    final caloriasAgregadas = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => FoodScanScreen(tdee: tdee)),
    );

    if (caloriasAgregadas != null && caloriasAgregadas > 0) {
      final nuevasCal = _caloriasEscaneadas + caloriasAgregadas;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyCalScan, nuevasCal);
      setState(() => _caloriasEscaneadas = nuevasCal);
      _animarProgreso();

      // Registrar scan para logros
      final nuevosLogros = await GamificacionService.registrarScan();
      if (nuevosLogros.isNotEmpty && mounted) {
        _mostrarPopupLogro(nuevosLogros.first);
      }
    }
  }

  void _mostrarPopupLogro(Logro logro) {
    if (_mostrandoLogro) return;
    _mostrandoLogro = true;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    logro.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Logro desbloqueado!',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                logro.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                logro.descripcion,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrandoLogro = false;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    '¡Genial!',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _mostrandoLogro = false);
  }

  void _abrirLogros() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LogrosScreen()),
    );
  }

  Future<void> _toggleCompletado(String titulo, bool valor) async {
    setState(() => _completados[titulo] = valor);
    _animarProgreso();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyCompletados, jsonEncode(_completados));

    // Verificar si se alcanzó la meta calórica
    if (valor && _plan != null) {
      final tdee = (widget.perfil['tdee'] as num?)?.toInt() ?? 2000;
      final secciones = _parsearPlan(_plan!);
      final progreso = _calcularProgreso(secciones, tdee);
      if (progreso >= 0.85) {
        final nuevosLogros = await GamificacionService.registrarDiaEnMeta();
        if (nuevosLogros.isNotEmpty && mounted) {
          _mostrarPopupLogro(nuevosLogros.first);
          await NotificationService().actualizarRacha(
            (await GamificacionService.obtenerEstado())['racha'] as int,
          );
        }
      }
    }
  }

  void _animarProgreso() {
    _progressController.reset();
    _progressController.forward();
  }

  String _fechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ── Parser de secciones ───────────────────────────────────

  List<_Seccion> _parsearPlan(String plan) {
    final secciones = <_Seccion>[];
    final bloques = [
      _BloqueDef(
        '🍳',
        'DESAYUNO',
        const Color(0xFFFF8C42),
        Icons.wb_sunny_outlined,
      ),
      _BloqueDef(
        '🥗',
        'ALMUERZO',
        const Color(0xFF10B981),
        Icons.lunch_dining_outlined,
      ),
      _BloqueDef(
        '🍎',
        'MERIENDA',
        const Color(0xFFF59E0B),
        Icons.apple_outlined,
      ),
      _BloqueDef(
        '🍽️',
        'CENA',
        const Color(0xFF6366F1),
        Icons.dinner_dining_outlined,
      ),
      _BloqueDef(
        '💧',
        'HIDRATACIÓN',
        const Color(0xFF3B82F6),
        Icons.water_drop_outlined,
      ),
      _BloqueDef(
        '✅',
        'RESUMEN',
        const Color(0xFF14B8A6),
        Icons.summarize_outlined,
      ),
    ];

    for (int i = 0; i < bloques.length; i++) {
      final bloque = bloques[i];
      final inicio = plan.indexOf(bloque.emoji);
      if (inicio == -1) continue;

      int fin = plan.length;
      for (int j = i + 1; j < bloques.length; j++) {
        final idx = plan.indexOf(bloques[j].emoji, inicio + 1);
        if (idx != -1 && idx < fin) fin = idx;
      }

      final contenido = plan.substring(inicio, fin).trim();
      secciones.add(
        _Seccion(
          titulo: bloque.titulo,
          contenido: contenido,
          color: bloque.color,
          icono: bloque.icono,
        ),
      );
    }
    return secciones;
  }

  // ── Progreso ──────────────────────────────────────────────

  int _caloriasDelPlan(List<_Seccion> secciones) {
    int total = 0;
    final regex = RegExp(r'~(\d+)\s*kcal', caseSensitive: false);
    for (final s in secciones) {
      if (s.titulo == 'RESUMEN' || s.titulo == 'HIDRATACIÓN') continue;
      if (_completados[s.titulo] == true) {
        final match = regex.firstMatch(s.contenido);
        if (match != null) {
          total += int.tryParse(match.group(1) ?? '0') ?? 0;
        }
      }
    }
    return total;
  }

  double _calcularProgreso(List<_Seccion> secciones, int tdee) {
    final calPlan = _caloriasDelPlan(secciones);
    final calTotal = calPlan + _caloriasEscaneadas;
    if (tdee <= 0) return 0;
    return (calTotal / tdee).clamp(0.0, 1.0);
  }

  // ════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final tdee = widget.perfil['tdee'] ?? 0;
    final objetivo = widget.perfil['objetivoRecomendado'] ?? '';
    final imc = widget.perfil['imc'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F1EF),
      body: Column(
        children: [
          _buildHeader(tdee, imc, objetivo),
          _buildBreadcrumb(),
          Expanded(
            child: _loading
                ? _buildLoading()
                : _error != null
                ? _buildError()
                : _buildPlan(),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(dynamic tdee, dynamic imc, String objetivo) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fila 1: back + título + refresh ──
          Row(
            children: [
              _headerBtn(Icons.arrow_back, () => Navigator.pop(context)),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Qué como hoy?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Plan personalizado con IA',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _headerBtn(
                Icons.refresh_rounded,
                _loading ? null : () => _generarPlan(resetearCompletados: true),
                tooltip: 'Nuevo plan',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Fila 2: botones de acción ──
          Row(
            children: [
              _headerBtn(
                Icons.camera_alt_rounded,
                _abrirScan,
                tooltip: 'Escanear',
              ),
              const SizedBox(width: 6),
              _headerBtn(
                Icons.emoji_events_rounded,
                _abrirLogros,
                tooltip: 'Logros',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Fila 3: chips de info ──
          Row(
            children: [
              _chip(
                '${(tdee as num).toStringAsFixed(0)} kcal',
                Icons.local_fire_department_outlined,
              ),
              const SizedBox(width: 6),
              _chip(
                'IMC ${(imc as num).toStringAsFixed(1)}',
                Icons.monitor_weight_outlined,
              ),
              const SizedBox(width: 6),
              _chip(_labelObjetivo(objetivo), Icons.flag_outlined),
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
            onTap: () => Navigator.pop(context),
            child: Text(
              'Perfil Nutricional',
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
          Text(
            'Plan de comidas',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFE8651A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback? onTap, {String? tooltip}) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _chip(String texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: Colors.white, size: 11),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _naranja.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: _naranja.withValues(alpha: 0.18),
                width: 2,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(color: _naranja, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Creando tu plan del día...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La IA analiza tu perfil y objetivos',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 36,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo generar el plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generarPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _naranja,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Intentar de nuevo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Plan principal ────────────────────────────────────────

  Widget _buildPlan() {
    if (_plan == null) return const SizedBox();

    final tdee = (widget.perfil['tdee'] as num?)?.toInt() ?? 2000;
    final secciones = _parsearPlan(_plan!);
    final progreso = _calcularProgreso(secciones, tdee);
    final calPlan = _caloriasDelPlan(secciones);
    final calTotal = calPlan + _caloriasEscaneadas;

    return RefreshIndicator(
      onRefresh: () => _generarPlan(resetearCompletados: true),
      color: _naranja,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Barra de progreso del día ──
          _barraProgreso(progreso, calTotal, tdee),
          const SizedBox(height: 16),

          // ── Banner IA ──
          _bannerIA(),
          const SizedBox(height: 14),

          // ── Secciones ──
          if (secciones.isEmpty)
            _cardTextoPlano(_plan!)
          else
            ...secciones.map((s) => _cardSeccion(s)),

          // ── Botón Escanear comida ──
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _abrirScan,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Escanear lo que voy a comer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  // ── Barra de progreso ────────────────────────────────────

  Widget _barraProgreso(double progreso, int calConsumidas, int tdee) {
    final caloriasMostradas = calConsumidas;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _progresColor(progreso).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  progreso >= 1.0
                      ? Icons.celebration_rounded
                      : Icons.local_fire_department_outlined,
                  color: _progresColor(progreso),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progreso >= 1.0 ? '¡Meta alcanzada!' : 'Calorías del día',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Meta diaria: $tdee kcal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, _) {
                  final display = (caloriasMostradas * _progressAnim.value)
                      .round();
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$display',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _progresColor(progreso),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: ' kcal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (_, _) => LinearProgressIndicator(
                value: progreso * _progressAnim.value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation(_progresColor(progreso)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_caloriasEscaneadas > 0)
            Row(
              children: [
                _desglose(
                  'Del plan',
                  _caloriasDelPlan(_parsearPlan(_plan!)),
                  const Color(0xFF6366F1),
                ),
                const SizedBox(width: 12),
                _desglose('Escaneado', _caloriasEscaneadas, _naranja),
              ],
            ),
        ],
      ),
    );
  }

  Widget _desglose(String label, int kcal, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: $kcal kcal',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _progresColor(double p) {
    if (p == 0) return Colors.grey.shade400;
    if (p < 0.5) return _naranja;
    if (p < 1.0) return const Color(0xFFF59E0B);
    return _verde;
  }

  // ── Banner IA ─────────────────────────────────────────────

  Widget _bannerIA() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _naranja.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: _naranja, size: 15),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Marca cada comida al completarla. Toca 🔄 en la esquina para generar un plan nuevo.',
              style: TextStyle(fontSize: 11, color: _naranja, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card de sección ───────────────────────────────────────

  Widget _cardSeccion(_Seccion seccion) {
    final esResumen = seccion.titulo == 'RESUMEN';
    final completado = _completados[seccion.titulo] == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: completado
            ? seccion.color.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completado
              ? seccion.color.withValues(alpha: 0.35)
              : Colors.grey.shade100,
          width: completado ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: completado
                ? seccion.color.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: completado ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: completado
                  ? seccion.color.withValues(alpha: 0.08)
                  : seccion.color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: completado
                        ? seccion.color.withValues(alpha: 0.15)
                        : seccion.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    completado && !esResumen
                        ? Icons.check_circle_rounded
                        : seccion.icono,
                    color: seccion.color,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seccion.titulo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: seccion.color,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (completado && !esResumen)
                        Text(
                          '¡Completado!',
                          style: TextStyle(
                            fontSize: 10,
                            color: seccion.color.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Toggle de completado (excepto en Resumen)
                if (!esResumen)
                  GestureDetector(
                    onTap: () => _toggleCompletado(seccion.titulo, !completado),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 44,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: completado
                            ? seccion.color
                            : Colors.grey.shade200,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        alignment: completado
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: completado
                              ? Icon(
                                  Icons.check,
                                  color: seccion.color,
                                  size: 12,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Contenido (con opacidad reducida si está completado)
          AnimatedOpacity(
            opacity: completado && !esResumen ? 0.55 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _renderContenido(seccion.contenido, seccion.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderContenido(String contenido, Color color) {
    final lineas = contenido
        .split('\n')
        .skip(1)
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lineas.map((linea) {
        if (linea.trim().startsWith('•')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    linea.replaceFirst('•', '').trim(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (linea.trim().startsWith('Por qué:')) {
          return Container(
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: color, size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    linea.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (linea.trim().startsWith('Total') ||
            linea.trim().startsWith('Consejo')) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Text(
              linea.trim(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.4,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              linea.trim(),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _cardTextoPlano(String texto) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  String _labelObjetivo(String objetivo) {
    const map = {
      'bajar_peso': 'Bajar peso',
      'subir_musculo': 'Ganar músculo',
      'mantenimiento': 'Mantenimiento',
      'energia': 'Energía',
      'digestivo': 'Digestivo',
    };
    return map[objetivo] ?? objetivo;
  }
}

// ── Modelos internos ──────────────────────────────────────────────────────────

class _Seccion {
  final String titulo;
  final String contenido;
  final Color color;
  final IconData icono;

  _Seccion({
    required this.titulo,
    required this.contenido,
    required this.color,
    required this.icono,
  });
}

class _BloqueDef {
  final String emoji;
  final String titulo;
  final Color color;
  final IconData icono;

  _BloqueDef(this.emoji, this.titulo, this.color, this.icono);
}
