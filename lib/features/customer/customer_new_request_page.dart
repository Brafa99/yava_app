import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/core/services/socket_services.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/customer/customer_request_steps_2.dart';

class CustomerNewRequestPage extends ConsumerStatefulWidget {
  const CustomerNewRequestPage({
    super.key,
    this.initialService,
  });

  static const routeName = 'customer-new-request';
  static const routePath = '/customer/new-request';

  final String? initialService;

  @override
  ConsumerState<CustomerNewRequestPage> createState() =>
      _CustomerNewRequestPageState();
}

class _CustomerNewRequestPageState extends ConsumerState<CustomerNewRequestPage>
    with SingleTickerProviderStateMixin {
  /// 1 al 8 -> Representa los 8 mockups completos del flujo de solicitud del Pasajero
  int _currentStep = 1;

  late final AnimationController _radarController;
  Timer? _pollingTimer;

  // Ubicación GPS y Destino (Por defecto Plaza Principal de Concepción)
  LatLng _originLatLng = const LatLng(-16.1311, -62.0298);
  LatLng _destinationLatLng = const LatLng(-16.1395, -62.0215);
  String _originAddress = 'Plaza Principal de Concepción';
  String _destinationAddress = 'Barrio Zapocó / Misión Jesuita';
  bool _loadingGps = true;

  // Categoría seleccionada ('auto', 'moto', 'ejecutivo', 'compartido')
  String _selectedCategorySlug = 'auto';

  // Datos calculados del viaje
  double _distanceKm = 5.8;
  int _estimatedMinutes = 12;
  double _offeredFare = 28.0;
  String _paymentMethod = 'EFECTIVO';
  String _promoCode = '';

  // Estado del viaje creado en Laravel
  bool _isSubmitting = false;
  int? _createdRideId;
  int? _assignedDriverId;
  String _driverName = 'Luis Fernández';
  double _driverRating = 4.9;
  int _driverTrips = 248;
  String _driverVehicle = 'Toyota Rush';
  String _driverPlate = 'Blanco • YAV-4521';
  List<dynamic> _receivedOffers = [];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    if (widget.initialService != null && widget.initialService!.isNotEmpty) {
      _selectedCategorySlug = _normalizeSlug(widget.initialService!);
    }

    _initGpsLocation();
    _initSocketListeners();
  }

  String _normalizeSlug(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('moto')) return 'moto';
    if (lower.contains('trufi') || lower.contains('compartido')) return 'compartido';
    if (lower.contains('interprovincial') || lower.contains('ejecutivo')) {
      return 'ejecutivo';
    }
    return 'auto';
  }

  int get _serviceCategoryId {
    switch (_selectedCategorySlug) {
      case 'moto':
        return 3;
      case 'compartido':
        return 4;
      case 'ejecutivo':
        return 5;
      case 'auto':
      default:
        return 2;
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// 1. Obtiene ubicación GPS real del teléfono
  Future<void> _initGpsLocation() async {
    setState(() => _loadingGps = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (enabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).timeout(const Duration(seconds: 8));

          if (!mounted) return;
          setState(() {
            _originLatLng = LatLng(pos.latitude, pos.longitude);
            _destinationLatLng = LatLng(
              pos.latitude + 0.0085,
              pos.longitude + 0.0075,
            );
            _originAddress = 'Tu ubicación actual (GPS activo)';
            _loadingGps = false;
          });
          _recalculateMetrics();
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loadingGps = false);
      _recalculateMetrics();
    }
  }

  /// 2. Conecta Socket.io para escuchar ofertas del taxista ('cliente:viaje-ofertar')
  void _initSocketListeners() {
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      try {
        SocketService().initSocket(user.id.toString(), 'client');
        SocketService().listenClientEvents(
          onDriverOfferReceived: (data) {
            if (!mounted) return;
            _checkRideStatusAndOffers();
          },
        );
      } catch (_) {}
    }
  }

  void _recalculateMetrics() {
    const earthRadiusKm = 6371.0;
    final dLat = _deg2rad(_destinationLatLng.latitude - _originLatLng.latitude);
    final dLon = _deg2rad(_destinationLatLng.longitude - _originLatLng.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(_originLatLng.latitude)) *
            math.cos(_deg2rad(_destinationLatLng.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final rawDist = (earthRadiusKm * c * 1.35).clamp(1.2, 45.0);

    final baseRate = _selectedCategorySlug == 'moto'
        ? 10.0
        : _selectedCategorySlug == 'ejecutivo'
            ? 25.0
            : _selectedCategorySlug == 'compartido'
                ? 8.0
                : 15.0;

    setState(() {
      _distanceKm = double.parse(rawDist.toStringAsFixed(1));
      _estimatedMinutes = (rawDist * 2.2).round().clamp(4, 90);
      _offeredFare = double.parse((baseRate + rawDist * 2.2).roundToDouble().toStringAsFixed(0));
    });
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  /// Modal interactivo con GoogleMap real para elegir Destino u Origen y dirección
  Future<void> _openDestinationPicker() async {
    final textCtrl = TextEditingController(text: _destinationAddress);
    LatLng tempDest = _destinationLatLng;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona tu destino en el mapa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A1628),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textCtrl,
                    decoration: InputDecoration(
                      labelText: 'Dirección o lugar de destino',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFE50914)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 230,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: tempDest,
                          zoom: 15,
                        ),
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('origin_pick'),
                            position: _originLatLng,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure,
                            ),
                          ),
                          Marker(
                            markerId: const MarkerId('dest_pick'),
                            position: tempDest,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        },
                        onTap: (pos) {
                          setModalState(() => tempDest = pos);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _destinationLatLng = tempDest;
                          if (textCtrl.text.trim().isNotEmpty) {
                            _destinationAddress = textCtrl.text.trim();
                          }
                        });
                        _recalculateMetrics();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Confirmar destino',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 3. Crea la solicitud real en Laravel: POST /api/ride-requests
  Future<void> _confirmAndCreateRideRequest() async {
    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);

      final response = await apiClient.post(
        ApiEndpoints.rideRequests,
        body: {
          'service_category_id': _serviceCategoryId,
          'origin_address': _originAddress,
          'origin_latitude': _originLatLng.latitude,
          'origin_longitude': _originLatLng.longitude,
          'destination_address': _destinationAddress,
          'destination_latitude': _destinationLatLng.latitude,
          'destination_longitude': _destinationLatLng.longitude,
          'distance_km': _distanceKm,
          'estimated_time_minutes': _estimatedMinutes,
          'offered_fare': _offeredFare,
          'payment_method': _paymentMethod,
        },
        requiresAuth: true,
      );

      final rideObj = response is Map
          ? (response['data'] ?? response['ride_request'] ?? response)
          : response;
      final rideId = int.tryParse(rideObj['id']?.toString() ?? '');

      if (!mounted) return;
      setState(() {
        _createdRideId = rideId ?? 1;
        _isSubmitting = false;
        _currentStep = 4; // Pasa a Paso 4: "Buscando tu driver"
      });

      _startPollingRideAndOffers();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear solicitud en el servidor: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// 4. Polling + Socket.io en tiempo real para sincronizar ofertas y estados del viaje
  void _startPollingRideAndOffers() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _currentStep >= 4 && _currentStep < 8) {
        _checkRideStatusAndOffers();
      }
    });
  }

  Future<void> _checkRideStatusAndOffers() async {
    if (_createdRideId == null) return;
    final apiClient = ref.read(apiClientProvider);

    try {
      // A. Revisamos el detalle del viaje GET /api/ride-requests/{id}
      final detailRes = await apiClient.get(
        ApiEndpoints.rideDetail(_createdRideId!),
        requiresAuth: true,
      );
      final ride = detailRes is Map
          ? (detailRes['data'] ?? detailRes['ride_request'] ?? detailRes)
          : detailRes;

      if (ride is Map) {
        final status = (ride['status'] ?? '').toString().toUpperCase();
        final driver = ride['driver'] as Map<String, dynamic>?;
        if (driver != null) {
          _assignedDriverId = int.tryParse(driver['id']?.toString() ?? '');
          final dName =
              '${driver['name'] ?? ''} ${driver['last_name'] ?? ''}'.trim();
          if (dName.isNotEmpty) _driverName = dName;
        }

        final offers = ride['offers'] as List<dynamic>? ?? [];
        if (offers.isNotEmpty && _currentStep == 4) {
          setState(() => _receivedOffers = offers);
        }

        if (!mounted) return;
        if (status == 'ACEPTADO' && _currentStep < 5) {
          setState(() => _currentStep = 5);
        } else if (status == 'EN_ORIGEN' && _currentStep < 6) {
          setState(() => _currentStep = 6);
        } else if (status == 'EN_CURSO' && _currentStep < 7) {
          setState(() => _currentStep = 7);
        } else if (status == 'FINALIZADO' && _currentStep < 8) {
          setState(() => _currentStep = 8);
          _pollingTimer?.cancel();
        }
      }

      // B. Si sigue en Paso 4, consultamos también GET /api/client/my-ride-offers
      if (_currentStep == 4) {
        final myOffersRes = await apiClient.get(
          ApiEndpoints.clientMyRideOffers,
          requiresAuth: true,
        );
        final list = myOffersRes is Map
            ? (myOffersRes['data'] ?? myOffersRes['requests'] ?? [])
            : myOffersRes;
        if (list is List && list.isNotEmpty) {
          for (final item in list) {
            if (item is Map && item['id'].toString() == _createdRideId.toString()) {
              final itemOffers = item['offers'] as List<dynamic>? ?? [];
              if (itemOffers.isNotEmpty && mounted) {
                setState(() => _receivedOffers = itemOffers);
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  /// 5. Aceptar oferta de un conductor: POST /api/ride-requests/{id}/accept-offer/{offerId}
  Future<void> _acceptDriverOffer(Map<String, dynamic> offer) async {
    if (_createdRideId == null) return;
    final offerId = int.tryParse(offer['id']?.toString() ?? '');
    if (offerId == null) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiEndpoints.acceptOffer(_createdRideId!, offerId),
        requiresAuth: true,
      );

      final amount = double.tryParse(
        (offer['offered_amount'] ?? offer['fare'] ?? _offeredFare).toString(),
      );
      final driver = offer['driver'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        if (amount != null) _offeredFare = amount;
        if (driver != null) {
          _assignedDriverId = int.tryParse(driver['id']?.toString() ?? '');
          final name =
              '${driver['name'] ?? ''} ${driver['last_name'] ?? ''}'.trim();
          if (name.isNotEmpty) _driverName = name;
        }
        _currentStep = 5; // Pasa a Paso 5: "¡Conductor encontrado!"
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aceptar oferta: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// 6. Cancelar solicitud o viaje: POST /api/ride-requests/{id}/cancel
  Future<void> _cancelRideRequest() async {
    if (_createdRideId != null) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          ApiEndpoints.cancelRide(_createdRideId!),
          body: {'cancellation_reason': 'Cancelado por el pasajero'},
          requiresAuth: true,
        );
      } catch (_) {}
    }
    _pollingTimer?.cancel();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customer/home');
    }
  }

  /// 7. Calificar al conductor al finalizar: POST /api/ratings
  Future<void> _submitDriverRating(int stars) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _assignedDriverId == null) return;
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiEndpoints.ratings,
        body: {
          if (_createdRideId != null) 'ride_id': _createdRideId,
          'driver_id': _assignedDriverId,
          'client_id': user.id,
          'evaluator_role': 'client',
          'score': stars,
          'comment': 'Excelente servicio con YAVÁ',
          'is_anonymous': false,
        },
        requiresAuth: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Gracias por calificar a tu conductor!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (_) {}
  }

  String get _currentBgAsset =>
      'assets/images/request/req_step_${_currentStep}_bg.png';

  void _handleBackTap() {
    if (_currentStep > 1 && _currentStep <= 3) {
      setState(() => _currentStep--);
    } else if (_currentStep >= 4 && _currentStep < 8) {
      _cancelRideRequest();
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/customer/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Stack(
            children: [
              // 1. Cabecera dinámica según el Paso (1 al 8)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _currentStep == 1 ? 470 : 380,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Image.asset(
                    _currentBgAsset,
                    key: ValueKey<int>(_currentStep),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/concepcion_catedral_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // 2. Fundido blanco para integrar el cuerpo inferior
              Positioned(
                top: _currentStep == 1 ? 390 : 285,
                left: 0,
                right: 0,
                height: 95,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Contenido de cada Paso
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(height: topPadding + 6),
                    _buildTopNavigationRow(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildCurrentStepContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          if (_currentStep > 1)
            GestureDetector(
              onTap: _handleBackTap,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF0A1628),
                  size: 22,
                ),
              ),
            )
          else
            const SizedBox(width: 42, height: 42),

          const Spacer(),

          // Indicador "Paso 2 de 8" en el Paso 2
          if (_currentStep == 2)
            Column(
              children: [
                SizedBox(
                  width: 170,
                  height: 18,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.38,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE50914),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (i) {
                          final active = i <= 1;
                          return Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFFE50914) : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Paso 2 de 8',
                  style: TextStyle(
                    color: Color(0xFF0A1628),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // Botón "Editar" en el Paso 3
          if (_currentStep == 3)
            GestureDetector(
              onTap: () => setState(() => _currentStep = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0A1628)),
                    SizedBox(width: 5),
                    Text(
                      'Editar',
                      style: TextStyle(
                        color: Color(0xFF0A1628),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1WhereTo();
      case 2:
        return _buildStep2HowToTravel();
      case 3:
        return _buildStep3ConfirmTrip();
      case 4:
        return _buildStep4SearchingDriver();
      default:
        return CustomerActiveAndCompletedSteps(
          currentStep: _currentStep,
          originLatLng: _originLatLng,
          destinationLatLng: _destinationLatLng,
          originAddress: _originAddress,
          destinationAddress: _destinationAddress,
          distanceKm: _distanceKm,
          estimatedMinutes: _estimatedMinutes,
          offeredFare: _offeredFare,
          paymentMethod: _paymentMethod,
          driverName: _driverName,
          driverRating: _driverRating,
          driverTrips: _driverTrips,
          driverVehicle: _driverVehicle,
          driverPlate: _driverPlate,
          onAdvanceStepDemo: (nextStep) => setState(() => _currentStep = nextStep),
          onCancelTrip: _cancelRideRequest,
          onRateDriver: _submitDriverRating,
          onBackHome: () => context.go('/customer/home'),
          onRepeatTrip: () => setState(() => _currentStep = 1),
        );
    }
  }

  // ===========================================================================
  // PASO 1: "¿A DÓNDE VAS HOY?" (Réplica exacta de Paso1_3.png)
  // ===========================================================================
  Widget _buildStep1WhereTo() {
    final quickCategories = [
      ('auto', 'Auto', 'Económico\ny cómodo', Icons.directions_car_filled_outlined, false),
      ('moto', 'Moto', 'Más rápido\nen la ciudad', Icons.two_wheeler_rounded, false),
      ('ejecutivo', 'Ejecutivo', 'Mayor\ncomodidad', Icons.directions_car_outlined, true),
      ('compartido', 'Compartido', 'Viaja y\nahorra', Icons.groups_outlined, false),
    ];

    return SingleChildScrollView(
      key: const ValueKey('req_step_1'),
      padding: const EdgeInsets.fromLTRB(20, 175, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿A dónde\nvas hoy?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.04,
              letterSpacing: -0.8,
              shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Muévete de forma segura,\nrápida y cómoda con YAVÁ.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
              shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 22),

          // Tarjeta Blanca de Origen y Destino
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Origen
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE50914), width: 4),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tu ubicación actual',
                            style: TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _loadingGps ? 'Detectando ubicación...' : _originAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _initGpsLocation,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFF475569),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        child: Center(
                          child: Text(
                            '⋮',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade200,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Destino (Abre selector con GoogleMap)
                InkWell(
                  onTap: _openDestinationPicker,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFE50914),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿A dónde vas?',
                              style: TextStyle(
                                color: Color(0xFF0A1628),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _destinationAddress.isEmpty
                                  ? 'Ingresa tu destino'
                                  : _destinationAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF475569),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 Tarjetas Inferiores de Categoría Rápida
          Row(
            children: quickCategories.map((cat) {
              final isSelected = _selectedCategorySlug == cat.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategorySlug = cat.$1);
                      _recalculateMetrics();
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 118,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF5F5)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE50914)
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(cat.$4, size: 30, color: const Color(0xFF0A1628)),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  cat.$2,
                                  style: const TextStyle(
                                    color: Color(0xFF0A1628),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cat.$3,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 9.5,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected || cat.$5)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE50914),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat.$5 && !isSelected
                                    ? Icons.workspace_premium_rounded
                                    : Icons.check_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Botón Rojo: Siguiente ->
          _buildPrimaryRedButton(
            label: 'Siguiente',
            onTap: () => setState(() => _currentStep = 2),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PASO 2: "¿CÓMO QUIERES VIAJAR HOY?" (Réplica de Paso2_4.png con Grid 2x2)
  // ===========================================================================
  Widget _buildStep2HowToTravel() {
    final cards = [
      (
        'auto',
        'Auto',
        'Económico y cómodo\nen tu día a día.',
        'assets/images/vehicles/auto_yava.png',
        '1-4',
        'Equipaje',
        Icons.work_outline_rounded,
        false,
      ),
      (
        'moto',
        'Moto',
        'Más rápido\nen la ciudad.',
        'assets/images/vehicles/moto_yava.png',
        '1',
        'Con casco',
        Icons.sports_motorsports_outlined,
        false,
      ),
      (
        'ejecutivo',
        'Ejecutivo',
        'Mayor comodidad\ny exclusividad.',
        'assets/images/vehicles/taxi_ejecutivo_yava.png',
        '1-4',
        'Equipaje',
        Icons.work_outline_rounded,
        true,
      ),
      (
        'compartido',
        'Compartido',
        'Viaja y ahorra.',
        'assets/images/vehicles/carga_yava.png',
        '1-4',
        'Equipaje',
        Icons.work_outline_rounded,
        false,
      ),
    ];

    return SingleChildScrollView(
      key: const ValueKey('req_step_2'),
      padding: const EdgeInsets.fromLTRB(20, 82, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo quieres\nviajar hoy?',
            style: TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.06,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige la opción que mejor se\nadapte a tus necesidades.',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),

          // Grid 2x2 de Vehículos con tus assets
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.88,
            children: cards.map((c) {
              final isSelected = _selectedCategorySlug == c.$1;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategorySlug = c.$1);
                  _recalculateMetrics();
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFF5F5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE50914)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.8 : 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                c.$4,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.directions_car_filled_rounded,
                                  size: 54,
                                  color: Color(0xFF0A1628),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c.$2,
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.$3,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 15,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                c.$5,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                c.$7,
                                size: 15,
                                color: const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  c.$6,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isSelected || c.$8)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE50914),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            c.$8 && !isSelected
                                ? Icons.workspace_premium_rounded
                                : Icons.check_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _buildPrimaryRedButton(
            label: 'Siguiente',
            onTap: () => setState(() => _currentStep = 3),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PASO 3: "CONFIRMA TU VIAJE" (Réplica de Paso3_3.png + GoogleMap real)
  // ===========================================================================
  Widget _buildStep3ConfirmTrip() {
    final midPoint = LatLng(
      (_originLatLng.latitude + _destinationLatLng.latitude) / 2,
      (_originLatLng.longitude + _destinationLatLng.longitude) / 2,
    );

    return SingleChildScrollView(
      key: const ValueKey('req_step_3'),
      padding: const EdgeInsets.fromLTRB(20, 74, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tu\nviaje',
            style: TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 33,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revisa los detalles de tu viaje\nantes de solicitar un conductor.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Mapa GoogleMap con Ruta Roja + Etiquetas de Origen y Destino
          Container(
            height: 148,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: midPoint,
                      zoom: 14.2,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('confirm_route'),
                        color: const Color(0xFFE50914),
                        width: 4,
                        points: [
                          _originLatLng,
                          midPoint,
                          _destinationLatLng,
                        ],
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('orig'),
                        position: _originLatLng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                      Marker(
                        markerId: const MarkerId('dest'),
                        position: _destinationLatLng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                  ),
                  // Etiqueta flotante Origen
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _mapLabelBubble('Origen', _originAddress),
                  ),
                  // Etiqueta flotante Destino
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: _mapLabelBubble('Destino', _destinationAddress),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Barra de 3 métricas: 12 min | 5.8 km | Bs 28 (Editable al tocar)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 22, color: Color(0xFF0A1628)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_estimatedMinutes min',
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Tiempo estimado',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.route_outlined, size: 22, color: Color(0xFF0A1628)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_distanceKm km',
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Distancia',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: GestureDetector(
                    onTap: _showEditFareDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on_outlined, size: 22, color: Color(0xFF0A1628)),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bs ${_offeredFare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF0A1628),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Tarifa estimada ⓘ',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tarjeta del Vehículo Seleccionado + Botón "Cambiar >"
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 95,
                  height: 60,
                  child: Image.asset(
                    _selectedCategorySlug == 'moto'
                        ? 'assets/images/vehicles/moto_yava.png'
                        : 'assets/images/vehicles/auto_yava.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 46,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategorySlug.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _currentStep = 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Cambiar >',
                                style: TextStyle(
                                  color: Color(0xFFE50914),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Económico y cómodo\nen tu día a día.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          Text(' 1-4  ', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          Icon(Icons.work_outline, size: 14, color: Color(0xFF64748B)),
                          Text(' Equipaje  ', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          Icon(Icons.ac_unit_rounded, size: 14, color: Color(0xFF64748B)),
                          Expanded(
                            child: Text(
                              ' Aire acond.',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Método de pago (EFECTIVO, QR, TARJETA)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de pago',
                  style: TextStyle(
                    color: Color(0xFF0A1628),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Color(0xFF0A1628), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _paymentMethod,
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Pago al finalizar el viaje',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _paymentMethod = _paymentMethod == 'EFECTIVO'
                              ? 'QR'
                              : _paymentMethod == 'QR'
                                  ? 'TARJETA'
                                  : 'EFECTIVO';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Cambiar >',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Código promocional (opcional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined, color: Color(0xFF0A1628), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Código promocional (opcional)',
                        style: TextStyle(
                          color: Color(0xFF0A1628),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _promoCode.isEmpty ? 'Ingresa tu código' : _promoCode,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _buildPrimaryRedButton(
            label: 'Confirmar viaje',
            isLoading: _isSubmitting,
            onTap: _confirmAndCreateRideRequest,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditFareDialog() async {
    final ctrl = TextEditingController(text: _offeredFare.toStringAsFixed(0));
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Proponer tarifa (Bs)'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monto en Bolivianos (Bs)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                setState(() => _offeredFare = val);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _mapLabelBubble(String title, String subtitle) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 9.5,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PASO 4: "BUSCANDO TU DRIVER" (Réplica de Paso4_2.png + Radar + Ofertas en vivo)
  // ===========================================================================
  Widget _buildStep4SearchingDriver() {
    return SingleChildScrollView(
      key: const ValueKey('req_step_4'),
      padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buscando\ntu driver',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              height: 1.04,
              shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Estamos conectando con el\nconductor más cercano a ti.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              height: 1.28,
              shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          // Radar animado sobre GoogleMap real con conductores alrededor
          GestureDetector(
            onTap: () {
              // Permite avanzar en vivo durante la presentación si aún no hay otro celular ofertando
              setState(() => _currentStep = 5);
            },
            child: SizedBox(
              height: 255,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Opacity(
                      opacity: 0.55,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _originLatLng,
                          zoom: 15,
                        ),
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        liteModeEnabled: true,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(235, 235),
                        painter: _RadarSweepPainter(_radarController.value),
                      );
                    },
                  ),
                  // Auto central
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE50914), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE50914).withValues(alpha: 0.25),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 38,
                      color: Color(0xFF0A1628),
                    ),
                  ),
                  // 4 Marcadores de conductores cercanos
                  const Positioned(top: 32, left: 38, child: _NearbyCarBadge()),
                  const Positioned(top: 24, right: 34, child: _NearbyCarBadge()),
                  const Positioned(bottom: 34, left: 50, child: _NearbyCarBadge()),
                  const Positioned(bottom: 26, right: 44, child: _NearbyCarBadge()),
                ],
              ),
            ),
          ),

          // Si llegan ofertas reales por Socket.io / Laravel, se muestran aquí para aceptarlas
          if (_receivedOffers.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Ofertas de conductores disponibles:',
              style: TextStyle(
                color: Color(0xFF0A1628),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            ..._receivedOffers.take(3).map((offer) {
              final mapOffer = offer as Map<String, dynamic>;
              final amount =
                  mapOffer['offered_amount'] ?? mapOffer['fare'] ?? _offeredFare;
              final driver = mapOffer['driver'] as Map<String, dynamic>?;
              final dName = driver != null
                  ? '${driver['name'] ?? 'Conductor'} ${driver['last_name'] ?? ''}'
                  : 'Socio Conductor YAVÁ';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE50914)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_taxi_rounded, color: Color(0xFFE50914)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A1628),
                            ),
                          ),
                          Text(
                            'Tarifa ofertada: Bs $amount',
                            style: const TextStyle(
                              color: Color(0xFFE50914),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _acceptDriverOffer(mapOffer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 12),

          // Barra de 3 indicadores: ~ 1-3 min | Conductores | Seguro
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded, size: 22, color: Color(0xFF0A1628)),
                      SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '~ 1-3 min',
                            style: TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Tiempo de espera',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined, size: 22, color: Color(0xFF0A1628)),
                      SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conductores',
                            style: TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Cerca de ti',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 22, color: Color(0xFF0A1628)),
                      SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seguro',
                            style: TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'y confiable',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón Rosado con Borde Rojo: Cancelar solicitud X
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: _cancelRideRequest,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF5F5),
                side: const BorderSide(color: Color(0xFFE50914), width: 1.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 22),
                  Text(
                    'Cancelar solicitud',
                    style: TextStyle(
                      color: Color(0xFFE50914),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.close_rounded, color: Color(0xFFE50914), size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryRedButton({
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE50914),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0xFFE50914).withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 24),
                ],
              ),
      ),
    );
  }
}

class _NearbyCarBadge extends StatelessWidget {
  const _NearbyCarBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE50914), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: const Icon(
        Icons.directions_car_filled_rounded,
        color: Color(0xFF0A1628),
        size: 18,
      ),
    );
  }
}

class _RadarSweepPainter extends CustomPainter {
  final double progress;
  _RadarSweepPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final circlePaint = Paint()
      ..color = const Color(0xFFE50914).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, maxRadius * 0.55, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.80, circlePaint);
    canvas.drawCircle(center, maxRadius, circlePaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          const Color(0xFFE50914).withValues(alpha: 0.45),
        ],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.72));

    canvas.drawCircle(center, maxRadius * 0.72, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarSweepPainter oldDelegate) =>
      oldDelegate.progress != progress;
}