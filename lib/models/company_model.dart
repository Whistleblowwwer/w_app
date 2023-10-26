class Company {
  final String name;
  final String parentCompany;

  Company({required this.name, required this.parentCompany});

  // Método fromJson
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      parentCompany: json['parentCompany'],
    );
  }
}
