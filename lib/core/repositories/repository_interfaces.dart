import 'package:yava_delivery_driver/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser?> getCurrentUser();

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();
}