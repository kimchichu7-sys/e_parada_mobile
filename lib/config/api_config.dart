import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String liveRenderUrl = 'https://e-parada.onrender.com/api';

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: liveRenderUrl,
  );

  static const String _prefKey = 'custom_api_base_url';
  static String? _runtimeOverrideUrl;

  static const String localEmulatorUrl = 'http://10.0.2.2:8000/api';
  static const String localHostUrl = 'http://127.0.0.1:8000/api';

  static String get defaultLocalUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return localEmulatorUrl;
    }
    return localHostUrl;
  }

  static Future<void> loadSavedBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _runtimeOverrideUrl = saved.trim();
      }
    } catch (_) {
      // Ignored if prefs not ready yet
    }
  }

  static Future<void> setCustomBaseUrl(String? customUrl) async {
    final cleaned = customUrl?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      _runtimeOverrideUrl = null;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefKey);
      } catch (_) {}
    } else {
      var value = cleaned;
      while (value.endsWith('/')) {
        value = value.substring(0, value.length - 1);
      }
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        value = 'https://$value';
      }
      if (!value.endsWith('/api')) {
        value = '$value/api';
      }
      _runtimeOverrideUrl = value;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, value);
      } catch (_) {}
    }
  }

  static String get baseUrl {
    var value = (_runtimeOverrideUrl ?? _configuredBaseUrl).trim();

    if (value.isEmpty) {
      if (kIsWeb) {
        value = defaultLocalUrl;
      } else if (!kReleaseMode) {
        value = defaultLocalUrl;
      } else {
        value = liveRenderUrl;
      }
    }

    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    if (!value.endsWith('/api')) {
      value = '$value/api';
    }

    return value;
  }

  static bool get hasRuntimeOverride =>
      _runtimeOverrideUrl != null && _runtimeOverrideUrl!.isNotEmpty;

  static String? get configurationError {
    if (baseUrl.isEmpty) {
      return 'Please enter your E-Parada server backend address.';
    }

    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'API_BASE_URL is not a valid absolute URL: $baseUrl';
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

    var trimmed = rawUrl.trim().replaceAll(r'\', '/');
    final apiUri = Uri.tryParse(baseUrl);
    if (apiUri == null) {
      return trimmed;
    }

    final mediaUri = Uri.tryParse(trimmed);
    if (mediaUri == null || !mediaUri.hasScheme) {
      if (trimmed.startsWith('public/')) {
        trimmed = trimmed.substring('public/'.length);
      }
      final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      final rootPort = (apiUri.hasPort && apiUri.port != 80 && apiUri.port != 443)
          ? ':${apiUri.port}'
          : '';
      return '${apiUri.scheme}://${apiUri.host}$rootPort$cleanPath';
    }

    const localHosts = {'localhost', '127.0.0.1', '0.0.0.0', '10.0.2.2'};

    final isLocalOrPrivate = localHosts.contains(mediaUri.host) ||
        mediaUri.host.startsWith('192.168.') ||
        mediaUri.host.startsWith('10.') ||
        mediaUri.host.startsWith('172.');

    if (isLocalOrPrivate || mediaUri.host == apiUri.host) {
      var cleanPath = mediaUri.path;
      if (cleanPath.startsWith('/public/')) {
        cleanPath = cleanPath.substring('/public'.length);
      }
      return Uri(
        scheme: apiUri.scheme,
        host: apiUri.host,
        port: (apiUri.hasPort && apiUri.port != 80 && apiUri.port != 443)
            ? apiUri.port
            : null,
        path: cleanPath,
        query: mediaUri.hasQuery ? mediaUri.query : null,
        fragment: mediaUri.hasFragment ? mediaUri.fragment : null,
      ).toString();
    }

    return mediaUri.toString();
  }
}
