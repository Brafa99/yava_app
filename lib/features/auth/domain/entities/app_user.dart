class AppUser {
  final int id;
  final String name;
  final String? lastName;
  final String email;
  final String role; // 'client' | 'driver' | 'admin'
  final String? ci;
  final String? birthDate;
  final String? phone;
  final String? address;
  final String? photo;
  final String? city;
  final String status; // 'HABILITADO' | 'DESHABILITADO' | 'EN_REVISION' | 'BORRADOR'
  final bool isEnabled;
  final bool isOnline;
  final bool isOnRide;
  final String? deviceToken;
  final String? platform;
  final double? lastLatitude;
  final double? lastLongitude;

  AppUser({
    required this.id,
    required this.name,
    this.lastName,
    required this.email,
    required this.role,
    this.ci,
    this.birthDate,
    this.phone,
    this.address,
    this.photo,
    this.city,
    required this.status,
    required this.isEnabled,
    required this.isOnline,
    required this.isOnRide,
    this.deviceToken,
    this.platform,
    this.lastLatitude,
    this.lastLongitude,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty ? '$name $lastName' : name;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Si viene anidado dentro de { "user": { ... } }
    final data = json.containsKey('user') && json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return AppUser(
      id: data['id'] is int ? data['id'] : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      name: data['name']?.toString() ?? '',
      lastName: data['last_name']?.toString(),
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? (data['is_online'] != null ? 'driver' : 'client'),
      ci: data['ci']?.toString(),
      birthDate: data['birth_date']?.toString(),
      phone: data['phone']?.toString(),
      address: data['address']?.toString(),
      photo: data['photo']?.toString(),
      city: data['city']?.toString(),
      status: data['status']?.toString() ?? 'EN_REVISION',
      isEnabled: data['is_enabled'] == 1 || data['is_enabled'] == true,
      isOnline: data['is_online'] == 1 || data['is_online'] == true,
      isOnRide: data['is_on_ride'] == 1 || data['is_on_ride'] == true,
      deviceToken: data['device_token']?.toString(),
      platform: data['platform']?.toString(),
      lastLatitude: data['last_latitude'] != null
          ? double.tryParse(data['last_latitude'].toString())
          : null,
      lastLongitude: data['last_longitude'] != null
          ? double.tryParse(data['last_longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'last_name': lastName,
    'email': email,
    'role': role,
    'ci': ci,
    'birth_date': birthDate,
    'phone': phone,
    'address': address,
    'photo': photo,
    'city': city,
    'status': status,
    'is_enabled': isEnabled,
    'is_online': isOnline,
    'is_on_ride': isOnRide,
    'device_token': deviceToken,
    'platform': platform,
    'last_latitude': lastLatitude,
    'last_longitude': lastLongitude,
  };

  AppUser copyWith({
    int? id,
    String? name,
    String? lastName,
    String? email,
    String? role,
    String? ci,
    String? birthDate,
    String? phone,
    String? address,
    String? photo,
    String? city,
    String? status,
    bool? isEnabled,
    bool? isOnline,
    bool? isOnRide,
    String? deviceToken,
    String? platform,
    double? lastLatitude,
    double? lastLongitude,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      ci: ci ?? this.ci,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      city: city ?? this.city,
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
      isOnline: isOnline ?? this.isOnline,
      isOnRide: isOnRide ?? this.isOnRide,
      deviceToken: deviceToken ?? this.deviceToken,
      platform: platform ?? this.platform,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
    );
  }
}