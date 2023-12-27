import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String idUser;
  final String name;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? profilePictureUrl;
  final String? role;
  final bool? isValid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int followings;
  final int followers;
  final String? userName;
  final bool? isFollowed;

  const User(
      {required this.idUser,
      required this.name,
      required this.lastName,
      this.email,
      this.phoneNumber,
      this.birthDate,
      this.gender,
      this.profilePictureUrl,
      this.role,
      this.isValid,
      this.createdAt,
      this.updatedAt,
      required this.followers,
      required this.followings,
      this.userName,
      this.isFollowed});

  String getFormattedCreationDate() {
    if (createdAt == null) {
      return 'Fecha de creación no disponible';
    }

    // Formatear la fecha
    return 'Se creó el ${createdAt!.day} de ${_getMonthName(createdAt!.month)} del ${createdAt!.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return monthNames[month - 1];
  }

  String get nameFirstLetter {
    return (name[0] + lastName[0]).toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        idUser: json['_id_user'],
        name: json['name'],
        lastName: json['last_name'],
        email: json['email'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        birthDate: json['birth_date'] != null
            ? DateTime.parse(json['birth_date'])
            : null,
        gender: json['gender'],
        profilePictureUrl: json['profile_picture_url'],
        role: json['role'],
        isValid: json['is_valid'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        followers: json['followers'] ?? 0,
        followings: json['followings'] ?? 0,
        userName: json['nick_name'] ?? '',
        isFollowed: json['is_followed'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'profile_picture_url': profilePictureUrl,
      'role': role,
      'is_valid': isValid,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'followers': followers,
      'followings': followings,
      'is_followed': isFollowed
    };
  }

  User copyWith({
    String? idUser,
    String? name,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? profilePictureUrl,
    String? role,
    bool? isValid,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? followings,
    int? followers,
    String? userName,
    bool? isFollowed,
  }) {
    return User(
      idUser: idUser ?? this.idUser,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      isValid: isValid ?? this.isValid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followings: followings ?? this.followings,
      followers: followers ?? this.followers,
      userName: userName ?? this.userName,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  @override
  List<Object?> get props => [
        idUser,
        name,
        lastName,
        email,
        phoneNumber,
        birthDate,
        gender,
        profilePictureUrl,
        role,
        isValid,
        createdAt,
        updatedAt,
        followings,
        followers,
        userName,
        isFollowed
      ];

  // Método stringify para una representación en string más detallada
  @override
  bool get stringify => true;
}
