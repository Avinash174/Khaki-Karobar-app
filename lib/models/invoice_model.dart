class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String customerPhone;
  final DateTime invoiceDate;
  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
  final String status;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.invoiceDate,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceAmount,
    required this.status,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      customerName: json['customer']?['name'] ?? 'Walk-in Customer',
      customerPhone: json['customer']?['phone'] ?? '',
      invoiceDate: json['invoiceDate'] != null ? DateTime.parse(json['invoiceDate']) : DateTime.now(),
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ISSUED',
    );
  }
}
