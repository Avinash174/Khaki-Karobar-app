class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'USER',
    );
  }
}

class BusinessModel {
  final String id;
  final String name;
  final String? gstin;
  final String phone;
  final String? city;

  BusinessModel({
    required this.id,
    required this.name,
    this.gstin,
    required this.phone,
    this.city,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gstin: json['gstin'],
      phone: json['phone'] ?? '',
      city: json['city'],
    );
  }
}
