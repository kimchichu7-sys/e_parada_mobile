import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class UploadFileData {
  const UploadFileData({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

class UploadFilePart {
  const UploadFilePart({required this.field, required this.file});

  final String field;
  final UploadFileData file;
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);

  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) {
    return _send(
      () => http.get(ApiConfig.endpoint(path), headers: _headers(headers)),
    );
  }

  static Future<http.Response> postJson(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _send(
      () => http.post(
        ApiConfig.endpoint(path),
        headers: _headers(headers, json: true),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  static Future<http.Response> patchJson(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _send(
      () => http.patch(
        ApiConfig.endpoint(path),
        headers: _headers(headers, json: true),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
  }) {
    return _send(
      () => http.post(ApiConfig.endpoint(path), headers: _headers(headers)),
    );
  }

  static Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) {
    return _send(
      () => http.delete(ApiConfig.endpoint(path), headers: _headers(headers)),
    );
  }

  static Future<http.Response> postMultipart(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    Map<String, UploadFileData>? files,
    List<UploadFilePart>? fileParts,
  }) {
    return _send(() async {
      final request = http.MultipartRequest('POST', ApiConfig.endpoint(path));
      request.headers.addAll(_headers(headers));
      request.fields.addAll(fields ?? const <String, String>{});

      for (final entry in (files ?? const <String, UploadFileData>{}).entries) {
        request.files.add(
          http.MultipartFile.fromBytes(
            entry.key,
            entry.value.bytes,
            filename: entry.value.filename,
          ),
        );
      }

      for (final part in fileParts ?? const <UploadFilePart>[]) {
        request.files.add(
          http.MultipartFile.fromBytes(
            part.field,
            part.file.bytes,
            filename: part.file.filename,
          ),
        );
      }

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    });
  }

  static Map<String, dynamic> decodeObject(http.Response response) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      // Converted to a concise API error below.
    }

    throw ApiException(
      'The E-Parada server returned an invalid response.',
      statusCode: response.statusCode,
    );
  }

  static void requireStatus(http.Response response, Set<int> acceptedStatuses) {
    if (acceptedStatuses.contains(response.statusCode)) {
      return;
    }

    final body = decodeObject(response);
    throw ApiException(_messageFrom(body), statusCode: response.statusCode);
  }

  static Map<String, String> _headers(
    Map<String, String>? extra, {
    bool json = false,
  }) {
    return <String, String>{
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      ...?extra,
    };
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'The E-Parada server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw ApiException(
        'Cannot reach the E-Parada server at ${ApiConfig.baseUrl}. '
        'Check that Laravel is running and that this device uses the correct PC IP address.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Cannot reach the E-Parada server at ${ApiConfig.baseUrl}. '
        'Check your network connection and try again.',
      );
    }
  }

  static String _messageFrom(Map<String, dynamic> body) {
    final errors = body['errors'];

    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }

        if (value != null) {
          return value.toString();
        }
      }
    }

    return body['message']?.toString() ?? 'The request could not be completed.';
  }
}
