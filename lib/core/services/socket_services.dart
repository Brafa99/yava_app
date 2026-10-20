import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;

  void initSocket(String userId, String role) {
    // Apunta a la URL base de tu servidor (Node.js / Socket.io)
    socket = IO.io('https://yavaapp.namnamapp.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'user_id': userId,
        'role': role, // 'client' o 'driver'
      },
    });

    socket.connect();

    socket.onConnect((_) {
      log('SOCKET.IO: Conectado exitosamente al servidor Node.js');
    });

    socket.onDisconnect((_) {
      log('SOCKET.IO: Desconectado del servidor');
    });

    socket.onError((data) => log('SOCKET.IO Error: $data'));
  }

  // --- ESCUCHAS DEL DRIVER ---
  void listenDriverEvents({
    required Function(dynamic) onNewRidePending,
    required Function(dynamic) onRideAccepted,
  }) {
    // Canal que mencionó tu colega para los taxistas
    socket.on('taxi:viaje-pendiente', (data) => onNewRidePending(data));
    socket.on('taxi:viaje-aceptar', (data) => onRideAccepted(data));
  }

  // --- ESCUCHAS DEL CLIENTE ---
  void listenClientEvents({
    required Function(dynamic) onDriverOfferReceived,
  }) {
    // Canal que mencionó tu colega para las ofertas al cliente
    socket.on('cliente:viaje-ofertar', (data) => onDriverOfferReceived(data));
  }

  void disconnect() {
    socket.disconnect();
  }
}