import 'package:yava_delivery_driver/features/auth/domain/entities/auth_repositories_entity.dart';
import 'package:yava_delivery_driver/features/auth/domain/entities/auth_romet_datasource.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/messaging_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/app_user.dart';

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

  @override
  Future<AppUser> login(String email, String password) async {
    final response = await remoteDataSource.login(email: email, password: password);
    await _handleAuthSuccess(response);
    return response.user;
  }

  @override
  Future<AppUser> registerClient({
    required String name,
    String? lastName,
    required String email,
    required String password,
    required String phone,
    String? ci,
    String? city,
  }) async {
    final response = await remoteDataSource.registerClient({
      'name': name,
      'last_name': (lastName != null && lastName.isNotEmpty) ? lastName : 'Cliente',
      'email': email,
      'password': password,
      'phone': phone,
      'term_and_requirement': true,
    });
    await _handleAuthSuccess(response);
    return response.user;
  }

  @override
  Future<AppUser> registerDriver({
    required String name,
    String? lastName,
    required String email,
    required String password,
    required String phone,
    required String ci,
    String? city,
  }) async {
    final response = await remoteDataSource.registerDriver({
      'name': name,
      'last_name': (lastName != null && lastName.isNotEmpty) ? lastName : 'Conductor',
      'email': email,
      'password': password,
      'phone': phone,
      'term_and_requirement': true,
    });
    await _handleAuthSuccess(response);

    // Sincronizamos automáticamente las categorías de servicio al conductor recién creado
    // para que /api/driver/available-requests le devuelva solicitudes de inmediato
    try {
      await apiClient.post(
        ApiEndpoints.driverServices(response.user.id),
        body: {
          'service_ids': [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        },
        requiresAuth: true,
      );
    } catch (_) {}

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

    final response = await apiClient.get(endpoint, requiresAuth: true);
    final userData = response['data'] ?? response['user'] ?? response;
    return AppUser.fromJson(userData as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      await storageService.clearSession();
    }
  }

  Future<void> _handleAuthSuccess(AuthResponseModel response) async {
    await storageService.saveToken(response.token);
    await storageService.saveUserId(response.user.id);
    await storageService.saveUserRole(response.user.role);
    await messagingService.syncTokenWithBackend();
  }
}