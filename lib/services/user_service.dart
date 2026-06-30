import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _historyCacheKey = 'history_cache_v1';
  static const String _historyCacheTimeKey = 'history_cache_time_v1';
  static const Duration _historyCacheTtl = Duration(minutes: 10);

  static Future<UserModel?> getUserData() async {
    try {
      final response = await ApiService.get(ApiConfig.userData);
      if (response['success'] == true && response['userData'] != null) {
        final user = UserModel.fromJson(response['userData']);
        await cacheUser(user);
        return user;
      }
      return await getCachedUser();
    } catch (e) {
      return await getCachedUser();
    }
  }

  static Future<void> cacheUser(UserModel user) async {
    try {
      await SecureTokenStorage.saveUserData(jsonEncode(user.toJson()));
    } catch (e) {
      print('Error caching user: $e');
    }
  }

  static Future<UserModel?> getCachedUser() async {
    try {
      final userDataStr = await SecureTokenStorage.getUserData();
      if (userDataStr != null) {
        return UserModel.fromJson(jsonDecode(userDataStr));
      }
    } catch (e) {
      print('Error getting cached user: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(ApiConfig.updateProfile, data);
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await ApiService.post(ApiConfig.updateSecurity, {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateSecurity(String setting, dynamic value) async {
    try {
      final response = await ApiService.post(ApiConfig.updateSecurity, {
        setting: value,
      });
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getHistory({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await getCachedHistory();
        if (cached.isNotEmpty) return cached;
      }
      final response = await ApiService.get(ApiConfig.history);
      if (response['success'] == true && response['history'] != null) {
        final history = (response['history'] as List).cast<dynamic>();
        await _setCachedHistory(history);
        return history;
      }
      return [];
    } catch (e) {
      return await getCachedHistory();
    }
  }

  static Future<List<dynamic>> getCachedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAt = prefs.getInt(_historyCacheTimeKey);
      final raw = prefs.getString(_historyCacheKey);
      if (cachedAt == null || raw == null || raw.isEmpty) return [];

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - cachedAt > _historyCacheTtl.inMilliseconds) return [];

      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.cast<dynamic>();
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> _setCachedHistory(List<dynamic> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyCacheKey, jsonEncode(history));
      await prefs.setInt(_historyCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  static Future<void> _clearHistoryCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyCacheKey);
      await prefs.remove(_historyCacheTimeKey);
    } catch (_) {}
  }

  static Future<bool> clearHistory() async {
    try {
      final response = await ApiService.delete(ApiConfig.clearHistory);
      if (response['success'] == true) {
        await _clearHistoryCache();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteHistoryItem(String id) async {
    try {
      final response = await ApiService.delete('${ApiConfig.deleteHistory}/$id');
      if (response['success'] == true) {
        final cached = await getCachedHistory();
        if (cached.isNotEmpty) {
          final updated = cached.where((item) {
            if (item is! Map) return true;
            final itemId = (item['id'] ?? item['_id'])?.toString();
            return itemId != id;
          }).toList();
          await _setCachedHistory(updated);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> addToHistory({
    required String type,
    required String title,
    required String query,
    Map<String, dynamic>? result,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final payloadData = <String, dynamic>{
        if (query.isNotEmpty) 'query': query,
        ...(result ?? {}),
        ...(metadata ?? {}),
      };

      final response = await ApiService.post(ApiConfig.history, {
        'type': type,
        'title': title,
        'preview': query.length > 120 ? '${query.substring(0, 117)}...' : query,
        'data': payloadData,
      });

      if (response['success'] == true) {
        // Refresh cache in background after a successful write.
        await getHistory(forceRefresh: true);
      }

      return response;
    } catch (e) {
      print('Error adding to history: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
