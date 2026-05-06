import 'package:flutter/material.dart';
import '../../../../services/user_service.dart';
import 'menus_balanceados_screen.dart';

class PerfilNutricionalScreen extends StatefulWidget {
  const PerfilNutricionalScreen({super.key});

  @override
  State<PerfilNutricionalScreen> createState() =>
      _PerfilNutricionalScreenState();
}

class _PerfilNutricionalScreenState extends State<PerfilNutricionalScreen> {
  final UserService _userService = UserService();

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
      'descripcion': 'Ejercicio 1-3 días/semana',
      'icono': Icons.directions_walk_outlined,
    },
    {
      'valor': 'moderado',
      'label': 'Moderado',
      'descripcion': 'Ejercicio 3-5 días/semana',
      'icono': Icons.directions_run_outlined,
    },
    {
      'valor': 'activo',
      'label': 'Activo',
      'descripcion': 'Ejercicio 6-7 días/semana',
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
      'color': Colors.blue,
      'descripcion': 'Tu plan está enfocado en reducir grasa corporal',
    },
    'subir_musculo': {
      'label': 'Subir músculo',
      'icono': Icons.fitness_center_rounded,
      'color': Colors.orange,
      'descripcion': 'Tu plan está enfocado en ganar masa muscular',
    },
    'mantenimiento': {
      'label': 'Mantenimiento',
      'icono': Icons.balance_rounded,
      'color': Colors.green,
      'descripcion': 'Tu peso está en el rango ideal',
    },
    'energia': {
      'label': 'Energía',
      'icono': Icons.bolt_rounded,
      'color': Colors.amber,
      'descripcion': 'Tu plan está enfocado en mejorar tu energía',
    },
    'digestivo': {
      'label': 'Digestivo',
      'icono': Icons.spa_rounded,
      'color': Colors.teal,
      'descripcion': 'Tu plan está enfocado en mejorar tu digestión',
    },
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  double _calcularAgua() {
    final peso = double.tryParse('${_perfil!['peso']}') ?? 0;
    double base = peso * 35; // ml base

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

    return base / 1000; // convertir a litros
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final result = await _userService.getPerfilNutricional();
      if (!mounted) return;
      if (result['success']) {
        setState(() {
          _tieneDatos = result['tieneDatos'] ?? false;
          _perfil = result['user'];
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardar() async {
    // Validaciones
    final peso = double.tryParse(_pesoController.text.trim());
    final altura = double.tryParse(_alturaController.text.trim());
    final edad = int.tryParse(_edadController.text.trim());

    if (peso == null || altura == null || edad == null) {
      _showMessage('Por favor ingresa valores válidos');
      return;
    }
    if (_sexo == null) {
      _showMessage('Selecciona tu sexo');
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

    if (result['success']) {
      _showMessage('Perfil nutricional guardado ✓', ok: true);
      setState(() => _editando = false);
      await _cargar();
    } else {
      _showMessage(result['error'] ?? 'Error al guardar');
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

  @override
  Widget build(BuildContext context) {
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
            child: SafeArea(
              child: Column(
                children: [
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
                            'Perfil Nutricional',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_tieneDatos && !_editando)
                          TextButton.icon(
                            onPressed: () => setState(() => _editando = true),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: const Text(
                              'Editar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.monitor_weight_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tu salud, tu objetivo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Calculamos tu IMC y calorías diarias',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8651A)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: !_tieneDatos || _editando
                        ? _formulario()
                        : _resultados(),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Formulario ─────────────────────────────────────────────

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_tieneDatos) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE8651A).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFE8651A), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Completa tu perfil para recibir recomendaciones de menús personalizadas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE8651A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Datos físicos
        _seccion('Datos físicos'),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _campo(
                controller: _pesoController,
                label: 'Peso',
                sufijo: 'kg',
                icono: Icons.monitor_weight_outlined,
                tipo: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                controller: _alturaController,
                label: 'Altura',
                sufijo: 'cm',
                icono: Icons.height_outlined,
                tipo: TextInputType.number,
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
          tipo: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Sexo
        _seccion('Sexo biológico'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _sexoChip(
                valor: 'masculino',
                label: 'Masculino',
                icono: Icons.male_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sexoChip(
                valor: 'femenino',
                label: 'Femenino',
                icono: Icons.female_rounded,
                color: Colors.pink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nivel de actividad
        _seccion('Nivel de actividad'),
        const SizedBox(height: 12),
        ..._nivelesActividad.map((n) => _actividadItem(n)),

        const SizedBox(height: 24),

        // Botón guardar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _guardando ? null : _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8651A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _tieneDatos ? 'Actualizar perfil' : 'Calcular mi perfil',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        if (_editando) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _editando = false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],

        const SizedBox(height: 30),
      ],
    );
  }

  // ── Resultados ─────────────────────────────────────────────

  Widget _resultados() {
    if (_perfil == null) return const SizedBox();

    final objetivo = _objetivos[_perfil!['objetivoRecomendado']];
    final color = objetivo?['color'] as Color? ?? Colors.grey;
    final imc = _perfil!['imc'] ?? 0.0;
    final tdee = _perfil!['tdee'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card objetivo recomendado ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      objetivo?['icono'] as IconData? ?? Icons.flag_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu objetivo recomendado',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        objetivo?['label'] as String? ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                objetivo?['descripcion'] as String? ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── IMC y TDEE ──
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
                titulo: 'Calorías/día',
                valor: tdee.toStringAsFixed(0),
                subtitulo: 'kcal recomendadas',
                icono: Icons.local_fire_department_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Card agua ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agua recomendada',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _calcularAgua().toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue,
                            ),
                          ),
                          const TextSpan(
                            text: ' L/día',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '≈ ${(_calcularAgua() * 1000 / 250).ceil()} vasos de 250 ml',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
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
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Icon(
                      Icons.local_drink_outlined,
                      size: 14,
                      color: i < (_calcularAgua() / 0.5).ceil().clamp(0, 4)
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Datos ingresados ──
        _seccion('Tus datos'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              _datoRow(
                Icons.monitor_weight_outlined,
                'Peso',
                '${_perfil!['peso']} kg',
              ),
              _datoRow(
                Icons.height_outlined,
                'Altura',
                '${_perfil!['altura']} cm',
              ),
              _datoRow(Icons.cake_outlined, 'Edad', '${_perfil!['edad']} años'),
              _datoRow(
                _perfil!['sexo'] == 'masculino'
                    ? Icons.male_rounded
                    : Icons.female_rounded,
                'Sexo',
                _perfil!['sexo'] == 'masculino' ? 'Masculino' : 'Femenino',
              ),
              _datoRow(
                Icons.directions_run_outlined,
                'Actividad',
                _labelActividad(_perfil!['nivelActividad']),
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Descripción IMC ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _colorImc(imc).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _colorImc(imc).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: _colorImc(imc), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _perfil!['descripcionImc'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: _colorImc(imc),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Ver menús recomendados ──
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Aquí se navega a la pantalla de menús balanceados
              // pasando el objetivo recomendado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MenusBalanceadosScreen(
                    objetivoInicial: _perfil!['objetivoRecomendado'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8651A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.restaurant_menu_outlined, size: 18),
            label: const Text(
              'Ver menús recomendados',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Color _colorImc(double imc) {
    if (imc < 18.5) return Colors.blue;
    if (imc <= 24.9) return Colors.green;
    if (imc <= 29.9) return Colors.orange;
    return Colors.red;
  }

  String _labelActividad(String? nivel) {
    switch (nivel) {
      case 'sedentario':
        return 'Sedentario';
      case 'ligero':
        return 'Ligero';
      case 'moderado':
        return 'Moderado';
      case 'activo':
        return 'Activo';
      case 'muy_activo':
        return 'Muy activo';
      default:
        return nivel ?? '';
    }
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
        Container(width: 30, height: 2, color: const Color(0xFFE8651A)),
      ],
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String sufijo,
    required IconData icono,
    required TextInputType tipo,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        suffixText: sufijo,
        prefixIcon: Icon(icono, color: Colors.grey.shade500, size: 20),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFFE8651A),
          fontSize: 13,
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
          borderSide: const BorderSide(color: Color(0xFFE8651A), width: 1.8),
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
    final seleccionado = _sexo == valor;
    return GestureDetector(
      onTap: () => setState(() => _sexo = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? color : color.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: seleccionado ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actividadItem(Map<String, dynamic> nivel) {
    final seleccionado = _nivelActividad == nivel['valor'];
    return GestureDetector(
      onTap: () => setState(() => _nivelActividad = nivel['valor']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFFE8651A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado
                ? const Color(0xFFE8651A)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              nivel['icono'] as IconData,
              color: seleccionado ? Colors.white : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: seleccionado ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    nivel['descripcion'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: seleccionado
                          ? Colors.white70
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Icon(icono, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitulo,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _datoRow(
    IconData icono,
    String label,
    String valor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icono, size: 16, color: const Color(0xFFE8651A)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}
