import 'app_user.dart';

abstract class AuthRepositoryEntity {
  Future<AppUser> login({
    required String email,
    required String password,
    String? deviceToken,
    String? platform,
  });

  Future<AppUser> registerClient({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    Map<String, dynamic>? termAndRequirement,
  });

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
  });

  Future<AppUser> loginSocial({
    required String name,
    String? lastName,
    required String email,
    String? photo,
    String? deviceToken,
    String? platform,
  });

  Future<AppUser?> getCurrentUser();
  Future<void> updateDeviceToken(String deviceToken, {String? platform});
  Future<void> logout();
}