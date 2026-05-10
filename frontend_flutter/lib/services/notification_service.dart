import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static const String _keyActivado = 'notificaciones_agua_activadas';

  // ── Inicializar ──────────────────────────────────────────
  Future<void> inicializar() async {
    await AwesomeNotifications().initialize(
      null, // null = ícono por defecto de la app
      [
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
      ],
    );
  }

  // ── Verificar si están activadas ─────────────────────────
  Future<bool> estaActivado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyActivado) ?? false;
  }

  // ── Pedir permisos ────────────────────────────────────────
  Future<bool> pedirPermisos() async {
    final permitido = await AwesomeNotifications().isNotificationAllowed();
    if (!permitido) {
      return await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return true;
  }

  // ── Activar notificaciones de agua ───────────────────────
  Future<void> activar(double litrosAgua) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivado, true);
    await _programarNotificacionesAgua(litrosAgua);
  }

  // ── Desactivar notificaciones de agua ────────────────────
  Future<void> desactivar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivado, false);
    await AwesomeNotifications().cancelSchedulesByChannelKey('agua_channel');
  }

  // ── Programar notificaciones diarias ─────────────────────
  Future<void> _programarNotificacionesAgua(double litrosAgua) async {
    // Cancelar anteriores
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
          repeats: true, // repite cada día
          allowWhileIdle: true, // funciona aunque el cel esté en reposo
        ),
      );
    }
  }
}