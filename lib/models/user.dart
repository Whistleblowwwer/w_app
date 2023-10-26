class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // Método para convertir un objeto JSON en una instancia de User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id_user'],
      name: json['name'],
      email: json['email'],
    );
  }
}
