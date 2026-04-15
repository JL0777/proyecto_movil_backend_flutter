import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/pedido_service.dart';

class NotificacionService {
  static final NotificacionService _instance =
      NotificacionService._internal();
  factory NotificacionService() => _instance;
  NotificacionService._internal();

  Timer? _timer;
  Map<int, String> _estadosAnteriores = {};
  final PedidoService _pedidoService = PedidoService();
  BuildContext? _context;

  final Map<String, String> _mensajes = {
    'Pendiente': '⏳ Tu pedido está siendo procesado',
    'Activo': '👨‍🍳 Tu pedido está en preparación',
    'Realizado': '✅ Tu pedido está listo',
    'Enviado': '🛵 Tu pedido fue enviado',
  };

  final Map<String, Color> _colores = {
    'Pendiente': Colors.grey,
    'Activo': Colors.orange,
    'Realizado': Colors.green,
    'Enviado': Colors.blue,
  };

  void iniciar(BuildContext context) {
    _context = context;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _verificarCambios();
    });
    _cargarEstadosIniciales();
  }

  void detener() {
    _timer?.cancel();
    _timer = null;
    _estadosAnteriores = {};
  }

  Future<void> _cargarEstadosIniciales() async {
    try {
      final pedidos = await _pedidoService.getMisPedidos();
      for (final p in pedidos) {
        _estadosAnteriores[p['id']] = p['estado'];
      }
    } catch (e) {
      // silencioso
    }
  }

  Future<void> _verificarCambios() async {
    if (_context == null || !(_context!.mounted)) return;

    try {
      final pedidos = await _pedidoService.getMisPedidos();

      for (final p in pedidos) {
        final id = p['id'] as int;
        final estadoActual = p['estado'] as String;
        final estadoAnterior = _estadosAnteriores[id];

        if (estadoAnterior != null && estadoAnterior != estadoActual) {
          _mostrarNotificacion(estadoActual);
        }

        _estadosAnteriores[id] = estadoActual;
      }
    } catch (e) {
      // silencioso
    }
  }

  void _mostrarNotificacion(String estado) {
    if (_context == null || !(_context!.mounted)) return;

    final mensaje = _mensajes[estado] ?? 'Tu pedido fue actualizado';
    final color = _colores[estado] ?? Colors.orange;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}