class PurchaseModel {
  final String id;
  final String purchaseNumber;
  final String supplierName;
  final String supplierPhone;
  final DateTime purchaseDate;
  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
  final String status;

  PurchaseModel({
    required this.id,
    required this.purchaseNumber,
    required this.supplierName,
    required this.supplierPhone,
    required this.purchaseDate,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceAmount,
    required this.status,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] ?? '',
      purchaseNumber: json['purchaseNumber'] ?? '',
      supplierName: json['supplier']?['name'] ?? 'Vendor / Supplier',
      supplierPhone: json['supplier']?['phone'] ?? '',
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate']) : DateTime.now(),
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'RECEIVED',
    );
  }
}
