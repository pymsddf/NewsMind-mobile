import 'package:newsmind_mobile/config/api_config.dart';
import 'package:newsmind_mobile/services/api_service.dart';

class HistoryService {
  static Future<bool> submitFeedback(String historyId, String feedback) async {
    try {
      final endpoint = '${ApiConfig.submitFeedback}/$historyId';
      final response = await ApiService.post(endpoint, {
        'feedback': feedback,
      });
      return response['success'] == true;
    } catch (e) {
      print('Submit feedback error: $e');
      return false;
    }
  }
}
