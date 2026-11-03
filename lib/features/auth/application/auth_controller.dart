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

// -----------------------------------------------------------------------------
// PROVIDERS DE INFRAESTRUCTURA Y RED
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// ESTADO DE AUTENTICACIÓN
// -----------------------------------------------------------------------------
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

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

// -----------------------------------------------------------------------------
// CONTROLADOR CON LOGS PARA FASE BETA
// -----------------------------------------------------------------------------
class AuthController extends StateNotifier<AuthState> {
  AuthController({required AuthRepositoryEntity repository})
      : _repository = repository,
        super(const AuthState());

  final AuthRepositoryEntity _repository;

  Future<AppUser?> signIn({
    required String email,
    required String password,
    String? deviceToken,
    String? platform,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    print('\n\n🟢 === INICIO DE SESIÓN YAVÁ === 🟢');
    print('Usuario: $email');

    try {
      final user = await _repository.login(
        email: email,
        password: password,
        deviceToken: deviceToken,
        platform: platform,
      );
      
      print('✅ LOGIN EXITOSO: ID ${user.id} | Rol: ${user.role} | Nombre: ${user.name}');
      print('🟢 =================================== 🟢\n\n');
      
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      print('❌ ERROR EN LOGIN: $error');
      print('🟢 =================================== 🟢\n\n');
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> registerClient({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    Map<String, dynamic>? termAndRequirement,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    print('\n\n🔵 === REGISTRO DE CLIENTE YAVÁ === 🔵');
    print('Registrando: $name $lastName | $email');

    try {
      final user = await _repository.registerClient(
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        termAndRequirement: termAndRequirement,
      );
      
      print('✅ REGISTRO CLIENTE EXITOSO: ID ${user.id}');
      print('🔵 ==================================== 🔵\n\n');
      
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      print('❌ ERROR EN REGISTRO CLIENTE: $error');
      print('🔵 ==================================== 🔵\n\n');
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> registerDriver({
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
    state = state.copyWith(isLoading: true, clearError: true);
    print('\n\n🟠 === REGISTRO DE CONDUCTOR YAVÁ === 🟠');
    print('Registrando Conductor: $name $lastName | $email | CI: $ci');

    try {
      final user = await _repository.registerDriver(
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        ci: ci,
        birthDate: birthDate,
        city: city,
        deviceToken: deviceToken,
        platform: platform,
        lastLatitude: lastLatitude,
        lastLongitude: lastLongitude,
        termAndRequirement: termAndRequirement,
      );
      
      print('✅ REGISTRO CONDUCTOR EXITOSO: ID ${user.id}');
      print('🟠 ====================================== 🟠\n\n');
      
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      print('❌ ERROR EN REGISTRO CONDUCTOR: $error');
      print('🟠 ====================================== 🟠\n\n');
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> signInWithSocial({
    required String name,
    String? lastName,
    required String email,
    String? photo,
    String? deviceToken,
    String? platform,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    print('\n\n🟣 === LOGIN SOCIAL YAVÁ === 🟣');
    print('Usuario: $email');

    try {
      final user = await _repository.loginSocial(
        name: name,
        lastName: lastName,
        email: email,
        photo: photo,
        deviceToken: deviceToken,
        platform: platform,
      );
      
      print('✅ LOGIN SOCIAL EXITOSO: ID ${user.id} | Rol: ${user.role}');
      print('🟣 ================================= 🟣\n\n');
      
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      print('❌ ERROR EN LOGIN SOCIAL: $error');
      print('🟣 ================================= 🟣\n\n');
      state = AuthState(isLoading: false, errorMessage: _mapHttpError(error));
      return null;
    }
  }

  Future<AppUser?> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, clearError: true);
    print('\n\n🟡 === CARGANDO SESIÓN YAVÁ === 🟡');

    try {
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        print('✅ SESIÓN ACTIVA RECUPERADA: ID ${user.id} | Rol: ${user.role} | Nombre: ${user.name}');
      } else {
        print('⚠️ SESIÓN RECUPERADA PERO EL USUARIO ESTÁ VACÍO.');
      }
      print('🟡 ================================= 🟡\n\n');
      
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (error) {
      print('⚠️ NO HAY SESIÓN ACTIVA O EL TOKEN EXPIRÓ: $error');
      print('🟡 ================================= 🟡\n\n');
      state = const AuthState();
      return null;
    }
  }

  Future<void> signOut() async {
    print('\n\n🔴 === CERRANDO SESIÓN YAVÁ === 🔴');
    try {
      await _repository.logout();
      print('✅ SESIÓN CERRADA EXITOSAMENTE.');
    } catch (error) {
      print('❌ ERROR AL CERRAR SESIÓN: $error');
    } finally {
      print('🔴 ================================= 🔴\n\n');
      state = const AuthState();
    }
  }

  String _mapHttpError(Object error) {
    final rawMessage = error.toString().replaceFirst('Exception: ', '');

    if (rawMessage.contains('Error de validación')) {
      return rawMessage.replaceAll('{', '').replaceAll('}', '');
    }
    if (rawMessage.contains('401') ||
        rawMessage.toLowerCase().contains('unauthorized')) {
      return 'Credenciales incorrectas o sesión expirada.';
    }
    if (rawMessage.contains('SocketException') ||
        rawMessage.contains('Failed host lookup')) {
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