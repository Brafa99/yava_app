import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:yava_delivery_driver/features/auth/domain/entities/auth_repositories_entity.dart';
import 'package:yava_delivery_driver/features/auth/domain/entities/auth_romet_datasource.dart';
import '../../../app/config/api_routes_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/messaging_service.dart';
import '../../../core/services/storage_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/app_user.dart';

// Providers de Infraestructura y Red
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiClient(
    storageService: storageService,
    baseUrl: ApiConfig.baseUrl,
  );
});

final messagingServiceProvider = Provider<MessagingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return MessagingService(apiClient: apiClient, storageService: storageService);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

final authRepositoryProvider = Provider<AuthRepositoryEntity>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    storageService: ref.watch(storageServiceProvider),
    messagingService: ref.watch(messagingServiceProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

// Estado
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// Controlador
class AuthController extends StateNotifier<AuthState> {
  AuthController({required AuthRepositoryEntity repository})
      : _repository = repository,
        super(const AuthState());

  final AuthRepositoryEntity _repository;

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> registerClient({
    required String name,
    String? lastName,
    required String email,
    required String password,
    required String phone,
    String? ci,
    String? city,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.registerClient(
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        ci: ci,
        city: city,
      );
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> registerDriver({
    required String name,
    String? lastName,
    required String email,
    required String password,
    required String phone,
    required String ci,
    String? city,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.registerDriver(
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        ci: ci,
        city: city,
      );
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.getCurrentUser();
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (_) {
      state = const AuthState();
      return null;
    }
  }

  Future<void> signOut() async {
    await _repository.logout();
    state = const AuthState();
  }

  String _mapHttpError(Object error) {
    final rawMessage = error.toString().replaceFirst('Exception: ', '');

    if (rawMessage.contains('Error de validación')) {
      return rawMessage.replaceAll('{', '').replaceAll('}', '');
    }
    if (rawMessage.contains('401') || rawMessage.toLowerCase().contains('unauthorized')) {
      return 'Credenciales incorrectas o sesión expirada.';
    }
    if (rawMessage.contains('SocketException') || rawMessage.contains('Failed host lookup')) {
      return 'No hay conexión con el servidor.';
    }

    return rawMessage.isNotEmpty ? rawMessage : 'Ocurrió un error inesperado.';
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository: repository);
});