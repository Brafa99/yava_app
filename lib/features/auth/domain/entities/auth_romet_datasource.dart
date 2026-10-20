import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/app_user.dart';

/// Modelo de respuesta que encapsula el Token de Sanctum y el Usuario autenticado
class AuthResponseModel {
  final String token;
  final AppUser user;

  AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Laravel suele responder con:
    // { "token": "...", "user": { ... } } o { "access_token": "...", "data": { ... } }
    final token = json['token'] ?? json['access_token'] ?? '';
    final userData = json['user'] ?? json['data'] ?? json;

    return AuthResponseModel(
      token: token.toString(),
      user: AppUser.fromJson(userData as Map<String, dynamic>),
    );
  }
}

/// Contrato abstracto para las operaciones de autenticación remotas
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> registerClient(Map<String, dynamic> clientData);

  Future<AuthResponseModel> registerDriver(Map<String, dynamic> driverData);

  Future<AuthResponseModel> loginSocial({
    required String provider,
    required String token,
  });

  Future<void> logout();
}

/// Implementación concreta consumiendo Laravel REST API con ApiClient
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> registerClient(Map<String, dynamic> clientData) async {
    final response = await apiClient.post(
      ApiEndpoints.clientRegister,
      body: clientData,
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> registerDriver(Map<String, dynamic> driverData) async {
    final response = await apiClient.post(
      ApiEndpoints.driverRegister,
      body: driverData,
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> loginSocial({
    required String provider,
    required String token,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.loginSocial,
      body: {
        'provider': provider,
        'token': token,
      },
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(
      ApiEndpoints.logout,
      requiresAuth: true,
    );
  }
}