// enum UserRole { customer, driver }

// extension UserRoleX on UserRole {
//   String get value => this == UserRole.customer ? 'customer' : 'driver';

//   String get displayName {
//     return this == UserRole.customer
//         ? 'Ganadero / Cliente'
//         : 'Transportista / Conductor';
//   }

//   static UserRole fromValue(Object? value) {
//     return value == 'driver' ? UserRole.driver : UserRole.customer;
//   }
// }

// DateTime? _dateFrom(Object? value) {
//   if (value is DateTime) return value;
//   if (value is String) return DateTime.tryParse(value);
//   return null;
// }

// String? _dateTo(DateTime? value) => value?.toIso8601String();

// class UserProfile {
//   final String uid;
//   final String name;
//   final String email;
//   final String? phone;
//   final UserRole role;
//   final bool isActive;
//   final DateTime? createdAt;

//   const UserProfile({
//     required this.uid,
//     required this.name,
//     required this.email,
//     this.phone,
//     required this.role,
//     this.isActive = true,
//     this.createdAt,
//   });

//   factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
//         uid: map['uid'] as String? ?? '',
//         name: map['name'] as String? ?? '',
//         email: map['email'] as String? ?? '',
//         phone: map['phone'] as String?,
//         role: UserRoleX.fromValue(map['role']),
//         isActive: map['isActive'] as bool? ?? true,
//         createdAt: _dateFrom(map['createdAt']),
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'uid': uid,
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'role': role.value,
//         'isActive': isActive,
//         'createdAt': _dateTo(createdAt),
//       };
// }

// class CustomerProfile {
//   final String uid;
//   final String? businessName;
//   final List<String> savedLocationIds;

//   const CustomerProfile({
//     required this.uid,
//     this.businessName,
//     this.savedLocationIds = const <String>[],
//   });

//   factory CustomerProfile.fromMap(Map<String, dynamic> map) => CustomerProfile(
//         uid: map['uid'] as String? ?? '',
//         businessName: map['businessName'] as String?,
//         savedLocationIds:
//             List<String>.from(map['savedLocationIds'] as List? ?? const []),
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'uid': uid,
//         'businessName': businessName,
//         'savedLocationIds': savedLocationIds,
//       };
// }

// class DriverProfile {
//   final String uid;
//   final bool isVerified;
//   final bool isAvailable;
//   final String? vehicleId;

//   const DriverProfile({
//     required this.uid,
//     this.isVerified = false,
//     this.isAvailable = false,
//     this.vehicleId,
//   });

//   factory DriverProfile.fromMap(Map<String, dynamic> map) => DriverProfile(
//         uid: map['uid'] as String? ?? '',
//         isVerified: map['isVerified'] as bool? ?? false,
//         isAvailable: map['isAvailable'] as bool? ?? false,
//         vehicleId: map['vehicleId'] as String?,
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'uid': uid,
//         'isVerified': isVerified,
//         'isAvailable': isAvailable,
//         'vehicleId': vehicleId,
//       };
// }

// class Vehicle {
//   final String id;
//   final String ownerId;
//   final String plateNumber;
//   final String type;
//   final double capacityTons;
//   final bool isActive;

//   const Vehicle({
//     required this.id,
//     required this.ownerId,
//     required this.plateNumber,
//     required this.type,
//     required this.capacityTons,
//     this.isActive = true,
//   });

//   factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
//         id: map['id'] as String? ?? '',
//         ownerId: map['ownerId'] as String? ?? '',
//         plateNumber: map['plateNumber'] as String? ?? '',
//         type: map['type'] as String? ?? '',
//         capacityTons: (map['capacityTons'] as num?)?.toDouble() ?? 0,
//         isActive: map['isActive'] as bool? ?? true,
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'ownerId': ownerId,
//         'plateNumber': plateNumber,
//         'type': type,
//         'capacityTons': capacityTons,
//         'isActive': isActive,
//       };
// }

// class TransportRequest {
//   final String id;
//   final String customerId;
//   final String originLocationId;
//   final String destinationLocationId;
//   final String serviceCategoryId;
//   final String status;
//   final DateTime? scheduledAt;

//   const TransportRequest({
//     required this.id,
//     required this.customerId,
//     required this.originLocationId,
//     required this.destinationLocationId,
//     required this.serviceCategoryId,
//     this.status = 'open',
//     this.scheduledAt,
//   });

