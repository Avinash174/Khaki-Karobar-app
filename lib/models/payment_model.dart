class PaymentModel {
  final String id;
  final String type; // 'IN' | 'OUT'
  final String partyType; // 'CUSTOMER' | 'SUPPLIER'
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String partyName;

  PaymentModel({
    required this.id,
    required this.type,
    required this.partyType,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
    required this.partyName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    String party = 'Unknown';
    if (json['customer'] != null && json['customer']['name'] != null) {
      party = json['customer']['name'];
    } else if (json['supplier'] != null && json['supplier']['name'] != null) {
      party = json['supplier']['name'];
    }

    return PaymentModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'IN',
      partyType: json['partyType'] ?? 'CUSTOMER',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : DateTime.now(),
      referenceNumber: json['referenceNumber'],
      notes: json['notes'],
      partyName: party,
    );
  }
}
