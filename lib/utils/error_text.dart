/// Convert any thrown error / exception into a short, user-safe message.
///
/// Never leak raw exceptions, stack traces, URIs, or host names to the UI.
/// Unknown errors collapse to a generic [fallback].
String friendlyError(Object? e,
    {String fallback = 'Something went wrong. Please try again.'}) {
  final s = (e?.toString() ?? '').toLowerCase();

  if (s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('no address associated') ||
      s.contains('network is unreachable') ||
      s.contains('connection refused') ||
      s.contains('connection closed') ||
      s.contains('connection reset') ||
      s.contains('handshakeexception') ||
      s.contains('clientexception') ||
      s.contains('network error')) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (s.contains('timeout') || s.contains('timed out')) {
    return 'The server took too long to respond. Please try again.';
  }
  if (s.contains('usage limit') ||
      s.contains('usage_limit') ||
      s.contains('limit reached') ||
      s.contains('upgraderequired')) {
    return 'You have reached your usage limit.';
  }
  if (s.contains('session expired') ||
      s.contains('not authorized') ||
      s.contains('login again') ||
      s.contains('authrequired')) {
    return 'Your session expired. Please log in again.';
  }
  return fallback;
}
