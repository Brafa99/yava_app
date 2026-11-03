import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'app_user.dart';

/// Modelo de respuesta que encapsula el Token de Sanctum y el Usuario autenticado
class AuthResponseModel {
  final String token;
  final AppUser user;

  AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json, {String? defaultRole}) {
    final token = json['token'] ?? json['access_token'] ?? '';
    final userData = json['user'] ?? json['data'] ?? json;

    final userMap = Map<String, dynamic>.from(userData as Map);
    if (!userMap.containsKey('role') && defaultRole != null) {
      userMap['role'] = defaultRole;
    }

    return AuthResponseModel(
      token: token.toString(),
      user: AppUser.fromJson(userMap),
    );
  }
}

/// Contrato abstracto para las operaciones remotas de autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? deviceToken,
    String? platform,
  });

  Future<AuthResponseModel> registerClient({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    Map<String, dynamic>? termAndRequirement,
  });

  Future<AuthResponseModel> registerDriver({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String? ci,
    String? birthDate,
    String? city,
    String? deviceToken,
    String? platform,
    double? lastLatitude,
    double? lastLongitude,
    Map<String, dynamic>? termAndRequirement,
  });

  Future<AuthResponseModel> loginSocial({
    required String name,
    String? lastName,
    required String email,
    String? photo,
    String? deviceToken,
    String? platform,
  });

  Future<void> updateDeviceToken({
    required String deviceToken,
    String? platform,
  });

  Future<AppUser> getClientProfile(int id);
  Future<AppUser> getDriverProfile(int driverId);

  Future<void> logout();
}

/// Implementación concreta consumiendo YAVA API REST con ApiClient
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  static Map<String, dynamic> _defaultTerms() => {
        'terms_and_conditions': {
          'accepted': true,
          'version': '1.0',
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        },
        'privacy_policy': {
          'accepted': true,
          'version': '1.0',
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        },
      };

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? deviceToken,
    String? platform,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (deviceToken != null && deviceToken.isNotEmpty) {
      body['device_token'] = deviceToken;
    }
    if (platform != null && platform.isNotEmpty) {
      body['platform'] = platform;
    }

    final response = await apiClient.post(
      ApiEndpoints.login,
      body: body,
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> registerClient({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    Map<String, dynamic>? termAndRequirement,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'term_and_requirement': termAndRequirement ?? _defaultTerms(),
    };

    final response = await apiClient.post(
      ApiEndpoints.clientRegister,
      body: body,
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(
      response as Map<String, dynamic>,
      defaultRole: 'client',
    );
  }

  @override
  Future<AuthResponseModel> registerDriver({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String? ci,
    String? birthDate,
    String? city,
    String? deviceToken,
    String? platform,
    double? lastLatitude,
    double? lastLongitude,
    Map<String, dynamic>? termAndRequirement,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'ci': ci,
      'birth_date': birthDate,
      'city': city,
      'device_token': deviceToken,
      'platform': platform ?? 'android',
      'last_latitude': lastLatitude,
      'last_longitude': lastLongitude,
      'term_and_requirement': termAndRequirement ?? _defaultTerms(),
    };

    final response = await apiClient.post(
      ApiEndpoints.driverRegister,
      body: body,
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(
      response as Map<String, dynamic>,
      defaultRole: 'driver',
    );
  }

  @override
  Future<AuthResponseModel> loginSocial({
    required String name,
    String? lastName,
    required String email,
    String? photo,
    String? deviceToken,
    String? platform,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'last_name': lastName,
      'email': email,
      'photo': photo,
      'device_token': deviceToken,
      'platform': platform ?? 'android',
    };

    final response = await apiClient.post(
      ApiEndpoints.loginSocial,
      body: body,
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateDeviceToken({
    required String deviceToken,
    String? platform,
  }) async {
    await apiClient.post(
      ApiEndpoints.updateToken,
      body: {
        'device_token': deviceToken,
        if (platform != null) 'platform': platform,
      },
      requiresAuth: true,
    );
  }

  @override
  Future<AppUser> getClientProfile(int id) async {
    final response = await apiClient.get(
      ApiEndpoints.clientProfile(id),
      requiresAuth: true,
    );
    return AppUser.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AppUser> getDriverProfile(int driverId) async {
    final response = await apiClient.get(
      ApiEndpoints.driverProfile(driverId),
      requiresAuth: true,
    );
    return AppUser.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(
      ApiEndpoints.logout,
      requiresAuth: true,
    );
  }
}