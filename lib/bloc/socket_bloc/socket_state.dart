abstract class SocketState {}

class Initial extends SocketState {}

class Connected extends SocketState {}

class Disconnected extends SocketState {}

class MessageState extends SocketState {
  final dynamic message;

  MessageState(this.message);
}
