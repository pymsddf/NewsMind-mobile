import '../config/api_config.dart';
import '../models/verification_model.dart';
import 'api_service.dart';

class VerificationService {
  static Future<VerificationModel> verifyContent(String article) async {
    final response = await ApiService.post(ApiConfig.verifyFact, {
      'article': article,
    });

    if (response['upgradeRequired'] == true) {
      throw Exception('USAGE_LIMIT_EXCEEDED');
    }

    if (response['success'] == false) {
      throw Exception(response['message'] ?? 'Verification failed');
    }

    return VerificationModel.fromJson(response);
  }
}
