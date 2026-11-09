/// Build-time network configuration.
///
/// The app is fully offline by default. Pass
/// `--dart-define=API_BASE_URL=http://10.0.2.2:8080` (Android emulator) or
/// `http://localhost:8080` (iOS Simulator) to enable the optional mock server.
final class ApiConfig {
  const ApiConfig({required this.baseUrl});

  factory ApiConfig.fromEnvironment() =>
      const ApiConfig(baseUrl: String.fromEnvironment('API_BASE_URL'));

  final String baseUrl;

  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 8);
  static const int maxRetries = 2;
  static const Duration retryBaseDelay = Duration(milliseconds: 400);
  static const String apiVersionPath = '/v1';

  bool get isConfigured => baseUrl.isNotEmpty;

  /// Resolves a relative image path from the data against the server.
  String? resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (!isConfigured) return null;
    final separator = path.startsWith('/') ? '' : '/';
    return '$baseUrl$separator$path';
  }
}