//   factory TransportRequest.fromMap(Map<String, dynamic> map) =>
//       TransportRequest(
//         id: map['id'] as String? ?? '',
//         customerId: map['customerId'] as String? ?? '',
//         originLocationId: map['originLocationId'] as String? ?? '',
//         destinationLocationId: map['destinationLocationId'] as String? ?? '',
//         serviceCategoryId: map['serviceCategoryId'] as String? ?? '',
//         status: map['status'] as String? ?? 'open',
//         scheduledAt: _dateFrom(map['scheduledAt']),
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'customerId': customerId,
//         'originLocationId': originLocationId,
//         'destinationLocationId': destinationLocationId,
//         'serviceCategoryId': serviceCategoryId,
//         'status': status,
//         'scheduledAt': _dateTo(scheduledAt),
//       };
// }

// class TransportOffer {
//   final String id;
//   final String requestId;
//   final String driverId;
//   final double price;
//   final String status;

//   const TransportOffer({
//     required this.id,
//     required this.requestId,
//     required this.driverId,
//     required this.price,
//     this.status = 'pending',
//   });

//   factory TransportOffer.fromMap(Map<String, dynamic> map) => TransportOffer(
//         id: map['id'] as String? ?? '',
//         requestId: map['requestId'] as String? ?? '',
//         driverId: map['driverId'] as String? ?? '',
//         price: (map['price'] as num?)?.toDouble() ?? 0,
//         status: map['status'] as String? ?? 'pending',
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'requestId': requestId,
//         'driverId': driverId,
//         'price': price,
//         'status': status,
//       };
// }

// class CounterOffer extends TransportOffer {
//   const CounterOffer({
//     required String id,
//     required String requestId,
//     required String driverId,
//     required double price,
//     String status = 'pending',
//   }) : super(
//           id: id,
//           requestId: requestId,
//           driverId: driverId,
//           price: price,
//           status: status,
//         );
// }

// class Trip {
//   final String id;
//   final String requestId;
//   final String customerId;
//   final String driverId;
//   final String status;
//   final DateTime? startedAt;
//   final DateTime? completedAt;

//   const Trip({
//     required this.id,
//     required this.requestId,
//     required this.customerId,
//     required this.driverId,
//     this.status = 'assigned',
//     this.startedAt,
//     this.completedAt,
//   });

//   factory Trip.fromMap(Map<String, dynamic> map) => Trip(
//         id: map['id'] as String? ?? '',
//         requestId: map['requestId'] as String? ?? '',
//         customerId: map['customerId'] as String? ?? '',
//         driverId: map['driverId'] as String? ?? '',
//         status: map['status'] as String? ?? 'assigned',
//         startedAt: _dateFrom(map['startedAt']),
//         completedAt: _dateFrom(map['completedAt']),
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'requestId': requestId,
//         'customerId': customerId,
//         'driverId': driverId,
//         'status': status,
//         'startedAt': _dateTo(startedAt),
//         'completedAt': _dateTo(completedAt),
//       };
// }

// class Wallet {
//   final String userId;
//   final double balance;
//   final String currency;

//   const Wallet({
//     required this.userId,
//     this.balance = 0,
//     this.currency = 'BOB',
//   });

//   factory Wallet.fromMap(Map<String, dynamic> map) => Wallet(
//         userId: map['userId'] as String? ?? '',
//         balance: (map['balance'] as num?)?.toDouble() ?? 0,
//         currency: map['currency'] as String? ?? 'BOB',
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'userId': userId,
//         'balance': balance,
//         'currency': currency,
//       };
// }

// class WalletTransaction {
//   final String id;
//   final String walletUserId;
//   final double amount;
//   final String type;
//   final DateTime? createdAt;

//   const WalletTransaction({
//     required this.id,
//     required this.walletUserId,
//     required this.amount,
//     required this.type,
//     this.createdAt,
//   });

//   factory WalletTransaction.fromMap(Map<String, dynamic> map) =>
//       WalletTransaction(
//         id: map['id'] as String? ?? '',
//         walletUserId: map['walletUserId'] as String? ?? '',
//         amount: (map['amount'] as num?)?.toDouble() ?? 0,
//         type: map['type'] as String? ?? '',
//         createdAt: _dateFrom(map['createdAt']),
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'walletUserId': walletUserId,
//         'amount': amount,
//         'type': type,
//         'createdAt': _dateTo(createdAt),
//       };
// }

