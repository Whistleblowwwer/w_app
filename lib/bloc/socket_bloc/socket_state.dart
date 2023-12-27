import 'package:socket_io_client/socket_io_client.dart';

abstract class SocketState {}

class Initial extends SocketState {}

class Connected extends SocketState {
  final Socket socket;

  Connected(this.socket);
}

class Disconnected extends SocketState {}

/*(class ArrivedMessage extends SocketState {
  final Message message;

  ArrivedMessage(this.message);
}*/
