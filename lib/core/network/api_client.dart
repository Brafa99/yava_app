import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

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
        _baseUrl = baseUrl;

  Future<Map<String, String>> _headers({bool requiresAuth = true}) async {
    final headers = <String, String>{
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

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.get(
      url,
      headers: await _headers(requiresAuth: requiresAuth),
    );
    return _processResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.post(
      url,
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.put(
      url,
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.patch(
      url,
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.delete(
      url,
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  /// Soporte para multipart/form-data (Documentos, Vehículo, Fotos de perfil)
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, String>? filePaths,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
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
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 401) {
      throw Exception(body?['message'] ?? 'No autenticado o sesión expirada');
    } else if (statusCode == 422) {
      final errors = body?['errors'] ?? body?['message'] ?? {};
      throw Exception('Error de validación: $errors');
    } else {
      throw Exception(body?['message'] ?? 'Error del servidor ($statusCode)');
    }
  }
}