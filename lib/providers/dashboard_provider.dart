import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';
import '../services/report_service.dart';
import 'auth_provider.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReportService(client);
});

final dashboardMetricsProvider = FutureProvider.autoDispose<DashboardModel>((ref) async {
  final service = ref.watch(reportServiceProvider);
  return service.getDashboardOverview();
});
