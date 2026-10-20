class ApiEndpoints {
  // Autenticación
  static const String login = '/login';
  static const String loginSocial = '/login-red-social';
  static const String updateToken = '/update-token';
  static const String logout = '/logout';

  // Cliente
  static const String clientRegister = '/client/register';
  static String clientUpdate(int id) => '/client/$id/update';
  static const String clientUpdatePhoto = '/client/update-photo';
  static const String clientDisable = '/client/disable-account';
  static String clientProfile(int id) => '/client/$id/profile';
  static String clientChangePassword(int id) => '/client/$id/change-password';

  // Conductor
  static const String driverRegister = '/driver/register';
  static String driverUpdate(int driverId) => '/driver/$driverId/update';
  static const String driverUpdatePhoto = '/driver/update-photo';
  static const String driverDisable = '/driver/disable-account';
  static String driverServices(int driverId) => '/driver/$driverId/services';
  static String driverDetachService(int driverId, int serviceId) =>
      '/driver/$driverId/services/$serviceId';
  static String driverProfile(int driverId) => '/driver/$driverId/profile';
  static String driverChangePassword(int driverId) =>
      '/driver/$driverId/change-password';

  // Documentos y Vehículo Conductor (Usan query ?user_id= en GET)
  static String driverDocumentsGet(int userId) =>
      '/driver/documents?user_id=$userId';
  static const String driverDocuments = '/driver/documents';

  static String driverVehicleGet(int userId) =>
      '/driver/vehicle?user_id=$userId';
  static const String driverVehicle = '/driver/vehicle';
  static String driverVehicleUpdate(int id) => '/driver/vehicle/$id';
  static String driverVehicleActivate(int vehicleId) =>
      '/driver/vehicle/$vehicleId/activate';

  // Calificaciones
  static const String ratings = '/ratings';
  static String userRatings(int userId, {String? role, int page = 1}) =>
      '/users/$userId/ratings?page=$page${role != null ? '&role=$role' : ''}';
  static String userRatingsSummary(int userId, {String? role}) =>
      '/users/$userId/ratings/summary${role != null ? '?role=$role' : ''}';

  // Solicitudes de Viaje
  static const String rideRequests = '/ride-requests';
  static const String driverAvailableRequests = '/driver/available-requests';
  static const String driverAssignedRequests = '/driver/assigned-requests';
  static const String clientMyRideOffers = '/client/my-ride-offers';
  static String rideOffer(int id) => '/ride-requests/$id/offer';
  static String acceptOffer(int id, int offerId) =>
      '/ride-requests/$id/accept-offer/$offerId';
  static String rideStatus(int id) => '/ride-requests/$id/status';
  static String cancelRide(int id) => '/ride-requests/$id/cancel';
  static String rideDetail(int id) => '/ride-requests/$id';

  // Categorías de Servicios
  static const String serviceCategoriesListAll = '/service-categories/list-all';
  static String serviceCategoriesByType(String type) =>
      '/service-categories/type/$type';
  static const String serviceCategories = '/service-categories';
}