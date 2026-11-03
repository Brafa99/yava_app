import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:yava_delivery_driver/features/customer/application/customer_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';

class CustomerLiveMap extends StatefulWidget {
  final CustomerRideState rideState;
  final RideRequestModel? ride;

  // Coordenadas temporales mientras el cliente arma el viaje (Pasos 1-3)
  final double? tempOriginLat;
  final double? tempOriginLng;
  final double? tempDestLat;
  final double? tempDestLng;

  const CustomerLiveMap({
    super.key,
    required this.rideState,
    this.ride,
    this.tempOriginLat,
    this.tempOriginLng,
    this.tempDestLat,
    this.tempDestLng,
  });

  @override
  State<CustomerLiveMap> createState() => _CustomerLiveMapState();
}

class _CustomerLiveMapState extends State<CustomerLiveMap> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  LatLng _currentCustomerPosition = const LatLng(0, 0);
  LatLng? _driverPosition; // Para cuando el conductor esté en camino

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String _googleApiKey = "TU_API_KEY_DE_GOOGLE_AQUI";

  // Estilo Claro/Diurno tipo Uber/Yango (Limpio, sin muchos negocios de Google)
  static const String _lightMapStyle = '''
  [
    {"featureType": "poi", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "transit", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#e0e0e0"}]},
    {"featureType": "water", "elementType": "geometry.fill", "stylers": [{"color": "#b3d1ff"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _initCustomerLocation();
  }

  Future<void> _initCustomerLocation() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentCustomerPosition = LatLng(pos.latitude, pos.longitude);

    if (mounted) {
      setState(() {
        _updateMarkersAndRoute();
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentCustomerPosition, 15.5),
      );
    }
  }

  // --- LÓGICA DE MARCADORES SEGÚN EL ESTADO ---
  void _updateMarkersAndRoute() async {
    final markers = <Marker>{};

    // VARIABLES DE COORDENADAS (Prioriza el viaje creado, sino usa las temporales)
    final originLat =
        widget.ride?.originLatitude ??
        widget.tempOriginLat ??
        _currentCustomerPosition.latitude;
    final originLng =
        widget.ride?.originLongitude ??
        widget.tempOriginLng ??
        _currentCustomerPosition.longitude;
    final destLat = widget.ride?.destinationLatitude ?? widget.tempDestLat;
    final destLng = widget.ride?.destinationLongitude ?? widget.tempDestLng;

    final originPoint = LatLng(originLat, originLng);

    // 1. Siempre mostramos el Origen (Punto de Recogida)
    markers.add(
      Marker(
        markerId: const MarkerId('pickup_marker'),
        position: originPoint,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ), // Pin Azul para el cliente
      ),
    );

    // 2. Si ya hay un destino, lo mostramos
    if (destLat != null && destLng != null) {
      final destPoint = LatLng(destLat, destLng);
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff_marker'),
          position: destPoint,
          infoWindow: const InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ), // Pin Rojo
        ),
      );

      // Calculamos la ruta si estamos en Pasos previos o en pleno Viaje (Paso 7)
      if (widget.rideState != CustomerRideState.driverAccepted &&
          widget.rideState != CustomerRideState.driverArrived) {
        await _drawRealRoute(originPoint, destPoint);
      }
    }

    // 3. Si el Conductor fue aceptado y viene en camino (Pasos 5 y 6)
    if (widget.rideState == CustomerRideState.driverAccepted ||
        widget.rideState == CustomerRideState.driverArrived) {
      // En la vida real, sacarías las coordenadas del driver de Pusher/Websockets o del polling
      // Aquí simulamos que está un poco más arriba para que aparezca en el mapa
      _driverPosition = LatLng(originLat + 0.005, originLng + 0.005);

      markers.add(
        Marker(
          markerId: const MarkerId('driver_car'),
          position: _driverPosition!,
          infoWindow: const InfoWindow(title: 'Tu conductor'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ), // Pin Naranja (Simulando auto)
        ),
      );

      // Ruta desde el Conductor hasta el Cliente
      await _drawRealRoute(_driverPosition!, originPoint);
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
      // Ajustar cámara para que se vean todos los pines
      _fitMapToMarkers();
    }
  }

  // --- TRAZADO DE RUTA REAL CON GOOGLE DIRECTIONS ---
  Future<void> _drawRealRoute(LatLng start, LatLng end) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty && mounted) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route_line'),
          color: const Color(0xFFE50914), // Rojo distintivo de YAVÁ
          width: 5,
          points: polylineCoordinates,
        ),
      };
    }
  }

  void _fitMapToMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLat = _markers.first.position.latitude;
    double maxLng = _markers.first.position.longitude;

    for (final marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng)
        minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng)
        maxLng = marker.position.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80.0, // Padding para que no queden pegados a los bordes
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomerLiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el estado (ej. de elegir destino a conductor en camino), redibuja el mapa
    if (oldWidget.rideState != widget.rideState ||
        oldWidget.tempDestLat != widget.tempDestLat) {
      _updateMarkersAndRoute();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentCustomerPosition,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.setMapStyle(_lightMapStyle);
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
