import 'package:flutter/material.dart';
import '../../../../services/ia_service.dart';

class PlanComidasScreen extends StatefulWidget {
  final Map<String, dynamic> perfil;

  const PlanComidasScreen({super.key, required this.perfil});

  @override
  State<PlanComidasScreen> createState() => _PlanComidasScreenState();
}

class _PlanComidasScreenState extends State<PlanComidasScreen> {
  final IaService _iaService = IaService();

  String? _plan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generarPlan();
  }

  Future<void> _generarPlan() async {
    setState(() {
      _loading = true;
      _error = null;
      _plan = null;
    });

    final result = await _iaService.generarPlanComidas();

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _plan = result['plan'];
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error'];
        _loading = false;
      });
    }
  }

  List<_Seccion> _parsearPlan(String plan) {
    final secciones = <_Seccion>[];

    final bloques = [
      _BloqueDef('🍳', 'DESAYUNO', Colors.orange, Icons.wb_sunny_outlined),
      _BloqueDef('🥗', 'ALMUERZO', const Color(0xFFE8651A), Icons.lunch_dining_outlined),
      _BloqueDef('🍎', 'MERIENDA', Colors.green, Icons.apple_outlined),
      _BloqueDef('🍽️', 'CENA', Colors.indigo, Icons.dinner_dining_outlined),
      _BloqueDef('💧', 'HIDRATACIÓN', Colors.blue, Icons.water_drop_outlined),
      _BloqueDef('✅', 'RESUMEN', Colors.teal, Icons.summarize_outlined),
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
      secciones.add(_Seccion(
        titulo: bloque.titulo,
        contenido: contenido,
        color: bloque.color,
        icono: bloque.icono,
      ));
    }

    return secciones;
  }

  @override
  Widget build(BuildContext context) {
    final tdee = widget.perfil['tdee'] ?? 0;
    final objetivo = widget.perfil['objetivoRecomendado'] ?? '';
    final imc = widget.perfil['imc'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0x66000000),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Qué como hoy?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Plan generado por IA para ti',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _loading ? null : _generarPlan,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Chips de perfil
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _perfilChip(
                        '${tdee.toStringAsFixed(0)} kcal',
                        Icons.local_fire_department_outlined,
                      ),
                      const SizedBox(width: 8),
                      _perfilChip(
                        'IMC ${imc.toStringAsFixed(1)}',
                        Icons.monitor_weight_outlined,
                      ),
                      const SizedBox(width: 8),
                      _perfilChip(
                        _labelObjetivo(objetivo),
                        Icons.flag_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Contenido ──
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

  // ── Loading ────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8651A).withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE8651A).withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFFE8651A),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Generando tu plan personalizado...',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'La IA está analizando tu perfil\ny los ingredientes disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade500, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────

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
                    color: Colors.red.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(Icons.error_outline,
                  size: 36, color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo generar el plan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
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
                backgroundColor: const Color(0xFFE8651A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 13),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Intentar de nuevo',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Plan ───────────────────────────────────────────────────

  Widget _buildPlan() {
    if (_plan == null) return const SizedBox();

    final secciones = _parsearPlan(_plan!);

    return RefreshIndicator(
      onRefresh: _generarPlan,
      color: const Color(0xFFE8651A),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Banner info
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFE8651A).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: Color(0xFFE8651A), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plan generado con IA basado en tu perfil y los ingredientes disponibles. Toca 🔄 para generar uno nuevo.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE8651A),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          if (secciones.isEmpty)
            _cardTextoPlano(_plan!)
          else
            ...secciones.map((s) => _cardSeccion(s)),
        ],
      ),
    );
  }

  // ── Card de sección ────────────────────────────────────────

  Widget _cardSeccion(_Seccion seccion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
          // Header de la card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: seccion.color.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: seccion.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(seccion.icono,
                      color: seccion.color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  seccion.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: seccion.color,
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: _renderContenido(seccion.contenido, seccion.color),
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
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    linea.replaceFirst('•', '').trim(),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        } else if (linea.trim().startsWith('Por qué:')) {
          return Container(
            margin: const EdgeInsets.only(top: 4, bottom: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: color, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    linea.trim(),
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        height: 1.4,
                        fontStyle: FontStyle.italic),
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
                  height: 1.4),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              linea.trim(),
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87, height: 1.4),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _cardTextoPlano(String texto) {
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
      child: Text(
        texto,
        style: const TextStyle(
            fontSize: 13, color: Colors.black87, height: 1.6),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _perfilChip(String texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _labelObjetivo(String objetivo) {
    switch (objetivo) {
      case 'bajar_peso':
        return 'Bajar peso';
      case 'subir_musculo':
        return 'Subir músculo';
      case 'mantenimiento':
        return 'Mantenimiento';
      case 'energia':
        return 'Energía';
      case 'digestivo':
        return 'Digestivo';
      default:
        return objetivo;
    }
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