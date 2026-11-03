import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/messaging_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_repositories_entity.dart';
import '../../domain/entities/auth_romet_datasource.dart';

class AuthRepositoryImpl implements AuthRepositoryEntity {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;
  final MessagingService messagingService;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
    required this.messagingService,
    required this.apiClient,
  });

  Future<String?> _resolveDeviceToken(String? explicitToken) async {
    if (explicitToken != null && explicitToken.isNotEmpty) {
      return explicitToken;
    }
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
    String? deviceToken,
    String? platform,
  }) async {
    final tokenFcm = await _resolveDeviceToken(deviceToken);

    final response = await remoteDataSource.login(
      email: email,
      password: password,
      deviceToken: tokenFcm,
      platform: platform ?? 'android',
    );

    await _handleAuthSuccess(response);
    return response.user;
  }

  @override
  Future<AppUser> registerClient({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    Map<String, dynamic>? termAndRequirement,
  }) async {
    final response = await remoteDataSource.registerClient(
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      termAndRequirement: termAndRequirement,
    );

    await _handleAuthSuccess(response);
    return response.user;
  }

  @override
  Future<AppUser> registerDriver({
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
    final tokenFcm = await _resolveDeviceToken(deviceToken);

    final response = await remoteDataSource.registerDriver(
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      ci: ci,
      birthDate: birthDate,
      city: city,
      deviceToken: tokenFcm,
      platform: platform ?? 'android',
      lastLatitude: lastLatitude,
      lastLongitude: lastLongitude,
      termAndRequirement: termAndRequirement,
    );

    await _handleAuthSuccess(response);

    // Habilitar servicios iniciales por defecto según docs.json (/api/driver/{driverId}/services)[cite: 1]
    try {
      await apiClient.post(
        ApiEndpoints.driverServices(response.user.id),
        body: {
          'service_ids': [1, 2, 3, 4], // Categorías base
        },
        requiresAuth: true,
      );
    } catch (_) {}

    return response.user;
  }

  @override
  Future<AppUser> loginSocial({
    required String name,
    String? lastName,
    required String email,
    String? photo,
    String? deviceToken,
    String? platform,
  }) async {
    final tokenFcm = await _resolveDeviceToken(deviceToken);

    final response = await remoteDataSource.loginSocial(
      name: name,
      lastName: lastName,
      email: email,
      photo: photo,
      deviceToken: tokenFcm,
      platform: platform ?? 'android',
    );

    await _handleAuthSuccess(response);
    return response.user;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final token = await storageService.getToken();
    final userId = await storageService.getUserId();
    final userRole = await storageService.getUserRole();

    if (token == null || userId == null) return null;

    final endpoint = userRole == 'driver'
        ? ApiEndpoints.driverProfile(userId)
        : ApiEndpoints.clientProfile(userId);

    try {
      final response = await apiClient.get(endpoint, requiresAuth: true);
      final userData = response is Map<String, dynamic>
          ? (response['user'] ?? response['data'] ?? response)
          : response;

      return AppUser.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      await storageService.clearSession();
      return null;
    }
  }

  @override
  Future<void> updateDeviceToken(String deviceToken, {String? platform}) async {
    await remoteDataSource.updateDeviceToken(
      deviceToken: deviceToken,
      platform: platform ?? 'android',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignorar fallo de red en backend para asegurar limpieza local
    } finally {
      await storageService.clearSession();
    }
  }

  Future<void> _handleAuthSuccess(AuthResponseModel response) async {
    await storageService.saveToken(response.token);
    await storageService.saveUserId(response.user.id);
    await storageService.saveUserRole(response.user.role);
    try {
      await messagingService.syncTokenWithBackend();
    } catch (_) {}
  }
}