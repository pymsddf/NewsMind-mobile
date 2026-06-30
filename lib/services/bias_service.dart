import '../config/api_config.dart';
import '../models/bias_model.dart';
import 'api_service.dart';

class BiasService {
  static Future<BiasModel> analyzeBias({
    String? text,
    String? url,
    String? queryHint,
  }) async {
    final body = <String, dynamic>{};
    if (text != null && text.isNotEmpty) body['text'] = text;
    if (url != null && url.isNotEmpty) body['url'] = url;
    if (queryHint != null && queryHint.isNotEmpty) body['query_hint'] = queryHint;

    final response = await ApiService.post(ApiConfig.analyzeBias, body);

    if (response['upgradeRequired'] == true) {
      throw Exception('USAGE_LIMIT_EXCEEDED');
    }

    if (response['detail'] != null) {
      throw Exception(response['detail']);
    }

    return BiasModel.fromJson(response);
  }
}
