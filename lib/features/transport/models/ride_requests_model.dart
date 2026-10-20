import '../../auth/domain/entities/app_user.dart';

enum RideStatus { SOLICITADO, ACEPTADO, EN_ORIGEN, EN_CURSO, FINALIZADO, CANCELADO }
enum PaymentMethod { EFECTIVO, QR, TARJETA }

class RideRequestModel {
  final int id;
  final int clientId;
  final int? driverId;
  final int serviceCategoryId;
  final String? originAddress;
  final double originLatitude;
  final double originLongitude;
  final String? destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? distanceKm;
  final int? estimatedTimeMinutes;
  final double offeredFare;
  final double? agreedFare;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? cancellationReason;
  final AppUser? client;
  final AppUser? driver;

  RideRequestModel({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.serviceCategoryId,
    this.originAddress,
    required this.originLatitude,
    required this.originLongitude,
    this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.distanceKm,
    this.estimatedTimeMinutes,
    required this.offeredFare,
    this.agreedFare,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.cancellationReason,
    this.client,
    this.driver,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      clientId: json['client_id'] is int ? json['client_id'] : int.parse(json['client_id'].toString()),
      driverId: json['driver_id'] != null
          ? (json['driver_id'] is int ? json['driver_id'] : int.tryParse(json['driver_id'].toString()))
          : null,
      serviceCategoryId: json['service_category_id'] is int
          ? json['service_category_id']
          : int.parse(json['service_category_id'].toString()),
      originAddress: json['origin_address']?.toString(),
      originLatitude: double.parse(json['origin_latitude'].toString()),
      originLongitude: double.parse(json['origin_longitude'].toString()),
      destinationAddress: json['destination_address']?.toString(),
      destinationLatitude: double.parse(json['destination_latitude'].toString()),
      destinationLongitude: double.parse(json['destination_longitude'].toString()),
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
      estimatedTimeMinutes: json['estimated_time_minutes'] != null
          ? int.tryParse(json['estimated_time_minutes'].toString())
          : null,
      offeredFare: double.parse(json['offered_fare'].toString()),
      agreedFare: json['agreed_fare'] != null ? double.tryParse(json['agreed_fare'].toString()) : null,
      paymentMethod: json['payment_method']?.toString() ?? 'EFECTIVO',
      paymentStatus: json['payment_status']?.toString() ?? 'PENDIENTE',
      status: json['status']?.toString() ?? 'SOLICITADO',
      cancellationReason: json['cancellation_reason']?.toString(),
      client: json['client'] != null ? AppUser.fromJson(json['client'] as Map<String, dynamic>) : null,
      driver: json['driver'] != null ? AppUser.fromJson(json['driver'] as Map<String, dynamic>) : null,
    );
  }
}