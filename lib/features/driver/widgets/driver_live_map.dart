import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yava_delivery_driver/features/driver/application/driver_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';

class DriverLiveMap extends StatefulWidget {
  final DriverRideState rideState;
  final RideRequestModel ride;

  const DriverLiveMap({super.key, required this.rideState, required this.ride});

  @override
  State<DriverLiveMap> createState() => _DriverLiveMapState();
}

class _DriverLiveMapState extends State<DriverLiveMap> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  LatLng _currentCarPosition = const LatLng(0, 0);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Reemplaza esto con tu verdadera API Key de Google Maps
  final String _googleApiKey = "AIzaSyBYmjLGgWK_C9nrt5b_Mu-0WKYv5S-_gHI";

  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#081528"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a3646"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#0f2c4a"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#143f66"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  void _startLiveTracking() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentCarPosition = LatLng(pos.latitude, pos.longitude);

    // Al obtener la primera ubicación, calculamos la ruta real
    _updateMarkersAndRealRoute();

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 3,
          ),
        ).listen((Position newPosition) {
          if (!mounted) return;
          setState(() {
            _currentCarPosition = LatLng(
              newPosition.latitude,
              newPosition.longitude,
            );
            _updateMarkersOnly(); // Solo movemos el auto, no recalculamos toda la ruta para ahorrar peticiones a la API
          });

          if (widget.rideState == DriverRideState.accepted ||
              widget.rideState == DriverRideState.inProgress) {
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _currentCarPosition,
                  zoom: 17.5,
                  bearing: newPosition.heading,
                  tilt: 45.0,
                ),
              ),
            );
          }
        });
  }

  // Actualiza solo los marcadores (ideal para el stream del GPS)
  void _updateMarkersOnly() {
    final markers = <Marker>{};

    // 1. Marcador del Auto (Tinte Azul)
    markers.add(
      Marker(
        markerId: const MarkerId('car_marker'),
        position: _currentCarPosition,
        infoWindow: const InfoWindow(title: 'Tú (Conductor)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ), // Pin Azul
      ),
    );

    // 2. Marcador Origen (Cliente) - (Tinte Verde)
    if (widget.rideState != DriverRideState.inProgress) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: LatLng(
            widget.ride.originLatitude ?? 0.0,
            widget.ride.originLongitude ?? 0.0,
          ),
          infoWindow: const InfoWindow(title: 'Punto de recogida'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ), // Pin Verde
        ),
      );
    }

    // 3. Marcador Destino - (Tinte Rojo)
    if (widget.rideState == DriverRideState.inProgress ||
        widget.rideState == DriverRideState.newRequest) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff_marker'),
          position: LatLng(
            widget.ride.destinationLatitude ?? 0.0,
            widget.ride.destinationLongitude ?? 0.0,
          ),
          infoWindow: const InfoWindow(title: 'Destino final'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ), // Pin Rojo
        ),
      );
    }

    _markers = markers;
  }

  // Consulta a Google Maps Directions para la Polyline real
  Future<void> _updateMarkersAndRealRoute() async {
    _updateMarkersOnly();

    LatLng destinationPoint;

    // Si estamos yendo a recoger al cliente, la meta es el Origen.
    if (widget.rideState == DriverRideState.newRequest ||
        widget.rideState == DriverRideState.accepted) {
      destinationPoint = LatLng(
        widget.ride.originLatitude ?? 0.0,
        widget.ride.originLongitude ?? 0.0,
      );
    }
    // Si el cliente ya subió, la meta es el Destino Final.
    else {
      destinationPoint = LatLng(
        widget.ride.destinationLatitude ?? 0.0,
        widget.ride.destinationLongitude ?? 0.0,
      );
    }

    // Si las coordenadas son 0.0 (modelo vacío), abortamos la ruta
    if (destinationPoint.latitude == 0.0) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(
          _currentCarPosition.latitude,
          _currentCarPosition.longitude,
        ),
        destination: PointLatLng(
          destinationPoint.latitude,
          destinationPoint.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty && mounted) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('real_route'),
            color: const Color(0xFF0075FF),
            width: 5,
            points: polylineCoordinates,
          ),
        };
      });
    }
  }

  @override
  void didUpdateWidget(covariant DriverLiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el estado del viaje (ej: de ir por el cliente a ir al destino), recalculamos ruta real
    if (oldWidget.rideState != widget.rideState) {
      _updateMarkersAndRealRoute();
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
        target: _currentCarPosition,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.setMapStyle(_darkMapStyle);
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
