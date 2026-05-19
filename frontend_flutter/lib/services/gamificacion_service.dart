import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Logro {
  final String id;
  final String emoji;
  final String titulo;
  final String descripcion;
  final bool desbloqueado;
  final String? fechaDesbloqueo;

  const Logro({
    required this.id,
    required this.emoji,
    required this.titulo,
    required this.descripcion,
    required this.desbloqueado,
    this.fechaDesbloqueo,
  });
}

class GamificacionService {
  static const String _prefKeyRacha = 'gamif_racha';
  static const String _prefKeyUltimoDia = 'gamif_ultimo_dia';
  static const String _prefKeyLogros = 'gamif_logros';
  static const String _prefKeyTotalDias = 'gamif_total_dias';
  static const String _prefKeyTotalScans = 'gamif_total_scans';

  // Definición de todos los logros posibles
  static const List<Map<String, String>> _definiciones = [
    {'id': 'primer_dia', 'emoji': '🌱', 'titulo': 'Primer paso', 'descripcion': 'Completaste tu primer día en meta'},
    {'id': 'racha_3', 'emoji': '🔥', 'titulo': 'En racha', 'descripcion': '3 días consecutivos en meta'},
    {'id': 'racha_7', 'emoji': '⚡', 'titulo': 'Imparable', 'descripcion': '7 días consecutivos en meta'},
    {'id': 'racha_14', 'emoji': '💪', 'titulo': 'Dedicación total', 'descripcion': '14 días consecutivos en meta'},
    {'id': 'racha_30', 'emoji': '🏆', 'titulo': 'Leyenda', 'descripcion': '30 días consecutivos en meta'},
    {'id': 'primer_scan', 'emoji': '📸', 'titulo': 'Ojo clínico', 'descripcion': 'Escaneaste tu primer alimento'},
    {'id': 'scan_5', 'emoji': '🔍', 'titulo': 'Analista', 'descripcion': 'Escaneaste 5 alimentos'},
    {'id': 'scan_20', 'emoji': '🧬', 'titulo': 'Nutricionista', 'descripcion': 'Escaneaste 20 alimentos'},
    {'id': 'dias_7', 'emoji': '📅', 'titulo': 'Una semana', 'descripcion': '7 días totales en meta'},
    {'id': 'dias_30', 'emoji': '🥇', 'titulo': 'Un mes', 'descripcion': '30 días totales en meta'},
  ];

  // Registra un día completado y devuelve los logros nuevos desbloqueados
  static Future<List<Logro>> registrarDiaEnMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = _fechaHoy();
    final ultimoDia = prefs.getString(_prefKeyUltimoDia) ?? '';
    int racha = prefs.getInt(_prefKeyRacha) ?? 0;
    int totalDias = prefs.getInt(_prefKeyTotalDias) ?? 0;

    // Evitar registrar el mismo día dos veces
    if (ultimoDia == hoy) return [];

    // Calcular racha
    final ayer = _fechaAyer();
    if (ultimoDia == ayer) {
      racha++;
    } else {
      racha = 1; // Se rompió la racha
    }

    totalDias++;

    await prefs.setString(_prefKeyUltimoDia, hoy);
    await prefs.setInt(_prefKeyRacha, racha);
    await prefs.setInt(_prefKeyTotalDias, totalDias);

    return await _verificarLogros(prefs, racha: racha, totalDias: totalDias);
  }

  // Registra un scan y devuelve logros nuevos
  static Future<List<Logro>> registrarScan() async {
    final prefs = await SharedPreferences.getInstance();
    int totalScans = (prefs.getInt(_prefKeyTotalScans) ?? 0) + 1;
    await prefs.setInt(_prefKeyTotalScans, totalScans);
    return await _verificarLogros(prefs, totalScans: totalScans);
  }

  // Verifica y desbloquea logros nuevos
  static Future<List<Logro>> _verificarLogros(
    SharedPreferences prefs, {
    int racha = 0,
    int totalDias = 0,
    int totalScans = 0,
  }) async {
    racha = racha > 0 ? racha : (prefs.getInt(_prefKeyRacha) ?? 0);
    totalDias = totalDias > 0 ? totalDias : (prefs.getInt(_prefKeyTotalDias) ?? 0);
    totalScans = totalScans > 0 ? totalScans : (prefs.getInt(_prefKeyTotalScans) ?? 0);

    final logrosJson = prefs.getString(_prefKeyLogros) ?? '{}';
    Map<String, dynamic> logrosGuardados = {};
    try {
      logrosGuardados = jsonDecode(logrosJson) as Map<String, dynamic>;
    } catch (_) {}

    final nuevosLogros = <Logro>[];

    // Condiciones para cada logro
    final condiciones = {
      'primer_dia': totalDias >= 1,
      'racha_3': racha >= 3,
      'racha_7': racha >= 7,
      'racha_14': racha >= 14,
      'racha_30': racha >= 30,
      'primer_scan': totalScans >= 1,
      'scan_5': totalScans >= 5,
      'scan_20': totalScans >= 20,
      'dias_7': totalDias >= 7,
      'dias_30': totalDias >= 30,
    };

    for (final def in _definiciones) {
      final id = def['id']!;
      final cumple = condiciones[id] ?? false;
      final yaDesbloqueado = logrosGuardados.containsKey(id);

      if (cumple && !yaDesbloqueado) {
        final fecha = _fechaHoy();
        logrosGuardados[id] = fecha;
        nuevosLogros.add(Logro(
          id: id,
          emoji: def['emoji']!,
          titulo: def['titulo']!,
          descripcion: def['descripcion']!,
          desbloqueado: true,
          fechaDesbloqueo: fecha,
        ));
      }
    }

    if (nuevosLogros.isNotEmpty) {
      await prefs.setString(_prefKeyLogros, jsonEncode(logrosGuardados));
    }

    return nuevosLogros;
  }

  // Obtiene el estado completo de gamificación
  static Future<Map<String, dynamic>> obtenerEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final racha = prefs.getInt(_prefKeyRacha) ?? 0;
    final totalDias = prefs.getInt(_prefKeyTotalDias) ?? 0;
    final totalScans = prefs.getInt(_prefKeyTotalScans) ?? 0;

    final logrosJson = prefs.getString(_prefKeyLogros) ?? '{}';
    Map<String, dynamic> logrosGuardados = {};
    try {
      logrosGuardados = jsonDecode(logrosJson) as Map<String, dynamic>;
    } catch (_) {}

    final logros = _definiciones.map((def) {
      final id = def['id']!;
      final desbloqueado = logrosGuardados.containsKey(id);
      return Logro(
        id: id,
        emoji: def['emoji']!,
        titulo: def['titulo']!,
        descripcion: def['descripcion']!,
        desbloqueado: desbloqueado,
        fechaDesbloqueo: desbloqueado ? logrosGuardados[id] as String : null,
      );
    }).toList();

    return {
      'racha': racha,
      'totalDias': totalDias,
      'totalScans': totalScans,
      'logros': logros,
    };
  }

  static String _fechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String _fechaAyer() {
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    return '${ayer.year}-${ayer.month}-${ayer.day}';
  }
}