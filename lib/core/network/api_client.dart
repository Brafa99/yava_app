import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

typedef RequestHeaders = Map<String, String>;

class ApiClient {
  final http.Client _client;
  final StorageService _storageService;
  final String _baseUrl;

  ApiClient({
    http.Client? client,
    required StorageService storageService,
    required String baseUrl,
  })  : _client = client ?? http.Client(),
        _storageService = storageService,
        _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;

  String get baseUrl => _baseUrl;

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final normalizedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$_baseUrl$normalizedEndpoint';
    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          ...queryParameters.map((k, v) => MapEntry(k, v.toString())),
        },
      );
    }
    return uri;
  }

  Future<RequestHeaders> _headers({bool requiresAuth = true}) async {
    final RequestHeaders headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final url = _buildUri(endpoint, queryParameters);
    final headers = await _headers(requiresAuth: requiresAuth);
    final response = await _client.get(
      url,
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = _buildUri(endpoint);
    final headers = await _headers(requiresAuth: requiresAuth);
    final response = await _client.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = _buildUri(endpoint);
    final headers = await _headers(requiresAuth: requiresAuth);
    final response = await _client.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = _buildUri(endpoint);
    final headers = await _headers(requiresAuth: requiresAuth);
    final response = await _client.patch(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = _buildUri(endpoint);
    final headers = await _headers(requiresAuth: requiresAuth);
    final response = await _client.delete(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, String>? filePaths,
    bool requiresAuth = true,
  }) async {
    final url = _buildUri(endpoint);
    final request = http.MultipartRequest('POST', url);

    request.headers['Accept'] = 'application/json';
    if (requiresAuth) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields.addAll(fields);

    if (filePaths != null) {
      for (final entry in filePaths.entries) {
        if (entry.value.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value),
          );
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic body;

    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 401) {
      throw Exception(
        body is Map && body['message'] != null
            ? body['message']
            : 'No autenticado o sesión expirada',
      );
    } else if (statusCode == 404) {
      throw Exception(
        body is Map && body['message'] != null
            ? body['message']
            : 'Recurso no encontrado (404)',
      );
    } else if (statusCode == 422) {
      if (body is Map && body['errors'] != null) {
        final Map<String, dynamic> errors = body['errors'];
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
        throw Exception(errors.toString());
      }
      throw Exception(
        body is Map && body['message'] != null
            ? body['message']
            : 'Error de validación (422)',
      );
    } else {
      throw Exception(
        body is Map && body['message'] != null
            ? body['message']
            : 'Error del servidor ($statusCode)',
      );
    }
  }
}