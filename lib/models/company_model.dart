import 'package:intl/intl.dart';

class Business {
  String idBusiness;
  String name;
  String entity;
  String address;
  String state;
  String city;
  String? profilePictureUrl;
  String country;
  bool isValid;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? joinedAt;
  double averageRating;
  int followers;
  bool isFollowed;
  UserInfo? user;
  Category? category;
  int reviewsCount;

  Business(
      {required this.idBusiness,
      required this.name,
      required this.entity,
      required this.address,
      required this.state,
      required this.city,
      this.profilePictureUrl,
      required this.country,
      required this.isValid,
      required this.createdAt,
      required this.updatedAt,
      this.joinedAt,
      required this.averageRating,
      required this.followers,
      required this.isFollowed,
      this.user,
      this.category,
      required this.reviewsCount});

  String get joinedDateFormatted {
    final DateFormat formatter = DateFormat("MMMM 'de' yyyy", 'es_ES');
    return "Te uniste en ${formatter.format(joinedAt!)}";
  }

  factory Business.fromJson(Map<String, dynamic> json) {
    print(json);
    return Business(
        idBusiness: json['_id_business'],
        name: json['name'],
        entity: json['entity'] ?? '',
        address: json['address'] ?? '',
        state: json['state'],
        city: json['city'],
        profilePictureUrl: json['profile_picture_url'],
        country: json['country'],
        isValid: json['is_valid'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        averageRating:
            double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
        followers: json['followers'] ?? 0,
        isFollowed: json['is_followed'] ?? false,
        user: json['User'] != null ? UserInfo.fromJson(json['User']) : null,
        category: json['Category'] != null
            ? Category.fromJson(json['Category'])
            : null,
        reviewsCount:
            int.tryParse(json['reviewsCount']?.toString() ?? '0') ?? 0,
        joinedAt:
            json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_business': idBusiness,
      'name': name,
      'entity': entity,
      'address': address,
      'state': state,
      'city': city,
      'profile_picture_url': profilePictureUrl,
      'country': country,
      'is_valid': isValid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'average_rating': averageRating,
      'followers': followers,
      'is_followed': isFollowed,
      'User': user?.toJson(),
      'Category': category?.toJson(),
      'reviewsCount': reviewsCount,
      'joinedAt': joinedAt
    };
  }
}

class UserInfo {
  String idUser;
  String name;
  String lastName;

  UserInfo({required this.idUser, required this.name, required this.lastName});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      idUser: json['_id_user'],
      name: json['name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_user': idUser,
      'name': name,
      'last_name': lastName,
    };
  }
}

class Category {
  String idCategory;
  String name;

  Category({required this.idCategory, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      idCategory: json['_id_category'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_category': idCategory,
      'name': name,
    };
  }
}
