import '../models/dashboard_summary.dart';
import 'api_client.dart';
import 'auth_service.dart';

class DashboardService {
  static Future<DashboardSummary> fetchSummary() async {
    final token = await AuthService.requireToken();
    final response = await ApiClient.get(
      'dashboard',
      headers: AuthService.bearerHeaders(token),
    );

    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    final data = body['data'];

    if (data is! Map) {
      throw const ApiException('The dashboard response is incomplete.');
    }

    return DashboardSummary.fromJson(Map<String, dynamic>.from(data));
  }
}
