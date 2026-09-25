class SupplierModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? contactPerson;
  final String? gstin;
  final String? city;
  final String? address;
  final double currentBalance;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.contactPerson,
    this.gstin,
    this.city,
    this.address,
    required this.currentBalance,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      contactPerson: json['contactPerson'],
      gstin: json['gstin'],
      city: json['city'],
      address: json['address'],
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
