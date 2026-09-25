import 'package:yava_delivery_driver/core/repositories/repository_interfaces.dart';
import 'package:yava_delivery_driver/features/auth/data/datasources/firebase_auth_data.dart'
    show FirebaseAuthDataSource;

import '../../domain/entities/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthDataSource dataSource,
  }) : _dataSource = dataSource;

  final FirebaseAuthDataSource _dataSource;

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _dataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) {
    return _dataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _dataSource.sendPasswordResetEmail(
      email: email,
    );
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}