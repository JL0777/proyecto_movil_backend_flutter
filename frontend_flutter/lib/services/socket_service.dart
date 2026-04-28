import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';
import '../core/config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  static final String _url = AppConfig.baseUrl.replaceAll('/api', '');

  void conectar() {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    _socket!.onConnect((_) {
      log('Socket conectado');
    });

    _socket!.onDisconnect((_) {
      log('Socket desconectado');
    });

    _socket!.onConnectError((error) {
      log('Error de conexión: $error');
    });
  }

  void escuchar(String evento, Function(dynamic) callback) {
    _socket?.on(evento, callback);
  }

  void dejarDeEscuchar(String evento) {
    _socket?.off(evento);
  }

  void desconectar() {
    _socket?.disconnect();
    _socket = null;
  }

  bool get conectado => _socket?.connected ?? false;
}