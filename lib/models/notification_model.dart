class UserNotification {
  final String idNotification;
  final String idUserSender;
  final String idUserReceiver;
  final String subject;
  final String content;
  final bool isValid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final Target target;

  UserNotification({
    required this.idNotification,
    required this.idUserSender,
    required this.idUserReceiver,
    required this.subject,
    required this.content,
    required this.isValid,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.target,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id_notification': idNotification,
      '_id_user_sender': idUserSender,
      '_id_user_receiver': idUserReceiver,
      'subject': subject,
      'content': content,
      'is_valid': isValid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type,
      'Target': target.toJson(),
    };
  }

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      idNotification: json['_id_notification'],
      idUserSender: json['_id_user_sender'],
      idUserReceiver: json['_id_user_receiver'],
      subject: json['subject'],
      content: json['content'],
      isValid: json['is_valid'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      type: json['type'],
      target: Target.fromJson(json['Target']),
    );
  }
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()} sem';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min';
    } else {
      return 'Ahora';
    }
  }

  UserNotification copyWith({
    String? idNotification,
    String? idUserSender,
    String? idUserReceiver,
    String? subject,
    String? content,
    bool? isValid,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    Target? target,
  }) {
    return UserNotification(
      idNotification: idNotification ?? this.idNotification,
      idUserSender: idUserSender ?? this.idUserSender,
      idUserReceiver: idUserReceiver ?? this.idUserReceiver,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      isValid: isValid ?? this.isValid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      target: target ?? this.target,
    );
  }
}

class Target {
  final String id;
  final String name;
  final String lastName;
  final String nickName;
  final bool? isFollowed;

  Target({
    required this.id,
    required this.name,
    required this.lastName,
    required this.nickName,
    required this.isFollowed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'nick_name': nickName,
      'is_followed': isFollowed,
    };
  }

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      id: json['id'],
      name: json['name'],
      lastName: json['last_name'],
      nickName: json['nick_name'],
      isFollowed: json['is_followed'],
    );
  }
  Target copyWith({
    String? id,
    String? name,
    String? lastName,
    String? nickName,
    bool? isFollowed,
  }) {
    return Target(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      nickName: nickName ?? this.nickName,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
