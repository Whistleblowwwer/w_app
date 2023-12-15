// Define los eventos adicionales
import 'package:intl/intl.dart';

abstract class SocketEvent {}

class Connect extends SocketEvent {}

class Disconnect extends SocketEvent {}

class NewMessage extends SocketEvent {
  final Message message;

  NewMessage(this.message);
}

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

class Message {
  String content;
  String idSender;
  String idReceiver;
  DateTime createdAt;

  Message({
    required this.content,
    required this.idSender,
    required this.idReceiver,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // final date = DateFormat('yyyy-MM-dd HH:mm:ss')
    //     .format(DateTime.parse(json['createdAt']).toLocal());
    // print('-----');
    // print(date);
    return Message(
      content: json['content'],
      idSender: json['_id_sender'],
      idReceiver: json['_id_receiver'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }

  String getFormattedTime() {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
