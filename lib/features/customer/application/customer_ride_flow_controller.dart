import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../transport/models/ride_requests_model.dart';

// --- ESTADOS DEL VIAJE DEL CUSTOMER (Pasajero) ---
enum CustomerRideState {
  selectingDestination, // Paso 1: ¿A dónde vas?
  selectingCategory,    // Paso 2: Elige Auto, Moto, etc.
  confirmingTrip,       // Paso 3: Confirma tarifa y detalles
  searchingDriver,      // Paso 4: Radar buscando ofertas
  driverAccepted,       // Paso 5: Conductor en camino
  driverArrived,        // Paso 6: Conductor afuera
  inProgress,           // Paso 7: Viaje en curso hacia destino
  completed,            // Paso 8: Llegó a destino, calificar
}

class CustomerRideFlowState {
  final CustomerRideState rideState;
  final bool isLoading;
  final String? error;
  
  // El viaje oficial una vez creado en la BD
  final RideRequestModel? currentRide; 
  
  // Datos temporales de construcción del viaje
  final double? originLat;
  final double? originLng;
  final String? originAddress;
  final double? destLat;
  final double? destLng;
  final String? destAddress;
  final int? categoryId;
  final double? offeredFare;

  // Lista de ofertas recibidas de conductores
  final List<dynamic> rideOffers; 

  const CustomerRideFlowState({
    this.rideState = CustomerRideState.selectingDestination,
    this.isLoading = false,
    this.error,
    this.currentRide,
    this.originLat,
    this.originLng,
    this.originAddress,
    this.destLat,
    this.destLng,
    this.destAddress,
    this.categoryId,
    this.offeredFare,
    this.rideOffers = const [],
  });

  CustomerRideFlowState copyWith({
    CustomerRideState? rideState,
    bool? isLoading,
    String? error,
    bool clearError = false,
    RideRequestModel? currentRide,
    double? originLat,
    double? originLng,
    String? originAddress,
    double? destLat,
    double? destLng,
    String? destAddress,
    int? categoryId,
    double? offeredFare,
    List<dynamic>? rideOffers,
  }) {
    return CustomerRideFlowState(
      rideState: rideState ?? this.rideState,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentRide: currentRide ?? this.currentRide,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      originAddress: originAddress ?? this.originAddress,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      destAddress: destAddress ?? this.destAddress,
      categoryId: categoryId ?? this.categoryId,
      offeredFare: offeredFare ?? this.offeredFare,
      rideOffers: rideOffers ?? this.rideOffers,
    );
  }
}

// --- CONTROLADOR ---
class CustomerRideFlowController extends StateNotifier<CustomerRideFlowState> {
  final ApiClient _apiClient;
  Timer? _pollingTimer;
  
