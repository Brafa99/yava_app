import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/features/transport/routes_service.dart';
import 'package:yava_delivery_driver/features/transport/transport_service.dart';

class DriverTripPage extends StatefulWidget {
  const DriverTripPage({
    super.key,
    required this.tripId,
    required this.driverId,
  });

  final String tripId;
  final String driverId;

  @override
  State<DriverTripPage> createState() => _DriverTripPageState();
}

class _DriverTripPageState extends State<DriverTripPage> {
  StreamSubscription<Position>? _positionSubscription;

  final TransportService _transportService = TransportService();
  final RoutesService _routesService = RoutesService();

  GoogleMapController? _mapController;

  bool _starting = false;
  bool _finishing = false;
  bool _trackingStarted = false;

  Position? _lastPosition;

  LatLng? _origin;
  LatLng? _destination;

  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};

  double _routeDistanceMeters = 0;
  Duration _routeDuration = Duration.zero;

  bool _routeLoading = false;
  bool _routeRequested = false;
  String? _routeKey;

  @override
  void dispose() {
    _stopTracking();
    _mapController?.dispose();
    _routesService.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOCATION
  // ---------------------------------------------------------------------------

  Future<void> _validateLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'La ubicación del dispositivo está desactivada. '
        'Activa el GPS para iniciar el viaje.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('El permiso de ubicación fue denegado.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'El permiso de ubicación está bloqueado. '
        'Actívalo desde los ajustes del teléfono.',
      );
    }
  }

  Future<Position> _getCurrentPosition() async {
    await _validateLocationPermission();

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ---------------------------------------------------------------------------
  // START TRIP
  // ---------------------------------------------------------------------------

  Future<void> _startTrip(Map<String, dynamic> data) async {
    if (_starting || _finishing) {
      return;
    }

    setState(() {
      _starting = true;
    });

    try {
      final customerId = data['customerId']?.toString() ?? '';

      /*
     * IMPORTANTE:
     *
     * El viaje NO debe depender del GPS.
     *
     * Primero activamos el viaje en Firestore.
     * Después intentamos obtener GPS.
     *
     * Esto permite que el demo funcione incluso
     * si la instancia clonada no entrega GPS.
     */
      await _transportService.startTrip(widget.tripId);

      if (!mounted) return;

      /*
     * El viaje ya está ACTIVO.
     * A partir de aquí GPS es complementario.
     */
      setState(() {
        _trackingStarted = false;
      });

      /*
     * Intentamos obtener una posición inicial,
     * pero como máximo durante 5 segundos.
     */
      Position? initialPosition;

      try {
        initialPosition = await _getCurrentPosition().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        debugPrint(
          'GPS tardó demasiado. '
          'El viaje continuará sin ubicación inicial.',
        );
      } catch (e) {
        debugPrint('No se pudo obtener GPS inicial: $e');
      }

      if (!mounted) return;

      /*
     * Si tenemos GPS, mostramos el conductor
     * inmediatamente en el mapa.
     */
      if (initialPosition != null) {
        _lastPosition = initialPosition;

        _updateDriverMarker(initialPosition);

        /*
       * La ubicación es complementaria.
       * Si Firebase tarda o falla, NO bloqueamos
       * el inicio del viaje.
       */
        if (customerId.isNotEmpty) {
          try {
            await _sendPosition(
              initialPosition,
              customerId,
            ).timeout(const Duration(seconds: 3));
          } on TimeoutException {
            debugPrint('Timeout enviando ubicación inicial.');
          } catch (e) {
            debugPrint('Error enviando ubicación inicial: $e');
          }
        }

        if (!mounted) return;

        setState(() {
          _trackingStarted = true;
        });

        await _moveCameraToDriver(initialPosition);

        if (!mounted) return;
      }

      /*
     * Intentamos activar el seguimiento continuo.
     *
     * Incluso si el GPS del clon falla,
     * el viaje ya está activo y se puede finalizar.
     */
      if (customerId.isNotEmpty) {
        _startPositionStream(customerId);
      }

      _showMessage(
        initialPosition != null
            ? 'Viaje iniciado. GPS activo.'
            : 'Viaje iniciado. Seguimiento GPS no disponible temporalmente.',
        isError: false,
      );
    } catch (e) {
      debugPrint('Error al iniciar viaje: $e');

      if (mounted) {
        _showMessage(_friendlyError(e), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _starting = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // TRACKING
  // ---------------------------------------------------------------------------

  Future<void> _startTracking({required String customerId}) async {
    if (_trackingStarted || _starting || _finishing) {
      return;
    }

    try {
      Position? initialPosition;

      try {
        initialPosition = await _getCurrentPosition().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        debugPrint('GPS no respondió al iniciar seguimiento.');
      } catch (e) {
        debugPrint('No se pudo obtener GPS: $e');
      }

      if (!mounted) return;

      if (initialPosition != null) {
        _lastPosition = initialPosition;

        _updateDriverMarker(initialPosition);

        try {
          await _sendPosition(
            initialPosition,
            customerId,
          ).timeout(const Duration(seconds: 3));
        } on TimeoutException {
          debugPrint('Timeout enviando posición inicial.');
        } catch (e) {
          debugPrint('Error enviando posición inicial: $e');
        }

        if (!mounted) return;

        setState(() {
          _trackingStarted = true;
        });

        await _moveCameraToDriver(initialPosition);
      }

      /*
     * El stream GPS se inicia aunque no tengamos
     * una posición inicial.
     *
     * Si posteriormente aparece GPS,
     * comenzará a actualizar normalmente.
     */
      _startPositionStream(customerId);
    } catch (e) {
      debugPrint('Error iniciando seguimiento GPS: $e');

      /*
     * IMPORTANTE:
     *
     * No cambiamos el viaje a error.
     * Firestore ya está en active.
     */
      if (mounted) {
        setState(() {
          _trackingStarted = false;
        });
      }
    }
  }

  void _startPositionStream(String customerId) {
    _positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
            if (!mounted || _finishing || !_trackingStarted) {
              return;
            }

            _lastPosition = position;

            _updateDriverMarker(position);

            await _sendPosition(position, customerId);

            if (!mounted) return;

            setState(() {});

            await _moveCameraToDriver(position);
          },
          onError: (Object error) {
            debugPrint('Error en stream GPS: $error');

            if (mounted) {
              _showMessage(
                'Se perdió temporalmente la señal GPS.',
                isError: true,
              );
            }
          },
        );
  }

  Future<void> _sendPosition(Position position, String customerId) async {
    final heading = position.heading.isFinite ? position.heading : 0.0;

    final speed = position.speed.isFinite && position.speed >= 0
        ? position.speed
        : 0.0;

    try {
      await _transportService
          .updateTripLocation(
            tripId: widget.tripId,
            driverId: widget.driverId,
            customerId: customerId,
            latitude: position.latitude,
            longitude: position.longitude,
            heading: heading,
            speed: speed,
          )
          .timeout(const Duration(seconds: 3));
    } on TimeoutException {
      debugPrint('Timeout enviando ubicación del conductor.');
    } catch (e) {
      debugPrint('Error actualizando ubicación: $e');
    }
  }

  Future<void> _stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _trackingStarted = false;
  }

  // ---------------------------------------------------------------------------
  // MAP MARKERS
  // ---------------------------------------------------------------------------

  void _updateDriverMarker(Position position) {
    final marker = Marker(
      markerId: const MarkerId('driver_location'),
      position: LatLng(position.latitude, position.longitude),
      rotation: position.heading.isFinite ? position.heading : 0,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(
        title: 'Tu ubicación',
        snippet: 'Conductor YAVÁ',
      ),
    );

    _markers.removeWhere(
      (marker) => marker.markerId.value == 'driver_location',
    );

    _markers.add(marker);
  }

  void _updateTripMarkers() {
    final markers = <Marker>{};

    if (_lastPosition != null) {
      final position = _lastPosition!;

      markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: LatLng(position.latitude, position.longitude),
          rotation: position.heading.isFinite ? position.heading : 0,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Conductor YAVÁ',
          ),
        ),
      );
    }

    if (_origin != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('trip_origin'),
          position: _origin!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Origen'),
        ),
      );
    }

    if (_destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('trip_destination'),
          position: _destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destino'),
        ),
      );
    }

    _markers
      ..clear()
      ..addAll(markers);
  }

  // ---------------------------------------------------------------------------
  // ROUTE
  // ---------------------------------------------------------------------------

  Future<void> _loadRoute() async {
    if (_origin == null || _destination == null) {
      _routeRequested = false;
      _routeKey = null;
      _polylines.clear();
      _routeDistanceMeters = 0;
      _routeDuration = Duration.zero;
      return;
    }

    final key =
        '${_origin!.latitude},'
        '${_origin!.longitude}|'
        '${_destination!.latitude},'
        '${_destination!.longitude}';

    if (_routeRequested && _routeKey == key) {
      return;
    }

    _routeRequested = true;
    _routeKey = key;

    if (mounted) {
      setState(() {
        _routeLoading = true;
      });
    }

    try {
      final result = await _routesService.getRoute(
        origin: _origin!,
        destination: _destination!,
      );

      if (!mounted) return;

      if (result == null || result.polylinePoints.isEmpty) {
        _routeRequested = false;
        _routeKey = null;

        setState(() {
          _routeLoading = false;
          _polylines.clear();
          _routeDistanceMeters = 0;
          _routeDuration = Duration.zero;
        });

        return;
      }

      setState(() {
        _routeDistanceMeters = result.distanceMeters;

        _routeDuration = result.duration;

        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('trip_route'),
              points: result.polylinePoints,
              width: 6,
              color: AppColors.navyLight,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            ),
          );

        _routeLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando ruta: $e');

      _routeRequested = false;
      _routeKey = null;

      if (!mounted) return;

      setState(() {
        _routeLoading = false;
        _polylines.clear();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // MAP
  // ---------------------------------------------------------------------------

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitMapToTrip();
      }
    });
  }

  Future<void> _moveCameraToDriver(Position position) async {
    final controller = _mapController;

    if (controller == null) {
      return;
    }

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
            bearing: position.heading.isFinite ? position.heading : 0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error moviendo cámara: $e');
    }
  }

  Future<void> _fitMapToTrip() async {
    final controller = _mapController;

    if (controller == null) {
      return;
    }

    final points = <LatLng>[];

    if (_origin != null) {
      points.add(_origin!);
    }

    if (_destination != null) {
      points.add(_destination!);
    }

    if (_lastPosition != null) {
      points.add(LatLng(_lastPosition!.latitude, _lastPosition!.longitude));
    }

    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 15),
        ),
      );

      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }

      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }

      if (point.longitude < minLng) {
        minLng = point.longitude;
      }

      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (e) {
      debugPrint('Error ajustando mapa: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // TRIP DATA
  // ---------------------------------------------------------------------------

  LatLng? _readLatLng(dynamic value) {
    if (value is GeoPoint) {
      return LatLng(value.latitude, value.longitude);
    }

    if (value is Map) {
      final latitude = value['latitude'];

      final longitude = value['longitude'];

      if (latitude is num && longitude is num) {
        return LatLng(latitude.toDouble(), longitude.toDouble());
      }
    }

    return null;
  }

  Future<void> _prepareTripMap(Map<String, dynamic> data) async {
    final origin = _readLatLng(data['origin']);

    final destination = _readLatLng(data['destination']);

    final originChanged =
        origin?.latitude != _origin?.latitude ||
        origin?.longitude != _origin?.longitude;

    final destinationChanged =
        destination?.latitude != _destination?.latitude ||
        destination?.longitude != _destination?.longitude;

    if (!originChanged && !destinationChanged) {
      return;
    }

    _origin = origin;
    _destination = destination;

    _routeRequested = false;
    _routeKey = null;

    _updateTripMarkers();

    if (mounted) {
      setState(() {});
    }

    if (_origin != null && _destination != null) {
      await _loadRoute();
    }

    await _fitMapToTrip();
  }

  // ---------------------------------------------------------------------------
  // FINISH
  // ---------------------------------------------------------------------------

  Future<void> _finishTrip() async {
    if (_finishing || _starting) {
      return;
    }

    final shouldFinish =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Finalizar viaje'),
              content: const Text(
                '¿Confirmas que llegaste al destino '
                'y deseas finalizar este viaje?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navyLight,
                  ),
                  child: const Text('Finalizar'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldFinish) {
      return;
    }

    setState(() {
      _finishing = true;
    });

    try {
      await _stopTracking();

      await _transportService.completeTrip(widget.tripId);

      if (!mounted) return;

      _showMessage('Viaje finalizado correctamente.', isError: false);

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      context.go('/driver/home');
      
    } catch (e) {
      debugPrint('Error finalizando viaje: $e');

      if (!mounted) return;

      _showMessage(_friendlyError(e), isError: true);

      setState(() {
        _finishing = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // BACK
  // ---------------------------------------------------------------------------

  Future<bool> _handleBack() async {
    if (_finishing) {
      return false;
    }

    final shouldLeave =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Salir del viaje'),
              content: const Text(
                'El viaje está en curso. '
                '¿Deseas salir de esta pantalla?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Salir'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldLeave) {
      await _stopTracking();
    }

    return shouldLeave;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await _handleBack();

        if (!mounted || !shouldLeave) {
          return;
        }

        context.go('/driver/home');
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          title: const Text(
            'Viaje',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          elevation: 0,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .doc(widget.tripId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState('No se pudo cargar el viaje.');
            }

            final trip = snapshot.data;

            if (trip == null || !trip.exists) {
              return _buildErrorState('El viaje ya no existe.');
            }

            final data = trip.data();

            if (data == null) {
              return _buildErrorState('No se encontraron datos del viaje.');
            }

            final status = data['status']?.toString() ?? 'accepted';

            /*
             * Actualizamos mapa de forma asíncrona,
             * pero no hacemos setState directamente
             * durante el build.
             */
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _prepareTripMap(data);
            });

            /*
             * Si el viaje ya aparece como active,
             * iniciamos GPS si todavía no está activo.
             *
             * Esto permite recuperar el tracking incluso
             * si DriverTripPage se abrió después de aceptar.
             */
            if (status == 'active' &&
                !_trackingStarted &&
                !_starting &&
                !_finishing) {
              final customerId = data['customerId']?.toString() ?? '';

              if (customerId.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _trackingStarted || _starting || _finishing) {
                    return;
                  }

                  _startTracking(customerId: customerId);
                });
              }
            }

            final price = _readDouble(data['price']);

            final commission = _readDouble(data['commission']);

            final driverNet = _readDouble(data['driverNet']);

            return Stack(
              children: [
                _buildMap(),

                _buildMapOverlay(
                  status: status,
                  price: price,
                  commission: commission,
                  driverNet: driverNet,
                ),

                _buildBottomPanel(
                  status: status,
                  data: data,
                  price: price,
                  commission: commission,
                  driverNet: driverNet,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap() {
    LatLng initialPosition;

    if (_lastPosition != null) {
      initialPosition = LatLng(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
      );
    } else if (_origin != null) {
      initialPosition = _origin!;
    } else if (_destination != null) {
      initialPosition = _destination!;
    } else {
      initialPosition = const LatLng(-16.5000, -68.1500);
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14),
      onMapCreated: _onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: _markers,
      polylines: _polylines,
      padding: const EdgeInsets.only(
        top: 120,
        bottom: 260,
        left: 16,
        right: 16,
      ),
    );
  }

  Widget _buildMapOverlay({
    required String status,
    required double price,
    required double commission,
    required double driverNet,
  }) {
    final bool active = status == 'active';

    final bool completed = status == 'completed';

    String title;

    if (active) {
      title = 'Viaje en curso';
    } else if (completed) {
      title = 'Viaje finalizado';
    } else {
      title = 'Viaje confirmado';
    }

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: active ? AppColors.navyLight : AppColors.mist,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  active ? Icons.navigation : Icons.local_taxi,
                  color: active ? AppColors.white : AppColors.navyLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_routeLoading)
                      const Text(
                        'Calculando ruta...',
                        style: TextStyle(color: AppColors.muted),
                      )
                    else
                      Text(
                        _routeSummary(),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (price > 0)
                Text(
                  'Bs ${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.navyLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel({
    required String status,
    required Map<String, dynamic> data,
    required double price,
    required double commission,
    required double driverNet,
  }) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Card(
          elevation: 8,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTripFinancialInfo(
                  price: price,
                  commission: commission,
                  driverNet: driverNet,
                  status: status,
                ),
                const SizedBox(height: 12),
                if (status == 'active')
                  _buildActiveContent()
                else if (status == 'accepted')
                  _buildStartButton(data)
                else if (status == 'completed')
                  _buildCompletedContent(
                    price: price,
                    commission: commission,
                    driverNet: driverNet,
                  )
                else
                  _buildStatusCard(status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripFinancialInfo({
    required double price,
    required double commission,
    required double driverNet,
    required String status,
  }) {
    if (price <= 0) {
      return const SizedBox.shrink();
    }

    if (status == 'completed' || driverNet > 0) {
      return Row(
        children: [
          Expanded(
            child: _InfoValue(
              label: 'Precio',
              value: 'Bs ${price.toStringAsFixed(0)}',
            ),
          ),
          Expanded(
            child: _InfoValue(
              label: 'Comisión 20%',
              value: 'Bs ${commission.toStringAsFixed(0)}',
            ),
          ),
          Expanded(
            child: _InfoValue(
              label: 'Neto',
              value: 'Bs ${driverNet.toStringAsFixed(0)}',
              valueColor: AppColors.navyLight,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.payments_outlined, color: AppColors.navyLight),
        const SizedBox(width: 8),
        const Text(
          'Cobro del viaje',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          'Bs ${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveContent() {
    final position = _lastPosition;

    final speedKmh =
        position != null && position.speed.isFinite && position.speed > 0
        ? position.speed * 3.6
        : 0.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.mist,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'GPS activo • ubicación compartida',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (speedKmh > 0)
                Text(
                  '${speedKmh.toStringAsFixed(0)} km/h',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyLight,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildFinishButton(),
      ],
    );
  }

  Widget _buildStartButton(Map<String, dynamic> data) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: _starting || _finishing ? null : () => _startTrip(data),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navyLight,
          disabledBackgroundColor: AppColors.lightGray,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _starting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: Text(
          _starting ? 'Iniciando viaje...' : 'Iniciar viaje',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    /*
     * IMPORTANTE:
     * El botón NO depende de _trackingStarted.
     *
     * Si Firestore dice "active", el viaje puede
     * finalizarse aunque el GPS haya perdido señal.
     */
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: _finishing || _starting ? null : _finishTrip,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navyLight,
          disabledBackgroundColor: AppColors.lightGray,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _finishing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.flag_rounded),
        label: Text(
          _finishing ? 'Finalizando...' : 'Finalizar viaje',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildCompletedContent({
    required double price,
    required double commission,
    required double driverNet,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 30,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Viaje completado correctamente.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    String text;

    switch (status) {
      case 'searching':
        text = 'Esperando conductor.';
        break;

      case 'cancelled':
        text = 'Este viaje fue cancelado.';
        break;

      default:
        text = 'Estado del viaje: $status';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.go('/driver/home'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navyLight,
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _routeSummary() {
    final parts = <String>[];

    if (_routeDistanceMeters > 0) {
      if (_routeDistanceMeters >= 1000) {
        parts.add('${(_routeDistanceMeters / 1000).toStringAsFixed(1)} km');
      } else {
        parts.add('${_routeDistanceMeters.toStringAsFixed(0)} m');
      }
    }

    if (_routeDuration.inMinutes > 0) {
      parts.add('${_routeDuration.inMinutes} min');
    }

    if (parts.isEmpty) {
      return 'Ruta del viaje';
    }

    return parts.join(' • ');
  }

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _friendlyError(Object error) {
    final text = error.toString();

    if (text.contains('ubicación')) {
      return text.replaceFirst('Exception: ', '');
    }

    if (text.contains('permission')) {
      return 'No se pudo obtener permiso de ubicación.';
    }

    if (text.contains('location')) {
      return 'No se pudo obtener la ubicación actual.';
    }

    return text.replaceFirst('Exception: ', '');
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.navyLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _InfoValue extends StatelessWidget {
  const _InfoValue({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
