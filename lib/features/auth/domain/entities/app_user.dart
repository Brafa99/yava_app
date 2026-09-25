enum UserRole {
  customer,
  driver,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';

      case UserRole.driver:
        return 'driver';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Ganadero o Cliente';

      case UserRole.driver:
        return 'Transportista o Conductor';
    }
  }

  static UserRole fromValue(String? value) {
    switch (value) {
      case 'driver':
        return UserRole.driver;

      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}