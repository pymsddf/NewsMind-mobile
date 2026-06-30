import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import '../config/api_config.dart';
import '../utils/error_text.dart';

/// Secure token storage using platform-specific secure storage
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain
class SecureTokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    final secure = await _storage.read(key: _tokenKey);
    if (secure != null && secure.isNotEmpty) return secure;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save refresh token securely
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    final secure = await _storage.read(key: _refreshTokenKey);
    if (secure != null && secure.isNotEmpty) return secure;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Save user data securely
  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  /// Get stored user data
  static Future<String?> getUserData() async {
    final secure = await _storage.read(key: _userDataKey);
    if (secure != null && secure.isNotEmpty) return secure;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  /// Clear all secure tokens (logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }

  /// Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

class ApiService {
  static String? _token;
  static String? _deviceId;

  static Future<void> init() async {
    // Load token from secure storage
    _token = await SecureTokenStorage.getToken();
    
    // Generate or retrieve device ID for security headers
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    if (_deviceId == null) {
      _deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', _deviceId!);
    }
  }

  static String? get token => _token;
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await SecureTokenStorage.getToken();
    return _token;
  }


  static Future<void> setToken(String token) async {
    _token = token;
    await SecureTokenStorage.saveToken(token);
  }

  static Future<void> clearToken() async {
    _token = null;
    await SecureTokenStorage.clearTokens();
  }

  /// Security headers with device identification
  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Version': '1.0.0',
      'X-Platform': kIsWeb ? 'web' : Platform.operatingSystem,
    };
    
    if (_deviceId != null) {
      headers['X-Device-Id'] = _deviceId!;
    }
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  /// Optional SSL Pinning check for production environments
  static Future<void> _checkSSLPinning(String url) async {
    if (kIsWeb) return; // SSL Pinning is not supported on Web (browsers manage SSL)
    if (!url.startsWith('https')) return;
    
    try {
      // In a real app, replace with actual fingerprints of your backend
      List<String> allowedFingerprints = [
        "your_sha256_fingerprint_here",
      ];
      
      // Bypass SSL pinning if it is configured with the placeholder fingerprint
      if (allowedFingerprints.contains("your_sha256_fingerprint_here")) {
        return;
      }
      
      await HttpCertificatePinning.check(
        serverURL: url,
        headerHttp: _headers,
        sha: SHA.SHA256,
        allowedSHAFingerprints: allowedFingerprints,
        timeout: 50,
      );
    } catch (e) {
      throw Exception('SSL Certificate Pinning Failed: potential MITM attack');
    }
  }

  /// Request wrapper with Retry Logic
  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request, {
    int maxRetries = 3,
  }) async {
    int retries = 0;
    while (true) {
      try {
        final response = await request();
        if (response.statusCode >= 500 && retries < maxRetries) {
          retries++;
          await Future.delayed(Duration(milliseconds: 500 * retries));
          continue;
        }
        return response;
      } catch (e) {
        if (retries < maxRetries) {
          retries++;
          await Future.delayed(Duration(milliseconds: 500 * retries));
          continue;
        }
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      await _checkSSLPinning(url);
      
      final response = await _requestWithRetry(() => http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(Duration(seconds: 30)));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      await _checkSSLPinning(url);
      
      final response = await _requestWithRetry(() => http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 60)));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      await _checkSSLPinning(url);

      final response = await _requestWithRetry(() => http
          .put(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 30)));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      await _checkSSLPinning(url);

      final response = await _requestWithRetry(() => http
          .delete(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(Duration(seconds: 30)));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': friendlyError(e)};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');
      
      // Check if response body is HTML (server error page)
      final body = response.body.trim();
      if (body.startsWith('<!') || body.startsWith('<html')) {
        return {
          'success': false,
          'message': 'Server returned an error (${response.statusCode}). Please try again.',
        };
      }

      if (response.statusCode == 429) {
        return {
          'success': false,
          'message': 'Usage limit reached',
          'upgradeRequired': true,
        };
      }

      if (response.statusCode == 401) {
        // Token expired or invalid - clear secure storage
        clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'authRequired': true,
        };
      }

      final data = jsonDecode(body);

      if (data is Map<String, dynamic>) {
        // Usage-limit responses arrive as 403 with `limitExceeded`. Normalize to
        // `upgradeRequired` so every caller can detect it uniformly (and show
        // the upgrade dialog) regardless of status code.
        if (data['limitExceeded'] == true) data['upgradeRequired'] = true;
        return data;
      }
      return {'success': true, 'data': data};
    } catch (e) {
      print('Failed to parse response: $e');
      print('Raw body: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      return {
        'success': false,
        'message': 'Server error (${response.statusCode}). Please try again.',
      };
    }
  }
}