  CustomerRideFlowController({required ApiClient apiClient}) 
    : _apiClient = apiClient,
      super(const CustomerRideFlowState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // --- MÉTODOS DE PREPARACIÓN DEL VIAJE (Pasos 1 al 3) ---

  void setOrigin(double lat, double lng, String address) {
    state = state.copyWith(originLat: lat, originLng: lng, originAddress: address);
  }

  void setDestination(double lat, double lng, String address) {
    state = state.copyWith(
      destLat: lat, 
      destLng: lng, 
      destAddress: address,
      rideState: CustomerRideState.selectingCategory, // Avanza al Paso 2
    );
  }

  void setCategory(int categoryId, double initialFare) {
    state = state.copyWith(
      categoryId: categoryId,
      offeredFare: initialFare,
      rideState: CustomerRideState.confirmingTrip, // Avanza al Paso 3
    );
  }

  void updateOfferedFare(double newFare) {
    state = state.copyWith(offeredFare: newFare);
  }

  // Permite volver atrás en los BottomSheets
  void goBackTo(CustomerRideState previousState) {
    state = state.copyWith(rideState: previousState);
  }

  // --- MÉTODOS DE CONEXIÓN CON LA API (Pasos 4 al 8) ---

  // Paso 4: Cliente envía POST para crear solicitud
  Future<void> createRideRequest() async {
    state = state.copyWith(isLoading: true, clearError: true);
    print('🟡 Customer: Creando solicitud de viaje...');

    try {
      final body = {
        'pickup_latitude': state.originLat,
        'pickup_longitude': state.originLng,
        'pickup_address': state.originAddress,
        'dropoff_latitude': state.destLat,
        'dropoff_longitude': state.destLng,
        'dropoff_address': state.destAddress,
        'offered_price': state.offeredFare,
        'service_category_id': state.categoryId,
      };

      final response = await _apiClient.post(
        ApiEndpoints.rideRequests, // Asegúrate de tener este endpoint en tu clase
        body: body,
      );

      final responseData = response['data'] ?? response;
      final newRide = RideRequestModel.fromJson(responseData);

      print('✅ Solicitud creada con ID: ${newRide.id}. Pasando al Radar...');
      state = state.copyWith(
        isLoading: false,
        currentRide: newRide,
        rideState: CustomerRideState.searchingDriver,
      );

      // Inicia a buscar ofertas de conductores cada 4 segundos
      _startPollingOffers(newRide.id);

    } catch (e) {
      print('❌ Error creando solicitud: $e');
      state = state.copyWith(isLoading: false, error: 'No se pudo crear el viaje.');
    }
  }

  // Busca ofertas activamente (Simula WebSockets)
  void _startPollingOffers(int rideId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (state.rideState != CustomerRideState.searchingDriver) {
        timer.cancel();
        return;
      }
      
      try {
        // En YAVÁ deberías tener un endpoint GET /api/customer/my-ride-offers
        final response = await _apiClient.get('/api/client/my-ride-offers'); 
        final data = response['data'] ?? [];
        
        if (mounted) {
          state = state.copyWith(rideOffers: data);
          // Si auto-aceptas al primer driver o el cliente debe elegir, la lógica va aquí.
        }
      } catch (e) {
        print('Silencioso: Error buscando ofertas $e');
      }
    });
  }

  // Paso 5: Cliente acepta la oferta de un driver
  Future<void> acceptDriverOffer(int offerId) async {
    if (state.currentRide == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    print('🟡 Customer: Aceptando oferta $offerId...');

    try {
      await _apiClient.post(
        '/api/ride-requests/${state.currentRide!.id}/accept-offer/$offerId',
        body: {},
      );

      print('✅ Oferta aceptada. Conductor en camino.');
      state = state.copyWith(
        isLoading: false,
        rideState: CustomerRideState.driverAccepted,
      );

      // Inicia a rastrear el estado del viaje (Para saber cuándo llega y cuándo inicia)
      _startPollingRideStatus(state.currentRide!.id);

    } catch (e) {
      print('❌ Error aceptando oferta: $e');
      state = state.copyWith(isLoading: false, error: 'No se pudo aceptar la oferta.');
    }
  }

  // Rastrear el estado del viaje para que la app del Customer cambie sola
  void _startPollingRideStatus(int rideId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Si el viaje terminó, apagamos el timer
      if (state.rideState == CustomerRideState.completed) {
        timer.cancel();
        return;
      }

      try {
        final response = await _apiClient.get(ApiEndpoints.rideDetail(rideId));
        final responseData = response['data'] ?? response;
        final updatedRide = RideRequestModel.fromJson(responseData);
        
        if (!mounted) return;
        
        // Sincronizar estado de Laravel con la App del Customer
        CustomerRideState newState = state.rideState;
        
        switch (updatedRide.status) {
          case 'arrived':
            newState = CustomerRideState.driverArrived; // Paso 6
            break;
          case 'in_progress':
            newState = CustomerRideState.inProgress; // Paso 7
            break;
          case 'completed':
            newState = CustomerRideState.completed; // Paso 8
            break;
        }

        state = state.copyWith(
          currentRide: updatedRide,
          rideState: newState,
        );

      } catch (e) {
        // Fallo de red temporal, seguimos intentando
      }
    });
  }

  // Paso 8: Calificar al Driver
  Future<bool> rateDriver(int rating, String comment) async {
    if (state.currentRide == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _apiClient.post(
        ApiEndpoints.ratings,
        body: {
          'ride_request_id': state.currentRide!.id,
          'rating': rating,
          'comment': comment,
        },
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error enviando calificación');
      return false;
    }
  }
}

// Provider Global
final customerRideFlowProvider = StateNotifierProvider.autoDispose<CustomerRideFlowController, CustomerRideFlowState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerRideFlowController(apiClient: apiClient);
});