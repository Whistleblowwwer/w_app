import 'package:equatable/equatable.dart';
import 'package:w_app/models/review_model.dart';
import 'package:intl/intl.dart';

class Comment extends Equatable {
  final String idComment;
  final String content;
  final bool isValid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String idReview;
  final String? idParent;
  final int likes;
  final int comments;
  final UserData user;
  final bool isLiked;
  final List<Comment>? children;
  final List<String>? images;

  const Comment(
      {required this.idComment,
      required this.content,
      required this.isValid,
      required this.createdAt,
      required this.updatedAt,
      required this.idReview,
      this.idParent,
      required this.comments,
      required this.likes,
      required this.isLiked,
      required this.user,
      this.children,
      this.images});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      idComment: json['_id_comment'],
      content: json['content'],
      isValid: json['is_valid'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      idReview: json['_id_review'] ?? json['Review']['_id_review'] ?? '',
      idParent: json['_id_parent'] ?? '',
      comments: int.tryParse(json['commentsCount']?.toString() ?? '0') ?? 0,
      likes: int.tryParse(json['likesCount']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] ?? false,
      user: json['User'] != null
          ? UserData.fromJson(json['User'])
          : UserData(
              idUser: json['_id_user'],
              name: '',
              lastName: '',
              followed: false),
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
      images: json['Images'] != null ? List<String>.from(json['Images']) : null,
    );
  }

  String get getLikes {
    return likes == 1 ? '$likes me gusta' : '$likes me gusta';
  }

  String get getComments {
    return comments == 1 ? '$comments respuesta' : '$comments respuestas';
  }

  String get timeAgo {
    if (createdAt == null) return 'Fecha desconocida';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 1) {
      // Si la diferencia es mayor a un día, devuelve la fecha en formato día/mes/año.
      return DateFormat('dd/MM/yy').format(createdAt);
    } else if (difference.inHours >= 1) {
      // Si ha pasado al menos una hora, pero menos de un día.
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes >= 1) {
      // Si ha pasado al menos un minuto, pero menos de una hora.
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      // Si ha pasado menos de un minuto.
      return 'Justo ahora';
    }
  }

  Comment copyWith(
      {String? idComment,
      String? content,
      bool? isValid,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? idReview,
      String? idParent,
      String? idUser,
      int? likes,
      int? comments,
      UserData? user,
      bool? isLiked,
      List<Comment>? children,
      List<String>? images}) {
    return Comment(
        idComment: idComment ?? this.idComment,
        content: content ?? this.content,
        isValid: isValid ?? this.isValid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        idReview: idReview ?? this.idReview,
        idParent: idParent ?? this.idParent,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        user: user ?? this.user,
        isLiked: isLiked ?? this.isLiked,
        children: children ?? this.children,
        images: images ?? this.images);
  }

  @override
  List<Object?> get props => [
        idComment,
        content,
        isValid,
        createdAt,
        updatedAt,
        idReview,
        idParent,
        likes,
        isLiked,
        user,
        children,
        images
      ];
}



  // factory Review.fromJson(Map<String, dynamic> json) {
  //   return Review(
  //     idReview: json['_id_comment'] ?? json['_id_review'] ?? '',
  //     content: json['content'],
  //     isValid: json['is_valid'] ?? false,
  //     createdAt:
  //         json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  //     updatedAt: DateTime.parse(json['updatedAt']),
  //     idBusiness: json['_id_business'] ?? '',
  //     idUser: json['_id_user'],
  //     likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
  //     isLiked: json['is_liked'] ?? false,
  //     comments: int.tryParse(json['comments']?.toString() ?? '0') ?? 0,
  //     business: json['Business'] != null
  //         ? BusinessData.fromJson(json['Business'])
  //         : null,
  //     user: UserData.fromJson(json['User']),
  //     children: json['children'] != null
  //         ? (json['children'] as List).map((c) => Comment.fromJson(c)).toList()
  //         : null,
  //   );
  // }
