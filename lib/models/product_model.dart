class ProductModel {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final double sellingPrice;
  final double purchasePrice;
  final double gstRate;
  final double currentStock;
  final double minStockAlert;
  final String unit;

  ProductModel({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.gstRate,
    required this.currentStock,
    required this.minStockAlert,
    required this.unit,
  });

  bool get isLowStock => currentStock <= minStockAlert;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'],
      barcode: json['barcode'],
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 0.0,
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      minStockAlert: (json['minStockAlert'] as num?)?.toDouble() ?? 5.0,
      unit: json['unit'] ?? 'PCS',
    );
  }
}
