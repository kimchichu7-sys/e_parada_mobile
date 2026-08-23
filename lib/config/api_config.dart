import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _localDevelopmentUrl = 'http://127.0.0.1:8000/api';

  static String get baseUrl {
    var value = _configuredBaseUrl.trim();

    if (value.isEmpty && !kReleaseMode) {
      value = _localDevelopmentUrl;
    }

    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    return value;
  }

  static String? get configurationError {
    if (baseUrl.isEmpty) {
      return 'Build the release with '
          '--dart-define=API_BASE_URL=https://your-domain.example/api.';
    }

    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'API_BASE_URL is not a valid absolute URL: $baseUrl';
    }

    if (kReleaseMode && uri.scheme != 'https') {
      return 'Release builds require an HTTPS API_BASE_URL. Current value: '
          '$baseUrl';
    }

    return null;
  }

  static Uri endpoint(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$cleanPath');
  }

  static String? resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final mediaUri = Uri.tryParse(rawUrl.trim());
    final apiUri = Uri.tryParse(baseUrl);

    if (mediaUri == null || apiUri == null || !mediaUri.hasScheme) {
      return rawUrl;
    }

    const localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};

    if (!localHosts.contains(mediaUri.host)) {
      return mediaUri.toString();
    }

    return Uri(
      scheme: apiUri.scheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
      path: mediaUri.path,
      query: mediaUri.hasQuery ? mediaUri.query : null,
      fragment: mediaUri.hasFragment ? mediaUri.fragment : null,
    ).toString();
  }
}
