class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? gstin;
  final String? city;
  final double currentBalance;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gstin,
    this.city,
    required this.currentBalance,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      gstin: json['gstin'],
      city: json['city'],
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
