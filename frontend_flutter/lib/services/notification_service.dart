import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static const String _keyActivado = 'notificaciones_agua_activadas';
  static const String _keyRachaActivada = 'notificaciones_racha_activadas';
  static const String _keyRachaHora = 'notificaciones_racha_hora';
  static const String _keyRachaMinuto = 'notificaciones_racha_minuto';

  Future<void> inicializar() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'agua_channel',
        channelName: 'Recordatorios de agua',
        channelDescription: 'Notificaciones para recordar tomar agua',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF2196F3),
        ledColor: const Color(0xFF2196F3),
        channelShowBadge: true,
        locked: false,
      ),
      // NUEVO canal de racha
      NotificationChannel(
        channelKey: 'racha_channel',
        channelName: 'Recordatorio de racha',
        channelDescription: 'Notificación diaria para mantener tu racha',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFFE8651A),
        ledColor: const Color(0xFFE8651A),
        channelShowBadge: true,
        locked: false,
      ),
    ]);
  }

  // ── Agua (igual que antes) ────────────────────────────────
  Future<bool> estaActivado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyActivado) ?? false;
  }

  Future<bool> pedirPermisos() async {
    final permitido = await AwesomeNotifications().isNotificationAllowed();
    if (!permitido) {
      return await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return true;
  }

  Future<void> activar(double litrosAgua) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivado, true);
    await _programarNotificacionesAgua(litrosAgua);
  }

  Future<void> desactivar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivado, false);
    await AwesomeNotifications().cancelSchedulesByChannelKey('agua_channel');
  }

  Future<void> _programarNotificacionesAgua(double litrosAgua) async {
    await AwesomeNotifications().cancelSchedulesByChannelKey('agua_channel');
    final vasos = (litrosAgua * 1000 / 250).ceil();
    final List<Map<String, dynamic>> horarios = [
      {
        'id': 1001,
        'hora': 7,
        'minuto': 0,
        'titulo': '💧 ¡Buenos días!',
        'mensaje': 'Empieza el día con un vaso de agua',
      },
      {
        'id': 1002,
        'hora': 11,
        'minuto': 0,
        'titulo': '💧 Hora de hidratarte',
        'mensaje': 'Llevas unas horas sin tomar agua, ¡bebe un vaso ahora!',
      },
      {
        'id': 1003,
        'hora': 15,
        'minuto': 0,
        'titulo': '💧 Recordatorio de agua',
        'mensaje': 'Es hora de tomar tu agua, ¡no lo olvides!',
      },
      {
        'id': 1004,
        'hora': 19,
        'minuto': 0,
        'titulo': '💧 Hidratación de la tarde',
        'mensaje': 'Toma un vaso de agua antes de la cena',
      },
      {
        'id': 1005,
        'hora': 21,
        'minuto': 0,
        'titulo': '💧 Resumen del día',
        'mensaje': '¿Ya tomaste tus $vasos vasos de agua hoy?',
      },
    ];
    for (final h in horarios) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: h['id'] as int,
          channelKey: 'agua_channel',
          title: h['titulo'] as String,
          body: h['mensaje'] as String,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          hour: h['hora'] as int,
          minute: h['minuto'] as int,
          second: 0,
          repeats: true,
          preciseAlarm: true,
        ),
      );
    }
  }

  // ── RACHA: nuevos métodos ─────────────────────────────────

  Future<bool> rachaEstaActivada() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRachaActivada) ?? false;
  }

  Future<TimeOfDay> rachaHoraGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final hora = prefs.getInt(_keyRachaHora) ?? 20;
    final minuto = prefs.getInt(_keyRachaMinuto) ?? 0;
    return TimeOfDay(hour: hora, minute: minuto);
  }

  Future<void> activarRacha(int hora, int minuto, int rachaActual) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRachaActivada, true);
    await prefs.setInt(_keyRachaHora, hora);
    await prefs.setInt(_keyRachaMinuto, minuto);
    await _programarNotificacionRacha(hora, minuto, rachaActual);
  }

  Future<void> desactivarRacha() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRachaActivada, false);
    await AwesomeNotifications().cancelSchedulesByChannelKey('racha_channel');
  }

  Future<void> actualizarRacha(int rachaActual) async {
    final activada = await rachaEstaActivada();
    if (!activada) return;
    final hora = await rachaHoraGuardada();
    await _programarNotificacionRacha(hora.hour, hora.minute, rachaActual);
  }

  Future<void> _programarNotificacionRacha(
    int hora,
    int minuto,
    int racha,
  ) async {
    await AwesomeNotifications().cancelSchedulesByChannelKey('racha_channel');

    final titulo = racha == 0
        ? '🔥 ¡Empieza tu racha hoy!'
        : '🔥 Racha de $racha ${racha == 1 ? 'día' : 'días'}';

    final mensaje = racha == 0
        ? 'Completa tu plan de comidas y comienza tu racha'
        : racha < 3
        ? '¡Vas bien! No pierdas tu racha de $racha ${racha == 1 ? 'día' : 'días'}'
        : racha < 7
        ? '🔥 ¡$racha días seguidos! Sigue así, no pares ahora'
        : '⚡ ¡Increíble racha de $racha días! Eres imparable';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2001,
        channelKey: 'racha_channel',
        title: titulo,
        body: mensaje,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        hour: hora,
        minute: minuto,
        second: 0,
        repeats: true,
        preciseAlarm: true, 
      ),
    );
  }
}
