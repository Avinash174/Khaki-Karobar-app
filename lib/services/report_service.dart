import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class ReportService {
  final ApiClient _client;

  ReportService(this._client);

  Future<DashboardModel> getDashboardOverview() async {
    final response = await _client.dio.get('/reports/dashboard');

    if (response.data['success'] == true) {
      return DashboardModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load dashboard metrics');
    }
  }
}
