class Attorney {
  final String idBroker;
  final String name;
  final String lastName;
  final String ine;
  final String phoneNumber;
  final String email;
  final String type;
  final bool isValid;
  final String? imgUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attorney({
    required this.idBroker,
    required this.name,
    required this.lastName,
    required this.ine,
    required this.phoneNumber,
    required this.email,
    required this.type,
    required this.isValid,
    this.imgUrl,
    required this.createdAt,
    required this.updatedAt,
  });

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
      imgUrl: json['img_url'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
    };
  }
}
