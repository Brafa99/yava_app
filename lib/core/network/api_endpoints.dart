class ApiEndpoints {
  // ===========================================================================
  // AUTENTICACIÓN
  // ===========================================================================
  static const String login = '/api/login';
  static const String loginSocial = '/api/login-red-social';
  static const String updateToken = '/api/update-token';
  static const String logout = '/api/logout';

  // ===========================================================================
  // CLIENTE (PASAJERO)
  // ===========================================================================
  static const String clientRegister = '/api/client/register';
  static const String clientUpdatePhoto = '/api/client/update-photo';
  static const String clientDisableAccount = '/api/client/disable-account';
  
  static String clientUpdate(int id) => '/api/client/$id/update';
  static String clientProfile(int id) => '/api/client/$id/profile';
  static String clientChangePassword(int id) => '/api/client/$id/change-password';

  // ===========================================================================
  // CONDUCTOR
  // ===========================================================================
  static const String driverRegister = '/api/driver/register';
  static const String driverUpdatePhoto = '/api/driver/update-photo';
  static const String driverDisableAccount = '/api/driver/disable-account';
  
  static String driverUpdate(int driverId) => '/api/driver/$driverId/update';
  static String driverProfile(int driverId) => '/api/driver/$driverId/profile';
  static String driverChangePassword(int driverId) => '/api/driver/$driverId/change-password';
  
  // Servicios del conductor
  static String driverServices(int driverId) => '/api/driver/$driverId/services'; // GET y POST
  static String driverRemoveService(int driverId, int serviceId) => '/api/driver/$driverId/services/$serviceId'; // DELETE

  // ===========================================================================
  // DOCUMENTOS DEL CONDUCTOR
  // ===========================================================================
  static const String driverDocuments = '/api/driver/documents'; // GET, POST, DELETE

  // ===========================================================================
  // VEHÍCULO DEL CONDUCTOR
  // ===========================================================================
  static const String driverVehicle = '/api/driver/vehicle'; // GET, POST, DELETE
  static const String checkPlate = '/api/driver/vehicle/check-plate';
  
  static String driverVehicleUpdate(int id) => '/api/driver/vehicle/$id'; // POST
  static String driverVehicleActivate(int vehicleId) => '/api/driver/vehicle/$vehicleId/activate'; // PATCH

  // ===========================================================================
  // CATEGORÍAS DE SERVICIOS
  // ===========================================================================
  static const String serviceCategoriesListAll = '/api/service-categories/list-all';
  static const String serviceCategories = '/api/service-categories'; // POST (Crear)
  
  static String serviceCategoriesByType(String type) => '/api/service-categories/type/$type';
  static String serviceCategoryDetail(int id) => '/api/service-categories/$id'; // POST (Actualizar) y DELETE

  // ===========================================================================
  // SOLICITUDES DE VIAJE Y OFERTAS (CORE UBER/YANGO)
  // ===========================================================================
  static const String rideRequests = '/api/ride-requests'; // POST
  
  // Para el Cliente
  static const String clientMyRideOffers = '/api/client/my-ride-offers';
  static const String clientMyRideRequests = '/api/client/my-ride-requests';
  static const String clientActiveRequest = '/api/client/active-request';
  
  // Para el Conductor
  static const String driverAvailableRequests = '/api/driver/available-requests';
  static const String driverAssignedRequests = '/api/driver/assigned-requests';
  
  // Interacciones del Viaje
  static String rideDetail(int id) => '/api/ride-requests/$id'; // GET
  static String sendOffer(int id) => '/api/ride-requests/$id/offer'; // POST
  static String acceptOffer(int id, int offerId) => '/api/ride-requests/$id/accept-offer/$offerId'; // POST
  static String changeRideStatus(int id) => '/api/ride-requests/$id/status'; // PATCH
  static String cancelRide(int id) => '/api/ride-requests/$id/cancel'; // POST

  // ===========================================================================
  // CALIFICACIONES Y RESEÑAS
  // ===========================================================================
  static const String ratings = '/api/ratings'; // POST
  
  static String userRatings(int userId) => '/api/users/$userId/ratings'; // GET
  static String userRatingsSummary(int userId) => '/api/users/$userId/ratings/summary'; // GET

  // ===========================================================================
  // ADMINISTRACIÓN (PANEL WEB / ADMIN APP)
  // ===========================================================================
  static const String adminDashboard = '/api/admin/dashboard';
  
  // Usuarios Administrativos
  static const String adminUsers = '/api/admin/users'; // GET, POST
  static const String adminUsersDisabled = '/api/admin/users/disabled';
  static String adminUserDetail(int id) => '/api/admin/users/$id'; // GET, PUT, DELETE
  static String adminUserChangeStatus(int id) => '/api/admin/users/$id/status'; // PATCH
  
  // Pasajeros
  static const String adminPassengers = '/api/admin/passengers';
  static String adminPassengerChangeStatus(int id) => '/api/admin/passengers/$id/status';
  
  // Conductores
  static const String adminDrivers = '/api/admin/drivers'; // GET, POST
  static const String adminDriversDisabled = '/api/admin/drivers/disabled';
  static String adminDriverDetail(int id) => '/api/admin/drivers/$id'; // PUT
  static String adminDriverChangeStatus(int id) => '/api/admin/drivers/$id/status'; // PATCH
  static String adminDriverDocuments(int id) => '/api/admin/users/$id/documents'; // GET
  
  // Vehículos Administrativo
  static String adminUserVehicles(int id) => '/api/admin/users/$id/vehicles'; // GET
  
  // Viajes Administrativo
  static const String adminRideRequests = '/api/admin/ride-requests';
  static String adminRideRequestDetail(int id) => '/api/admin/ride-requests/$id';
  
  // Categorías Administrativo
  static const String adminServiceCategories = '/api/admin/service-categories'; // GET, POST
  static String adminServiceCategoryDetail(int id) => '/api/admin/service-categories/$id'; // POST, DELETE
}