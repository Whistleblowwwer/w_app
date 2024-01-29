class Attorney {
  final String idBroker;
  final String name;
  final String lastName;
  final String ine;
  final String phoneNumber;
  final String email;
  final String type;
  final bool isValid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profilePictureUrl;

  Attorney(
      {required this.idBroker,
      required this.name,
      required this.lastName,
      required this.ine,
      required this.phoneNumber,
      required this.email,
      required this.type,
      required this.isValid,
      required this.createdAt,
      required this.updatedAt,
      required this.profilePictureUrl});

  factory Attorney.fromJson(Map<String, dynamic> json) {
    return Attorney(
      idBroker: json['_id_broker'],
      name: json['name'],
      lastName: json['last_name'],
      ine: json['INE'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      type: json['type'],
      isValid: json['is_valid'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id_broker': idBroker,
      'name': name,
      'last_name': lastName,
      'INE': ine,
      'phone_number': phoneNumber,
      'email': email,
      'type': type,
      'is_valid': isValid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profile_picture_url': profilePictureUrl
    };
  }
}
