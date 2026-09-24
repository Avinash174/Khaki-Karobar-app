class DashboardModel {
  final double todaySales;
  final double todayPurchase;
  final double totalReceivables;
  final double totalPayables;
  final double cashBalance;
  final int lowStockCount;

  DashboardModel({
    required this.todaySales,
    required this.todayPurchase,
    required this.totalReceivables,
    required this.totalPayables,
    required this.cashBalance,
    required this.lowStockCount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      todaySales: (json['todaySales'] as num?)?.toDouble() ?? 0.0,
      todayPurchase: (json['todayPurchase'] as num?)?.toDouble() ?? 0.0,
      totalReceivables: (json['totalReceivables'] as num?)?.toDouble() ?? 0.0,
      totalPayables: (json['totalPayables'] as num?)?.toDouble() ?? 0.0,
      cashBalance: (json['cashBalance'] as num?)?.toDouble() ?? 0.0,
      lowStockCount: json['lowStockCount'] ?? 0,
    );
  }
}
