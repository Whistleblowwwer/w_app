// Define los eventos adicionales

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
    final now = DateTime.now().toLocal();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().toLocal().subtract(Duration(days: 1));
    return createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
  }

  String getFormattedTime() {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String getFormattedDate() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime createdAtDate =
        DateTime(createdAt.year, createdAt.month, createdAt.day);
    final int differenceInDays = today.difference(createdAtDate).inDays;

    if (isToday()) {
      return "Hoy";
    } else if (isYesterday()) {
      return "Ayer";
    } else if (differenceInDays < 7) {
      // For dates within the last seven days
      return '${_formatDayOfWeek(createdAt)}, ${_formatMonth(createdAt.month)} ${createdAt.day}';
    } else {
      // For dates more than seven days ago
      return '${_formatMonth(createdAt.month)}. ${createdAt.day}, ${createdAt.year}';
    }
  }

  String _formatDayOfWeek(DateTime date) {
    // Depending on your locale, you might want to change these
    const daysOfWeek = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    return daysOfWeek[date.weekday - 1];
  }

  String _formatMonth(int month) {
    // Depending on your locale, you might want to change these
    const months = [
      "ene",
      "feb",
      "mar",
      "abr",
      "may",
      "jun",
      "jul",
      "ago",
      "sep",
      "oct",
      "nov",
      "dic"
    ];
    return months[month - 1];
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
