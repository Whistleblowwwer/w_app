import 'dart:convert';

class Review {
  final String idReview;
  final String content;
  final bool? isValid;
  final DateTime? createdAt;
  final String idBusiness;
  final String nameBusiness;
  final String entity;
  final String namePerson;
  final String lastName;
  final String idUser;
  final List? comments;

  Review(
      {required this.idReview,
      required this.content,
      this.isValid,
      this.createdAt,
      required this.idBusiness,
      required this.idUser,
      required this.nameBusiness,
      required this.namePerson,
      required this.entity,
      required this.lastName,
      this.comments});

  factory Review.fromJson(Map<String, dynamic> jsonReponse) {
    return Review(
        idReview: jsonReponse['_id_review'],
        content: jsonReponse['content'],
        isValid: jsonReponse['isValid'],
        createdAt: jsonReponse['createdAt'] != null
            ? DateTime.parse(jsonReponse['createdAt'])
            : null,
        idBusiness: jsonReponse['business']['_id_business'] ?? '',
        nameBusiness: jsonReponse['business']['name'] ?? '',
        entity: jsonReponse['user']['entity'] ?? '',
        idUser: jsonReponse['user']['_id_user'] ?? '',
        namePerson: jsonReponse['user']['name'] ?? '',
        lastName: jsonReponse['user']['last_name'] ?? '',
        comments: jsonReponse['comments'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'is_valid': isValid,
      'created_at': createdAt?.toIso8601String(),
      'id_business': idBusiness,
      'id_user': idUser,
      '_name_business': nameBusiness,
      '_name_user': namePerson
    };
  }
}

class Comment {
  final String author;
  final String content;
  final List<Comment>? children;

  Comment({required this.author, required this.content, this.children});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      author: json['author'],
      content: json['content'],
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
    );
  }
}
