class User {
  final String idUser;
  final String name;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? profilePictureUrl;
  final String? role;
  final bool? isValid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int followings;
  final int followers;

  User(
      {required this.idUser,
      required this.name,
      required this.lastName,
      required this.email,
      required this.phoneNumber,
      this.birthDate,
      this.gender,
      this.profilePictureUrl,
      this.role,
      this.isValid,
      this.createdAt,
      this.updatedAt,
      required this.followers,
      required this.followings});

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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['_id_user'],
      name: json['name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      gender: json['gender'],
      profilePictureUrl: json['profile_picture_url'],
      role: json['role'],
      isValid: json['is_valid'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      followers: json['followers'] ?? 0,
      followings: json['followings'] ?? 0,
    );
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
      'followings': followings
    };
  }
}
