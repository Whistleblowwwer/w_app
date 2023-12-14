import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:w_app/models/comment_model.dart';

class Review extends Equatable {
  final String idReview;
  final String content;
  final bool? isValid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String idBusiness;
  final String idUser;
  final int likes;
  final int comments;
  final BusinessData? business;
  final UserData user;
  final bool isLiked;
  final double rating;
  final List<Comment>? children;
  final List<String>? images;

  const Review(
      {required this.idReview,
      required this.content,
      required this.isValid,
      required this.createdAt,
      required this.updatedAt,
      required this.idBusiness,
      required this.idUser,
      required this.likes,
      required this.comments,
      required this.business,
      required this.user,
      required this.isLiked,
      required this.rating,
      this.children,
      this.images});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idReview: json['_id_review'],
      content: json['content'],
      isValid: json['is_valid'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      idBusiness: json['_id_business'],
      idUser: json['_id_user'],
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] ?? false,
      comments: int.tryParse(json['comments']?.toString() ?? '0') ?? 0,
      business: BusinessData.fromJson(json['Business']),
      user: UserData.fromJson(json['User']),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  // void toggleLike() {
  //   isLiked = !isLiked;
  //   likes += isLiked ? 1 : -1;
  // }

  String get getLikes {
    return likes == 1 ? '$likes Me gusta' : '$likes Me gustas';
  }

  String get timeAgo {
    if (createdAt == null) return 'Fecha desconocida';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 90) {
      // Si la diferencia es mayor a 90 días (aproximadamente 3 meses), se muestra la fecha.
      return DateFormat('dd/MM/yy').format(createdAt!);
    } else if (difference.inDays >= 30) {
      // Si ha pasado al menos un mes, pero menos de tres meses.
      final months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays >= 7) {
      // Si ha pasado al menos una semana, pero menos de un mes.
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays >= 1) {
      // Si ha pasado al menos un día, pero menos de una semana.
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours >= 1) {
      // Si ha pasado al menos una hora, pero menos de un día.
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes >= 1) {
      // Si ha pasado al menos un minuto, pero menos de una hora.
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'min' : 'min'}';
    } else {
      // Si ha pasado menos de un minuto.
      return 'Justo ahora';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_review': idReview,
      'content': content,
      'is_valid': isValid,
      'created_at': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '_id_business': idBusiness,
      '_id_user': idUser,
      'likes': likes,
      'comments': comments,
      'Business': business?.toJson() ?? '',
      'User': user.toJson(),
    };
  }

  Review copyWith(
      {String? idReview,
      String? content,
      bool? isValid,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? idBusiness,
      String? idUser,
      int? likes,
      int? comments,
      BusinessData? business,
      UserData? user,
      bool? isLiked,
      double? rating,
      List<Comment>? children,
      List<String>? images}) {
    return Review(
        idReview: idReview ?? this.idReview,
        content: content ?? this.content,
        isValid: isValid ?? this.isValid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        idBusiness: idBusiness ?? this.idBusiness,
        idUser: idUser ?? this.idUser,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        business: business ?? this.business,
        user: user ?? this.user,
        isLiked: isLiked ?? this.isLiked,
        rating: rating ?? this.rating,
        children: children ?? this.children,
        images: images ?? this.images);
  }

  @override
  List<Object?> get props => [
        idReview,
        content,
        isValid,
        createdAt,
        updatedAt,
        idBusiness,
        idUser,
        likes,
        comments,
        business,
        user,
        isLiked,
        rating,
        children,
        images
      ];
}

class BusinessData extends Equatable {
  final String idBusiness;
  final String name;
  final String entity;
  final double rating;
  final bool followed;

  BusinessData({
    required this.idBusiness,
    required this.name,
    required this.entity,
    required this.rating,
    required this.followed,
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) {
    return BusinessData(
        idBusiness: json['_id_business'] ?? '',
        name: json['name'] ?? '',
        entity: json['entity'] ?? '',
        followed: json['is_followed'] ?? false,
        rating: json['avarage_rating'] ?? 0.0);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_business': idBusiness,
      'name': name,
      'entity': entity,
      'is_followed': followed,
    };
  }

  BusinessData copyWith(
      {String? idBusiness,
      String? name,
      String? entity,
      bool? followed,
      double? rating}) {
    return BusinessData(
        idBusiness: idBusiness ?? this.idBusiness,
        name: name ?? this.name,
        entity: entity ?? this.entity,
        followed: followed ?? this.followed,
        rating: rating ?? this.rating);
  }

  @override
  List<Object?> get props => [idBusiness, name, entity, followed, rating];
}

class UserData extends Equatable {
  final String idUser;
  final String? userName;
  final String name;
  final String lastName;
  final bool followed;

  UserData(
      {required this.idUser,
      required this.name,
      required this.lastName,
      required this.followed,
      this.userName});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        idUser: json['_id_user'] ?? '',
        name: json['name'],
        lastName: json['last_name'],
        followed: json['is_followed'] ?? false,
        userName: json['nick_name'] ?? 'Usuario');
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_user': idUser,
      'name': name,
      'last_name': lastName,
      'is_followed': followed,
      'nick_name': userName
    };
  }

  UserData copyWith({
    String? idUser,
    String? name,
    String? lastName,
    bool? followed,
    String? userName,
  }) {
    return UserData(
        idUser: idUser ?? this.idUser,
        name: name ?? this.name,
        lastName: lastName ?? this.lastName,
        followed: followed ?? this.followed,
        userName: userName ?? this.userName);
  }

  @override
  List<Object?> get props => [idUser, name, lastName, followed, userName];
}
