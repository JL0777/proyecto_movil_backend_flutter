import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/config/app_config.dart';


class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  static final String _url = AppConfig.baseUrl.replaceAll('/api', '');

  void conectar() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    _socket!.onConnect((_) {
      print('Socket conectado');
    });

    _socket!.onDisconnect((_) {
      print('Socket desconectado');
    });

    _socket!.onConnectError((error) {
      print('Error de conexión: $error');
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