/// Mock API Service for Flutter Testing
/// Simulates API responses without making real network calls
library mock_api_service;

class MockApiService {
  final Map<String, dynamic> _responses = {};
  final List<Map<String, dynamic>> _requests = [];
  bool _isOffline = false;
  Duration _simulatedDelay = const Duration(milliseconds: 100);

  /// Set a mock response for a specific endpoint
  void setResponse(String endpoint, Map<String, dynamic> response) {
    _responses[endpoint] = response;
  }

  /// Set multiple responses at once
  void setResponses(Map<String, Map<String, dynamic>> responses) {
    _responses.addAll(responses);
  }

  /// Set simulated network delay
  void setDelay(Duration delay) {
    _simulatedDelay = delay;
  }

  /// Simulate offline mode
  void setOffline(bool offline) {
    _isOffline = offline;
  }

  /// GET request simulation
  Future<Map<String, dynamic>> get(String endpoint) async {
    _requests.add({
      'method': 'GET',
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_isOffline) {
      return {
        'success': false,
        'message': 'No internet connection',
        'offline': true,
      };
    }

    await Future.delayed(_simulatedDelay);

    if (_responses.containsKey(endpoint)) {
      return _responses[endpoint]!;
    }

    // Default responses for common endpoints
    if (endpoint == '/api/user/profile') {
      return _defaultProfileResponse();
    }

    if (endpoint.startsWith('/api/user/usage')) {
      return _defaultUsageResponse();
    }

    return {'success': true, 'data': []};
  }

  /// POST request simulation
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    _requests.add({
      'method': 'POST',
      'endpoint': endpoint,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_isOffline) {
      return {
        'success': false,
        'message': 'No internet connection',
        'offline': true,
      };
    }

    await Future.delayed(_simulatedDelay);

    // Auth endpoints
    if (endpoint == '/api/auth/login') {
      return _handleLogin(body);
    }

    if (endpoint == '/api/auth/register') {
      return _handleRegister(body);
    }

    if (endpoint == '/api/auth/send-reset-otp') {
      return {'success': true, 'message': 'OTP sent to your email'};
    }

    if (endpoint == '/api/auth/reset-password') {
      return {'success': true, 'message': 'Password reset successfully'};
    }

    // AI endpoints
    if (endpoint == '/api/agents/news') {
      return _handleNewsGeneration(body);
    }

    if (endpoint == '/api/agents/verify') {
      return _handleVerification(body);
    }

    if (endpoint == '/api/agents/bias') {
      return _handleBiasDetection(body);
    }

    // Payment endpoints
    if (endpoint == '/api/payment/create-checkout-session') {
      return _handleCheckoutSession(body);
    }

    if (_responses.containsKey(endpoint)) {
      return _responses[endpoint]!;
    }

    return {'success': true};
  }

  /// PUT request simulation
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    _requests.add({
      'method': 'PUT',
      'endpoint': endpoint,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_isOffline) {
      return {
        'success': false,
        'message': 'No internet connection',
        'offline': true,
      };
    }

    await Future.delayed(_simulatedDelay);

    if (endpoint == '/api/user/profile') {
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': {..._defaultProfileResponse()['user'], ...body},
      };
    }

    if (_responses.containsKey(endpoint)) {
      return _responses[endpoint]!;
    }

    return {'success': true};
  }

  /// DELETE request simulation
  Future<Map<String, dynamic>> delete(String endpoint) async {
    _requests.add({
      'method': 'DELETE',
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_isOffline) {
      return {
        'success': false,
        'message': 'No internet connection',
        'offline': true,
      };
    }

    await Future.delayed(_simulatedDelay);

    if (_responses.containsKey(endpoint)) {
      return _responses[endpoint]!;
    }

    return {'success': true, 'message': 'Deleted successfully'};
  }

  // Handler methods

  Map<String, dynamic> _handleLogin(Map<String, dynamic> body) {
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return {'success': false, 'message': 'Email and password required'};
    }

    // Simulate successful login
    if (email.contains('@') && password.length >= 6) {
      return {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'user_123',
          'name': 'Test User',
          'email': email,
          'role': 'Reporter',
          'pro': false,
        },
      };
    }

