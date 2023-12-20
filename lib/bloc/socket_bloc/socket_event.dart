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

  bool isToday() {
    final now = DateTime.now();
    return createdAt.year == now.year && createdAt.month == now.month && createdAt.day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return createdAt.year == yesterday.year && createdAt.month == yesterday.month && createdAt.day == yesterday.day;
  }
  
  String getFormattedTime() {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String getFormattedDate() {
    if(isToday()){
      return "Hoy";
    }else if(isYesterday()){
      return "Ayer";
    }else{
      return '${createdAt.day.toString().padLeft(2, '0')} de ${_getMonthName(createdAt.month)} de ${createdAt.year}';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'enero';
      case 2:
        return 'febrero';
      case 3:
        return 'marzo';
      case 4:
        return 'abril';
      case 5:
        return 'mayo';
      case 6:
        return 'junio';
      case 7:
        return 'julio';
      case 8:
        return 'agosto';
      case 9:
        return 'septiembre';
      case 10:
        return 'octubre';
      case 11:
        return 'noviembre';
      case 12:
        return 'diciembre';
      default:
        return '';
    }
  }
}
