import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/models/service_category_model.dart';


abstract class TransportRemoteDataSource {
  Future<List<ServiceCategoryModel>> getServiceCategories({String? type});
  Future<RideRequestModel> createRideRequest(Map<String, dynamic> data);
  Future<List<RideRequestModel>> getDriverAvailableRequests();
  Future<List<RideRequestModel>> getDriverAssignedRequests();
  Future<List<dynamic>> getClientMyRideOffers();
  Future<RideRequestModel> getRideRequestDetail(int id);
  Future<void> sendDriverOffer(int rideId, double offeredAmount);
  Future<void> acceptDriverOffer(int rideId, int offerId);
  Future<void> updateRideStatus(int rideId, String status);
  Future<void> cancelRide(int rideId, String reason);
  Future<void> syncDriverServices(int driverId, List<int> serviceIds);
  Future<void> createRating({
    int? rideId,
    required int driverId,
    required int clientId,
    required String evaluatorRole,
    required int score,
    String? comment,
    List<String>? tags,
  });
}

class TransportRemoteDataSourceImpl implements TransportRemoteDataSource {
  final ApiClient apiClient;

  TransportRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ServiceCategoryModel>> getServiceCategories({String? type}) async {
    final endpoint = type != null
        ? ApiEndpoints.serviceCategoriesByType(type)
        : ApiEndpoints.serviceCategoriesListAll;

    final response = await apiClient.get(
      endpoint,
      requiresAuth: type == null, // /type/{type} es público, /list-all requiere token
    );

    final rawList = (response is Map)
        ? (response['data'] ?? response['categories'] ?? response['service_categories'] ?? [])
        : response;

    if (rawList is List) {
      return rawList
          .map((item) => ServiceCategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<RideRequestModel> createRideRequest(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      ApiEndpoints.rideRequests,
      body: data,
      requiresAuth: true,
    );
    final rideData = response['data'] ?? response['ride_request'] ?? response;
    return RideRequestModel.fromJson(rideData as Map<String, dynamic>);
  }

  @override
  Future<List<RideRequestModel>> getDriverAvailableRequests() async {
    final response = await apiClient.get(
      ApiEndpoints.driverAvailableRequests,
      requiresAuth: true,
    );
    final list = (response is Map ? (response['data'] ?? response['requests'] ?? []) : response) as List<dynamic>;
    return list
        .map((item) => RideRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RideRequestModel>> getDriverAssignedRequests() async {
    final response = await apiClient.get(
      ApiEndpoints.driverAssignedRequests,
      requiresAuth: true,
    );
    final list = (response is Map ? (response['data'] ?? response['requests'] ?? []) : response) as List<dynamic>;
    return list
        .map((item) => RideRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<dynamic>> getClientMyRideOffers() async {
    final response = await apiClient.get(
      ApiEndpoints.clientMyRideOffers,
      requiresAuth: true,
    );
    return (response is Map ? (response['data'] ?? response['requests'] ?? []) : response) as List<dynamic>;
  }

  @override
  Future<RideRequestModel> getRideRequestDetail(int id) async {
    final response = await apiClient.get(
      ApiEndpoints.rideDetail(id),
      requiresAuth: true,
    );
    final rideData = response['data'] ?? response['ride_request'] ?? response;
    return RideRequestModel.fromJson(rideData as Map<String, dynamic>);
  }

  @override
  Future<void> sendDriverOffer(int rideId, double offeredAmount) async {
    // Según api-docs.json el campo requerido es "offered_amount"
    await apiClient.post(
      ApiEndpoints.rideOffer(rideId),
      body: {'offered_amount': offeredAmount},
      requiresAuth: true,
    );
  }

  @override
  Future<void> acceptDriverOffer(int rideId, int offerId) async {
    await apiClient.post(
      ApiEndpoints.acceptOffer(rideId, offerId),
      requiresAuth: true,
    );
  }

  @override
  Future<void> updateRideStatus(int rideId, String status) async {
    await apiClient.patch(
      ApiEndpoints.rideStatus(rideId),
      body: {'status': status},
      requiresAuth: true,
    );
  }

  @override
  Future<void> cancelRide(int rideId, String reason) async {
    await apiClient.post(
      ApiEndpoints.cancelRide(rideId),
      body: {'cancellation_reason': reason},
      requiresAuth: true,
    );
  }

  @override
  Future<void> syncDriverServices(int driverId, List<int> serviceIds) async {
    await apiClient.post(
      ApiEndpoints.driverServices(driverId),
      body: {'service_ids': serviceIds},
      requiresAuth: true,
    );
  }

  @override
  Future<void> createRating({
    int? rideId,
    required int driverId,
    required int clientId,
    required String evaluatorRole,
    required int score,
    String? comment,
    List<String>? tags,
  }) async {
    await apiClient.post(
      ApiEndpoints.ratings,
      body: {
        if (rideId != null) 'ride_id': rideId,
        'driver_id': driverId,
        'client_id': clientId,
        'evaluator_role': evaluatorRole,
        'score': score,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (tags != null) 'tags': tags,
        'is_anonymous': false,
      },
      requiresAuth: true,
    );
  }
}