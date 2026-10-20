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
  final String status; // 'BORRADOR','EN_REVISION','OBSERVADO','APROBADO','HABILITADO', etc.
  final bool isEnabled;
  final bool isOnline;
  final bool isOnRide;
  final String? deviceToken;
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
    this.lastLatitude,
    this.lastLongitude,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      lastName: json['last_name'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      ci: json['ci'],
      birthDate: json['birth_date'],
      phone: json['phone'],
      address: json['address'],
      photo: json['photo'],
      city: json['city'],
      status: json['status'] ?? 'BORRADOR',
      isEnabled: json['is_enabled'] == 1 || json['is_enabled'] == true,
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      isOnRide: json['is_on_ride'] == 1 || json['is_on_ride'] == true,
      deviceToken: json['device_token'],
      lastLatitude: json['last_latitude'] != null ? double.tryParse(json['last_latitude'].toString()) : null,
      lastLongitude: json['last_longitude'] != null ? double.tryParse(json['last_longitude'].toString()) : null,
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
    'is_enabled': isEnabled ? 1 : 0,
    'is_online': isOnline ? 1 : 0,
    'is_on_ride': isOnRide ? 1 : 0,
    'device_token': deviceToken,
    'last_latitude': lastLatitude,
    'last_longitude': lastLongitude,
  };
}