// class Document {
//   final String id;
//   final String ownerId;
//   final String type;
//   final String storagePath;
//   final String status;

//   const Document({
//     required this.id,
//     required this.ownerId,
//     required this.type,
//     required this.storagePath,
//     this.status = 'pending',
//   });

//   factory Document.fromMap(Map<String, dynamic> map) => Document(
//         id: map['id'] as String? ?? '',
//         ownerId: map['ownerId'] as String? ?? '',
//         type: map['type'] as String? ?? '',
//         storagePath: map['storagePath'] as String? ?? '',
//         status: map['status'] as String? ?? 'pending',
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'ownerId': ownerId,
//         'type': type,
//         'storagePath': storagePath,
//         'status': status,
//       };
// }

// class SavedLocation {
//   final String id;
//   final String ownerId;
//   final String name;
//   final String address;
//   final double? latitude;
//   final double? longitude;

//   const SavedLocation({
//     required this.id,
//     required this.ownerId,
//     required this.name,
//     required this.address,
//     this.latitude,
//     this.longitude,
//   });

//   factory SavedLocation.fromMap(Map<String, dynamic> map) => SavedLocation(
//         id: map['id'] as String? ?? '',
//         ownerId: map['ownerId'] as String? ?? '',
//         name: map['name'] as String? ?? '',
//         address: map['address'] as String? ?? '',
//         latitude: (map['latitude'] as num?)?.toDouble(),
//         longitude: (map['longitude'] as num?)?.toDouble(),
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'ownerId': ownerId,
//         'name': name,
//         'address': address,
//         'latitude': latitude,
//         'longitude': longitude,
//       };
// }

// class ServiceCategory {
//   final String id;
//   final String name;
//   final String description;

//   const ServiceCategory({
//     required this.id,
//     required this.name,
//     this.description = '',
//   });

//   factory ServiceCategory.fromMap(Map<String, dynamic> map) => ServiceCategory(
//         id: map['id'] as String? ?? '',
//         name: map['name'] as String? ?? '',
//         description: map['description'] as String? ?? '',
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'name': name,
//         'description': description,
//       };
// }

// class Rating {
//   final String id;
//   final String tripId;
//   final String authorId;
//   final String subjectId;
//   final double score;
//   final String comment;

//   const Rating({
//     required this.id,
//     required this.tripId,
//     required this.authorId,
//     required this.subjectId,
//     required this.score,
//     this.comment = '',
//   });

//   factory Rating.fromMap(Map<String, dynamic> map) => Rating(
//         id: map['id'] as String? ?? '',
//         tripId: map['tripId'] as String? ?? '',
//         authorId: map['authorId'] as String? ?? '',
//         subjectId: map['subjectId'] as String? ?? '',
//         score: (map['score'] as num?)?.toDouble() ?? 0,
//         comment: map['comment'] as String? ?? '',
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'tripId': tripId,
//         'authorId': authorId,
//         'subjectId': subjectId,
//         'score': score,
//         'comment': comment,
//       };
// }

// class Zone {
//   final String id;
//   final String name;
//   final String city;

//   const Zone({
//     required this.id,
//     required this.name,
//     required this.city,
//   });

//   factory Zone.fromMap(Map<String, dynamic> map) => Zone(
//         id: map['id'] as String? ?? '',
//         name: map['name'] as String? ?? '',
//         city: map['city'] as String? ?? '',
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'name': name,
//         'city': city,
//       };
// }

// class Tariff {
//   final String id;
//   final String zoneId;
//   final String serviceCategoryId;
//   final double basePrice;
//   final double pricePerKm;

//   const Tariff({
//     required this.id,
//     required this.zoneId,
//     required this.serviceCategoryId,
//     required this.basePrice,
//     required this.pricePerKm,
//   });

//   factory Tariff.fromMap(Map<String, dynamic> map) => Tariff(
//         id: map['id'] as String? ?? '',
//         zoneId: map['zoneId'] as String? ?? '',
//         serviceCategoryId: map['serviceCategoryId'] as String? ?? '',
//         basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0,
//         pricePerKm: (map['pricePerKm'] as num?)?.toDouble() ?? 0,
//       );

//   Map<String, dynamic> toMap() => <String, dynamic>{
//         'id': id,
//         'zoneId': zoneId,
//         'serviceCategoryId': serviceCategoryId,
//         'basePrice': basePrice,
//         'pricePerKm': pricePerKm,
//       };
// }