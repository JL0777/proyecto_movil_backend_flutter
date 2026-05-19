import 'package:flutter/material.dart';
import '../../../../services/user_service.dart';
import '../../../../services/notification_service.dart';
import 'menus_balanceados_screen.dart';
import 'plan_comidas_screen.dart';

class PerfilNutricionalScreen extends StatefulWidget {
  const PerfilNutricionalScreen({super.key});

  @override
  State<PerfilNutricionalScreen> createState() =>
      _PerfilNutricionalScreenState();
}

class _PerfilNutricionalScreenState extends State<PerfilNutricionalScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _edadController = TextEditingController();

  String? _sexo;
  String? _nivelActividad;
  bool _loading = true;
  bool _guardando = false;
  bool _editando = false;
  Map<String, dynamic>? _perfil;
  bool _tieneDatos = false;

  // ── Notificaciones de agua ──
  bool _notifActivadas = false;
  bool _togglingNotif = false;
  bool _mostrarHorario = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Paleta de colores ──
  static const Color _naranja = Color(0xFFE8651A);
  static const Color _naranjaClaro = Color(0xFFFFF0E8);
  static const Color _fondo = Color(0xFFF8F7F5);
  static const Color _azul = Color(0xFF3B82F6);

  final List<Map<String, dynamic>> _nivelesActividad = [
    {
      'valor': 'sedentario',
      'label': 'Sedentario',
      'descripcion': 'Poco o nada de ejercicio',
      'icono': Icons.weekend_outlined,
    },
    {
      'valor': 'ligero',
      'label': 'Ligero',
      'descripcion': 'Ejercicio 1–3 días/semana',
      'icono': Icons.directions_walk_outlined,
    },
    {
      'valor': 'moderado',
      'label': 'Moderado',
      'descripcion': 'Ejercicio 3–5 días/semana',
      'icono': Icons.directions_run_outlined,
    },
    {
      'valor': 'activo',
      'label': 'Activo',
      'descripcion': 'Ejercicio 6–7 días/semana',
      'icono': Icons.fitness_center_outlined,
    },
    {
      'valor': 'muy_activo',
      'label': 'Muy activo',
      'descripcion': 'Ejercicio intenso diario',
      'icono': Icons.bolt_outlined,
    },
  ];

  final Map<String, Map<String, dynamic>> _objetivos = {
    'bajar_peso': {
      'label': 'Bajar peso',
      'icono': Icons.trending_down_rounded,
      'color': _azul,
      'gradient': [_azul, Color(0xFF60A5FA)],
      'descripcion': 'Tu plan está enfocado en reducir grasa corporal',
    },
    'subir_musculo': {
      'label': 'Ganar músculo',
      'icono': Icons.fitness_center_rounded,
      'color': _naranja,
      'gradient': [_naranja, Color(0xFFF59E0B)],
      'descripcion': 'Tu plan está enfocado en ganar masa muscular',
    },
    'mantenimiento': {
      'label': 'Mantenimiento',
      'icono': Icons.balance_rounded,
      'color': Color(0xFF10B981),
      'gradient': [Color(0xFF10B981), Color(0xFF34D399)],
      'descripcion': 'Tu peso está en el rango ideal',
    },
    'energia': {
      'label': 'Más energía',
      'icono': Icons.bolt_rounded,
      'color': Color(0xFFF59E0B),
      'gradient': [Color(0xFFF59E0B), Color(0xFFFCD34D)],
      'descripcion': 'Tu plan está enfocado en mejorar tu energía',
    },
    'digestivo': {
      'label': 'Salud digestiva',
      'icono': Icons.spa_rounded,
      'color': Color(0xFF14B8A6),
      'gradient': [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
      'descripcion': 'Tu plan está enfocado en mejorar tu digestión',
    },
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _cargar();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  double _calcularAgua() {
    if (_perfil == null) return 2.0;
    final peso = double.tryParse('${_perfil!['peso']}') ?? 0;
    double base = peso * 35;
    switch (_perfil!['nivelActividad']) {
      case 'ligero':
        base += 300;
        break;
      case 'moderado':
        base += 500;
        break;
      case 'activo':
        base += 700;
        break;
      case 'muy_activo':
        base += 1000;
        break;
    }
    return double.parse((base / 1000).toStringAsFixed(1));
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _userService.getPerfilNutricional(),
        _notificationService.estaActivado(),
      ]);

      if (!mounted) return;

      final result = results[0] as Map<String, dynamic>;
      final notifActiva = results[1] as bool;

      if (result['success'] == true) {
        setState(() {
          _tieneDatos = result['tieneDatos'] ?? false;
          _perfil = result['user'];
          _notifActivadas = notifActiva;
          if (_tieneDatos && _perfil != null) {
            _pesoController.text = '${_perfil!['peso']}';
            _alturaController.text = '${_perfil!['altura']}';
            _edadController.text = '${_perfil!['edad']}';
            _sexo = _perfil!['sexo'];
            _nivelActividad = _perfil!['nivelActividad'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _animController.forward();
      }
    }
  }

  Future<void> _guardar() async {
    final peso = double.tryParse(_pesoController.text.trim());
    final altura = double.tryParse(_alturaController.text.trim());
    final edad = int.tryParse(_edadController.text.trim());

    if (peso == null || altura == null || edad == null) {
      _showMessage('Por favor ingresa valores válidos');
      return;
    }
    if (_sexo == null) {
      _showMessage('Selecciona tu sexo biológico');
      return;
    }
    if (_nivelActividad == null) {
      _showMessage('Selecciona tu nivel de actividad');
      return;
    }
    if (peso < 20 || peso > 300) {
      _showMessage('El peso debe estar entre 20 y 300 kg');
      return;
    }
    if (altura < 100 || altura > 250) {
      _showMessage('La altura debe estar entre 100 y 250 cm');
      return;
    }
    if (edad < 10 || edad > 100) {
      _showMessage('La edad debe estar entre 10 y 100 años');
      return;
    }

    setState(() => _guardando = true);

    final result = await _userService.updatePerfilNutricional(
      peso: peso,
      altura: altura,
      edad: edad,
      sexo: _sexo!,
      nivelActividad: _nivelActividad!,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (result['success'] == true) {
      _showMessage('Perfil guardado correctamente ✓', ok: true);
      setState(() => _editando = false);
      await _cargar();
    } else {
      _showMessage(result['error'] ?? 'Error al guardar');
    }
  }

  Future<void> _toggleNotificaciones(bool valor) async {
    setState(() => _togglingNotif = true);
    try {
      if (valor) {
        await _notificationService.pedirPermisos();
        await _notificationService.activar(_calcularAgua());
      } else {
        await _notificationService.desactivar();
      }
      if (mounted) setState(() => _notifActivadas = valor);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  valor
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  valor
                      ? 'Recordatorios activados ✓'
                      : 'Recordatorios desactivados',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: valor
                ? const Color(0xFF10B981)
                : Colors.grey.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingNotif = false);
    }
  }

  void _showMessage(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: ok ? const Color(0xFF10B981) : Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: Column(
        children: [
          _buildHeader(),
          _buildBreadcrumb(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _naranja),
                  )
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: !_tieneDatos || _editando
                          ? _formulario()
                          : _resultados(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x80000000), BlendMode.darken),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Perfil Nutricional',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (_tieneDatos && !_editando)
                    GestureDetector(
                      onTap: () => setState(() => _editando = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        85,
                        64,
                        51,
                      ).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu salud, tu objetivo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'IMC · calorías · hidratación personalizados',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
        Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade300),
        Text(
          'Perfil Nutricional',
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

  // ════════════════════════════════════════════════
  // FORMULARIO
  // ════════════════════════════════════════════════

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_tieneDatos) ...[
          _infoCard(
            icon: Icons.info_outline_rounded,
            color: _naranja,
            bgColor: _naranjaClaro,
            text:
                'Completa tu perfil para recibir recomendaciones de menús y recordatorios de hidratación personalizados.',
          ),
          const SizedBox(height: 20),
        ],

        _labelSeccion('Datos físicos'),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _campo(
                controller: _pesoController,
                label: 'Peso',
                sufijo: 'kg',
                icono: Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                controller: _alturaController,
                label: 'Altura',
                sufijo: 'cm',
                icono: Icons.height_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _campo(
          controller: _edadController,
          label: 'Edad',
          sufijo: 'años',
          icono: Icons.cake_outlined,
        ),
        const SizedBox(height: 24),

        _labelSeccion('Sexo biológico'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _sexoChip(
                valor: 'masculino',
                label: 'Masculino',
                icono: Icons.male_rounded,
                color: _azul,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sexoChip(
                valor: 'femenino',
                label: 'Femenino',
                icono: Icons.female_rounded,
                color: const Color(0xFFEC4899),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _labelSeccion('Nivel de actividad'),
        const SizedBox(height: 12),
        ..._nivelesActividad.map((n) => _actividadItem(n)),
        const SizedBox(height: 28),

        _botonPrimario(
          onTap: _guardando ? null : _guardar,
          loading: _guardando,
          label: _tieneDatos ? 'Actualizar perfil' : 'Calcular mi perfil',
          icon: Icons.check_rounded,
          color: _naranja,
        ),

        if (_editando) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _editando = false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  // ════════════════════════════════════════════════
  // RESULTADOS
  // ════════════════════════════════════════════════

  Widget _resultados() {
    if (_perfil == null) return const SizedBox();

    final objetivo = _objetivos[_perfil!['objetivoRecomendado']];
    final color = objetivo?['color'] as Color? ?? Colors.grey;
    final gradients =
        objetivo?['gradient'] as List<Color>? ??
        [Colors.grey, Colors.grey.shade400];
    final imc = (_perfil!['imc'] as num?)?.toDouble() ?? 0.0;
    final tdee = (_perfil!['tdee'] as num?)?.toDouble() ?? 0.0;
    final litros = _calcularAgua();
    final vasos = (litros * 1000 / 250).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card objetivo recomendado ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradients,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  objetivo?['icono'] as IconData? ?? Icons.flag_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OBJETIVO RECOMENDADO',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      objetivo?['label'] as String? ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      objetivo?['descripcion'] as String? ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── IMC + Calorías ──
        Row(
          children: [
            Expanded(
              child: _statCard(
                titulo: 'IMC',
                valor: imc.toStringAsFixed(1),
                subtitulo: _perfil!['categoriaImc'] ?? '',
                icono: Icons.monitor_weight_outlined,
                color: _colorImc(imc),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                titulo: 'Calorías / día',
                valor: tdee.toStringAsFixed(0),
                subtitulo: 'kcal recomendadas',
                icono: Icons.local_fire_department_outlined,
                color: _naranja,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Card hidratación + toggle integrado ──
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Parte superior: datos de agua con gradiente ──
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_azul, Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HIDRATACIÓN DIARIA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$litros',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' L/día',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '≈ $vasos vasos de 250 ml',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Indicador visual de vasos
                    Column(
                      children: List.generate(
                        4,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Icon(
                            i < (litros / 0.5).ceil().clamp(0, 4)
                                ? Icons.local_drink_rounded
                                : Icons.local_drink_outlined,
                            color: i < (litros / 0.5).ceil().clamp(0, 4)
                                ? Colors.white
                                : Colors.white30,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Horario colapsable (solo si notif activas) ──
              if (_notifActivadas) ...[
                GestureDetector(
                  onTap: () =>
                      setState(() => _mostrarHorario = !_mostrarHorario),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _azul.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.schedule_outlined,
                            color: _azul,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Horario de recordatorios',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _mostrarHorario ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Column(
                      children: [
                        _horarioItem(
                          '7:00 AM',
                          '¡Buenos días! Empieza el día con un vaso de agua',
                        ),
                        _horarioItem('11:00 AM', 'Recuerda hidratarte'),
                        _horarioItem('3:00 PM', 'Es hora de tomar tu agua'),
                        _horarioItem('7:00 PM', 'Hidratación de la tarde'),
                        _horarioItem(
                          '9:00 PM',
                          '¿Ya tomaste tus $vasos vasos hoy?',
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _mostrarHorario
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],

              // ── Divisor ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),

              // ── Toggle notificaciones ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _notifActivadas
                            ? _azul.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _notifActivadas
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: _notifActivadas ? _azul : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recordatorios de agua',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _notifActivadas
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _notifActivadas
                                ? 'Recibirás 5 recordatorios al día'
                                : 'Activa para recibir recordatorios',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _togglingNotif
                        ? const SizedBox(
                            width: 48,
                            height: 28,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _azul,
                                ),
                              ),
                            ),
                          )
                        : Switch(
                            value: _notifActivadas,
                            onChanged: _toggleNotificaciones,
                            activeThumbColor: Colors.white,
                            activeTrackColor: _azul,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade300,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Datos del perfil en grid ──
        _labelSeccion('Tu información'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _datoChip(
              Icons.monitor_weight_outlined,
              'Peso',
              '${_perfil!['peso']} kg',
              _naranja,
            ),
            _datoChip(
              Icons.height_outlined,
              'Altura',
              '${_perfil!['altura']} cm',
              _azul,
            ),
            _datoChip(
              Icons.cake_outlined,
              'Edad',
              '${_perfil!['edad']} años',
              const Color(0xFF10B981),
            ),
            _datoChip(
              _perfil!['sexo'] == 'masculino'
                  ? Icons.male_rounded
                  : Icons.female_rounded,
              'Sexo',
              _perfil!['sexo'] == 'masculino' ? 'Masculino' : 'Femenino',
              const Color(0xFFEC4899),
            ),
            _datoChip(
              Icons.directions_run_outlined,
              'Actividad',
              _labelActividad(_perfil!['nivelActividad']),
              const Color(0xFFF59E0B),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Info IMC ──
        _infoCard(
          icon: Icons.info_outline_rounded,
          color: _colorImc(imc),
          bgColor: _colorImc(imc).withValues(alpha: 0.07),
          borderColor: _colorImc(imc).withValues(alpha: 0.2),
          text: _perfil!['descripcionImc'] ?? '',
        ),

        const SizedBox(height: 20),

        // ── Botones de acción ──
        _botonPrimario(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlanComidasScreen(perfil: _perfil!),
            ),
          ),
          label: '¿Qué como hoy? — IA',
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 10),
        _botonPrimario(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MenusBalanceadosScreen(
                objetivoInicial: _perfil!['objetivoRecomendado'],
              ),
            ),
          ),
          label: 'Ver menús recomendados',
          icon: Icons.restaurant_menu_outlined,
          color: _naranja,
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ════════════════════════════════════════════════
  // WIDGETS AUXILIARES
  // ════════════════════════════════════════════════

  Widget _horarioItem(String hora, String mensaje) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _azul.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hora,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _azul,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.water_drop_outlined, color: _azul, size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String text,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonPrimario({
    required VoidCallback? onTap,
    required String label,
    required IconData icon,
    required Color color,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _labelSeccion(String titulo) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _naranja,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          titulo.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String sufijo,
    required IconData icono,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: sufijo,
        suffixStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icono, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        floatingLabelStyle: const TextStyle(
          color: _naranja,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _naranja, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
      ),
    );
  }

  Widget _sexoChip({
    required String valor,
    required String label,
    required IconData icono,
    required Color color,
  }) {
    final sel = _sexo == valor;
    return GestureDetector(
      onTap: () => setState(() => _sexo = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: sel ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? color : Colors.grey.shade200,
            width: sel ? 2 : 1.5,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(icono, color: sel ? Colors.white : color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actividadItem(Map<String, dynamic> nivel) {
    final sel = _nivelActividad == nivel['valor'];
    return GestureDetector(
      onTap: () => setState(() => _nivelActividad = nivel['valor']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: sel ? _naranja : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? _naranja : Colors.grey.shade200,
            width: sel ? 0 : 1.5,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: _naranja.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              nivel['icono'] as IconData,
              color: sel ? Colors.white : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    nivel['descripcion'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: sel ? Colors.white70 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (sel)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String titulo,
    required String valor,
    required String subtitulo,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            subtitulo,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _datoChip(IconData icono, String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorImc(double imc) {
    if (imc < 18.5) return _azul;
    if (imc <= 24.9) return const Color(0xFF10B981);
    if (imc <= 29.9) return _naranja;
    return Colors.red.shade400;
  }

  String _labelActividad(String? nivel) {
    const map = {
      'sedentario': 'Sedentario',
      'ligero': 'Ligero',
      'moderado': 'Moderado',
      'activo': 'Activo',
      'muy_activo': 'Muy activo',
    };
    return map[nivel] ?? nivel ?? '';
  }
}
