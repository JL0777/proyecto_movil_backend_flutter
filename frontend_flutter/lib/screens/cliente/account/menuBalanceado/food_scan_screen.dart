import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/ia_service.dart';

class FoodScanScreen extends StatefulWidget {
  final int tdee;
  const FoodScanScreen({super.key, required this.tdee});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen>
    with SingleTickerProviderStateMixin {
  final IaService _iaService = IaService();
  final ImagePicker _picker = ImagePicker();

  File? _imagen;
  bool _analizando = false;
  String? _error;
  Map<String, dynamic>? _resultado;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const Color _naranja = Color(0xFFE8651A);
  static const Color _fondo = Color(0xFFF2F1EF);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource fuente) async {
    final picked = await _picker.pickImage(
      source: fuente,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null) return;
    setState(() {
      _imagen = File(picked.path);
      _resultado = null;
      _error = null;
    });
    await _analizar();
  }

  Future<void> _analizar() async {
    if (_imagen == null) return;
    setState(() {
      _analizando = true;
      _error = null;
      _resultado = null;
    });
    final result = await _iaService.analizarFotoComida(_imagen!);
    if (!mounted) return;
    if (result['success']) {
      setState(() {
        _resultado = result['resultado'] as Map<String, dynamic>;
        _analizando = false;
      });
      _fadeCtrl.reset();
      _fadeCtrl.forward();
    } else {
      setState(() {
        _error = result['error'];
        _analizando = false;
      });
    }
  }

  // Devuelve las calorías al plan y vuelve atrás
  void _agregarAlDia() {
    final calorias = (_resultado?['calorias'] ?? 0) as num;
    Navigator.pop(context, calorias.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: Column(
        children: [
          _buildHeader(),
          _buildBreadcrumb(),
          Expanded(
            child: _imagen == null ? _buildEstadoVacio() : _buildContenido(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          _headerBtn(Icons.arrow_back, () => Navigator.pop(context)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escanear comida',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Análisis nutricional con IA',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          if (_imagen != null)
            _headerBtn(
              Icons.refresh_rounded,
              _analizando ? null : _analizar,
              tooltip: 'Analizar de nuevo',
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
          Text(
            'Escanear comida',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFE8651A),
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

  Widget _buildEstadoVacio() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _naranja.withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Fotografía tu comida',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La IA detectará el plato y calculará\nsus valores nutricionales al instante',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _botonFuente(
            icono: Icons.camera_alt_rounded,
            label: 'Tomar foto',
            sublabel: 'Usa la cámara ahora',
            color: _naranja,
            onTap: () => _seleccionarImagen(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _botonFuente(
            icono: Icons.photo_library_outlined,
            label: 'Elegir de galería',
            sublabel: 'Selecciona una foto existente',
            color: const Color(0xFF6366F1),
            onTap: () => _seleccionarImagen(ImageSource.gallery),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 5),
              Text(
                'Las fotos se procesan y no se almacenan',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _botonFuente({
    required IconData icono,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          _buildImagenCard(),
          const SizedBox(height: 16),
          if (_analizando)
            _buildAnalizando()
          else if (_error != null)
            _buildError()
          else if (_resultado != null)
            FadeTransition(
              opacity: _fadeAnim,
              child: _buildResultado(_resultado!),
            ),
        ],
      ),
    );
  }

  Widget _buildImagenCard() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(_imagen!, fit: BoxFit.cover),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    _miniBtn(
                      Icons.camera_alt_outlined,
                      'Cámara',
                      () => _seleccionarImagen(ImageSource.camera),
                    ),
                    const SizedBox(width: 8),
                    _miniBtn(
                      Icons.photo_library_outlined,
                      'Galería',
                      () => _seleccionarImagen(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalizando() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _naranja.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: _naranja.withValues(alpha: 0.18),
                width: 2,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: _naranja,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Analizando tu plato...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Detectando ingredientes y calculando macros',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _analizar,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _naranja,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Intentar de nuevo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado(Map<String, dynamic> r) {
    final semaforo = r['semaforo'] ?? 'verde';
    final colorSemaforo = semaforo == 'verde'
        ? const Color(0xFF10B981)
        : semaforo == 'amarillo'
        ? const Color(0xFFF59E0B)
        : Colors.red.shade400;

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: colorSemaforo.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorSemaforo.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      r['emoji'] ?? '🍽️',
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['nombre'] ?? 'Plato detectado',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            r['porcion'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorSemaforo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: colorSemaforo,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            semaforo == 'verde'
                                ? 'Saludable'
                                : semaforo == 'amarillo'
                                ? 'Moderado'
                                : 'Ocasional',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorSemaforo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${r['calorias'] ?? 0}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: colorSemaforo,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Row(
                  children: [
                    _macroChip(
                      'Proteínas',
                      '${r['proteinas'] ?? 0}g',
                      const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 8),
                    _macroChip(
                      'Carbos',
                      '${r['carbohidratos'] ?? 0}g',
                      _naranja,
                    ),
                    const SizedBox(width: 8),
                    _macroChip(
                      'Grasas',
                      '${r['grasas'] ?? 0}g',
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _macroChip(
                      'Fibra',
                      '${r['fibra'] ?? 0}g',
                      const Color(0xFF3B82F6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (r['descripcion'] != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r['descripcion'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (r['consejo'] != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _naranja.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: _naranja,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r['consejo'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: _naranja,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // ── Botones: Volver + Agregar al día ──
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black54,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Volver',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _agregarAlDia,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Agregar al día',
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
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Botón Otro alimento ──
        GestureDetector(
          onTap: () => setState(() {
            _imagen = null;
            _resultado = null;
            _error = null;
          }),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_rounded, color: Colors.black38, size: 16),
                SizedBox(width: 8),
                Text(
                  'Escanear otro alimento',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _macroChip(String label, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
