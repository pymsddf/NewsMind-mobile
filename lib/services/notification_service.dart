import '../config/api_config.dart';
import 'api_service.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await ApiService.get(ApiConfig.notifications);

    if (response['success'] == true && response['notifications'] != null) {
      return List<Map<String, dynamic>>.from(response['notifications']);
    }
    return [];
  }

  static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    return await ApiService.post(ApiConfig.markNotificationRead, {
      'notificationId': notificationId,
    });
  }

  static Future<Map<String, dynamic>> markAllAsRead() async {
    return await ApiService.post(ApiConfig.markAllNotificationsRead, {});
  }
}
