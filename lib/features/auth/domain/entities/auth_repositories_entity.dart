import '../entities/app_user.dart';

abstract class AuthRepositoryEntity {
  Future<AppUser> login(String email, String password);

  Future<AppUser> registerClient({
    required String name,
    String? lastName,
    required String email,
    required String password,
    required String phone,
    String? ci,
    String? city,
  });

  Future<AppUser> registerDriver({
    required String name,
    String? lastName,
    required String email,
    required String password,
    required String phone,
    required String ci,
    String? city,
  });

  Future<AppUser?> getCurrentUser();
  Future<void> logout();
}