class Business {
  final String idBusiness;
  final String name;
  final String address;
  final String state;
  final String city;
  final String? profilePictureUrl;
  final String country;
  final bool? isValid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String idUser;

  Business({
    required this.idBusiness,
    required this.name,
    required this.address,
    required this.state,
    required this.city,
    this.profilePictureUrl,
    required this.country,
    required this.isValid,
    required this.createdAt,
    required this.updatedAt,
    required this.idUser,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      idBusiness: json['_id_business'],
      name: json['name'],
      address: json['address'],
      state: json['state'],
      city: json['city'],
      profilePictureUrl: json['profile_picture_url'],
      country: json['country'],
      isValid: json['is_valid'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      idUser: json['_id_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'address': address,
      'state': state,
      'city': city,
    };
  }
}
