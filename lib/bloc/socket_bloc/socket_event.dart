// Define los eventos adicionales
abstract class SocketEvent {}

class Connect extends SocketEvent {}

class Disconnect extends SocketEvent {}

class SendMessage extends SocketEvent {
  final String content;
  final String idSender;
  final String idReceiver;

  SendMessage(this.content, this.idSender, this.idReceiver);
}

class JoinConversation extends SocketEvent {
  final String idSender;
  final String idReceiver;

  JoinConversation(this.idSender, this.idReceiver);
}

class LeaveConversation extends SocketEvent {
  final String idSender;
  final String idReceiver;

  LeaveConversation(this.idSender, this.idReceiver);
}

// Agrega más eventos según sea necesario...