    return {'success': false, 'message': 'Invalid credentials'};
  }

  Map<String, dynamic> _handleRegister(Map<String, dynamic> body) {
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final name = body['name'] as String?;

    if (email == null || password == null || name == null) {
      return {'success': false, 'message': 'All fields are required'};
    }

    if (!email.contains('@')) {
      return {'success': false, 'message': 'Invalid email format'};
    }

    if (password.length < 6) {
      return {'success': false, 'message': 'Password too short'};
    }

    return {'success': true, 'message': 'Registration successful'};
  }

  Map<String, dynamic> _handleNewsGeneration(Map<String, dynamic> body) {
    final topic = body['topic'] as String?;

    if (topic == null || topic.isEmpty) {
      return {'success': false, 'message': 'Topic is required'};
    }

    return {
      'success': true,
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': topic,
      'content': '''# $topic

**By NewsMind AI Reporter**

This is a mock generated article about $topic for testing purposes.

## Background

The topic of $topic has been gaining attention recently.

## Key Points

1. Important aspect of $topic
2. Another key consideration
3. Critical background information

## Conclusion

Further developments are expected.

*This article was generated using AI for testing.*''',
      'wordCount': 100,
      'status': 'draft',
    };
  }

  Map<String, dynamic> _handleVerification(Map<String, dynamic> body) {
    final article = body['article'] as String?;

    if (article == null || article.isEmpty) {
      return {'success': false, 'message': 'Article content is required'};
    }

    return {
      'success': true,
      'verdict': 'TRUE',
      'confidence': 8,
      'credibilityScore': 75,
      'summary': 'Mock verification result for testing purposes.',
      'keyFindings': [
        'Claim appears to be factually accurate',
        'Multiple sources support the assertion',
        'No significant contradictions found',
      ],
      'evidence': [
        {
          'title': 'Reuters Article',
          'url': 'https://reuters.com/example',
          'reliability': 90,
        },
        {
          'title': 'BBC News',
          'url': 'https://bbc.com/example',
          'reliability': 88,
        },
      ],
    };
  }

  Map<String, dynamic> _handleBiasDetection(Map<String, dynamic> body) {
    final text = body['text'] as String?;

    if (text == null || text.isEmpty) {
      return {'success': false, 'message': 'Text is required'};
    }

    return {
      'success': true,
      'overallScore': 45,
      'verdict': 'MODERATE',
      'confidence': 7,
      'categories': {
        'political': {'score': 30, 'label': 'LOW'},
        'sensationalism': {'score': 50, 'label': 'MODERATE'},
        'factual': {'score': 75, 'label': 'HIGH'},
        'emotional': {'score': 40, 'label': 'LOW'},
      },
      'summary': 'Mock bias analysis for testing.',
    };
  }

  Map<String, dynamic> _handleCheckoutSession(Map<String, dynamic> body) {
    final planId = body['planId'] as String?;

    return {
      'success': true,
      'sessionId': 'cs_mock_${DateTime.now().millisecondsSinceEpoch}',
      'url': 'https://checkout.stripe.com/mock-session',
      'planId': planId ?? 'pro_monthly',
    };
  }

  Map<String, dynamic> _defaultProfileResponse() {
    return {
      'success': true,
      'user': {
        'id': 'user_123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'Reporter',
        'pro': false,
        'isAccountVerified': true,
        'createdAt': '2026-01-01T00:00:00Z',
      },
    };
  }

  Map<String, dynamic> _defaultUsageResponse() {
    return {
      'success': true,
      'usage': {
        'newsGenerations': {'used': 3, 'limit': 5},
        'verifications': {'used': 5, 'limit': 10},
        'biasDetections': {'used': 2, 'limit': 10},
      },
    };
  }

  // Test helper methods

  /// Get all recorded requests
  List<Map<String, dynamic>> get requests => List.unmodifiable(_requests);

  /// Check if a specific request was made
  bool wasCalled(String method, String endpoint) {
    return _requests.any(
      (r) => r['method'] == method && r['endpoint'] == endpoint,
    );
  }

  /// Get request count for an endpoint
  int getRequestCount(String method, String endpoint) {
    return _requests
        .where((r) => r['method'] == method && r['endpoint'] == endpoint)
        .length;
  }

  /// Get the last request made
  Map<String, dynamic>? get lastRequest =>
      _requests.isNotEmpty ? _requests.last : null;

  /// Get request body for a specific request
  Map<String, dynamic>? getRequestBody(String method, String endpoint) {
    final request = _requests.firstWhere(
      (r) => r['method'] == method && r['endpoint'] == endpoint,
      orElse: () => <String, dynamic>{},
    );
    return request['body'] as Map<String, dynamic>?;
  }

  /// Clear all recorded requests and responses
  void clear() {
    _responses.clear();
    _requests.clear();
    _isOffline = false;
    _simulatedDelay = const Duration(milliseconds: 100);
  }

  /// Clear only requests (keep responses)
  void clearRequests() {
    _requests.clear();
  }
}

// Pre-configured mock for common test scenarios
class MockApiServiceScenarios {
  static MockApiService createAuthenticatedMock() {
    final mock = MockApiService();
    mock.setResponse('/api/user/profile', {
      'success': true,
      'user': {
        'id': 'user_123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'Reporter',
        'pro': true,
      },
    });
    return mock;
  }

  static MockApiService createProUserMock() {
    final mock = MockApiService();
    mock.setResponse('/api/user/profile', {
      'success': true,
      'user': {
        'id': 'user_pro',
        'name': 'Pro User',
        'email': 'pro@example.com',
        'role': 'Analyst',
        'pro': true,
        'planId': 'pro_monthly',
      },
    });
    mock.setResponse('/api/user/usage', {
      'success': true,
      'usage': {
        'newsGenerations': {'used': 10, 'limit': -1}, // Unlimited
        'verifications': {'used': 25, 'limit': -1},
        'biasDetections': {'used': 15, 'limit': -1},
      },
    });
    return mock;
  }

  static MockApiService createOfflineMock() {
    final mock = MockApiService();
    mock.setOffline(true);
    return mock;
  }

  static MockApiService createErrorMock({String message = 'Server error'}) {
    final mock = MockApiService();
    mock.setResponses({
      '/api/user/profile': {'success': false, 'message': message},
      '/api/agents/news': {'success': false, 'message': message},
      '/api/agents/verify': {'success': false, 'message': message},
      '/api/agents/bias': {'success': false, 'message': message},
    });
    return mock;
  }
}
