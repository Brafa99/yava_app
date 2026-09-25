import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:yava_delivery_driver/core/repositories/repository_interfaces.dart';
import 'package:yava_delivery_driver/features/auth/data/datasources/firebase_auth_data.dart';
import 'package:yava_delivery_driver/features/auth/domain/entities/app_user.dart';
import 'package:yava_delivery_driver/features/auth/domain/repositories/auth_repositories_entity.dart';

final firebaseAuthDataSourceProvider =
    Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);

  return AuthRepositoryImpl(
    dataSource: dataSource,
  );
});

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
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        super(const AuthState());

  final AuthRepository _repository;

  Future<AppUser?> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      state = AuthState(
        user: user,
        isLoading: false,
      );

      return user;
    } catch (error) {
      state = AuthState(
        isLoading: false,
        errorMessage: _mapFirebaseError(error),
      );

      return null;
    }
  }

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );

      state = AuthState(
        user: user,
        isLoading: false,
      );

      return user;
    } catch (error) {
      state = AuthState(
        isLoading: false,
        errorMessage: _mapFirebaseError(error),
      );

      return null;
    }
  }

  Future<AppUser?> loadCurrentUser() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _repository.getCurrentUser();

      state = AuthState(
        user: user,
        isLoading: false,
      );

      return user;
    } catch (error) {
      state = AuthState(
        isLoading: false,
        errorMessage: _mapFirebaseError(error),
      );

      return null;
    }
  }

  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.sendPasswordResetEmail(
        email: email,
      );

      state = state.copyWith(
        isLoading: false,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(error),
      );

      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();

    state = const AuthState();
  }

  String _mapFirebaseError(Object error) {
    final code = _extractFirebaseCode(error);

    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';

      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'user-not-found':
        return 'No existe una cuenta con este correo.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No hay conexión con Internet.';

      case 'profile-not-found':
        return 'No se encontró el perfil del usuario.';

      default:
        return 'Ocurrió un error. Intenta nuevamente.';
    }
  }

  String _extractFirebaseCode(Object error) {
    try {
      final dynamic firebaseError = error;

      return firebaseError.code?.toString() ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return AuthController(
    repository: repository,
  );
});