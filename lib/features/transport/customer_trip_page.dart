import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/features/transport/routes_service.dart';
import 'package:yava_delivery_driver/features/transport/transport_service.dart';

class CustomerTripPage extends StatefulWidget {
  const CustomerTripPage({
    super.key,
    required this.tripId,
    required this.customerId,
  });

  final String tripId;
  final String customerId;

  @override
  State<CustomerTripPage> createState() => _CustomerTripPageState();
}

class _CustomerTripPageState extends State<CustomerTripPage> {
  GoogleMapController? _mapController;

  StreamSubscription<DatabaseEvent>? _locationSubscription;

  Timer? _driverAnimationTimer;
  String? _driverId;

  final Set<Marker> _markers = {};
  final RoutesService _routesService = RoutesService();

  final Set<Polyline> _polylines = {};

  double _routeDistanceMeters = 0;
  Duration _routeDuration = Duration.zero;

  bool _routeLoading = false;
  bool _routeRequested = false;
  String? _routeKey;
  LatLng? _origin;
  LatLng? _destination;
  LatLng? _driverLocation;
  LatLng? _lastDriverLocation;

  double _driverHeading = 0;
  double _driverSpeed = 0;

  bool _trackingStarted = false;
  bool _finishing = false;
  bool _ratingShown = false;
  bool _ratingOpening = false;

  /// Cuando está activo, la cámara acompaña al conductor.
  bool _followDriver = true;

  /// Evita reajustar los bounds del mapa constantemente.
  bool _initialMapFitted = false;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _driverAnimationTimer?.cancel();
    _mapController?.dispose();
    _routesService.dispose();
    super.dispose();
  }

  Future<void> _loadRoute(LatLng origin, LatLng destination) async {
    final key =
        '${origin.latitude},${origin.longitude}'
        '_'
        '${destination.latitude},${destination.longitude}';

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
        origin: origin,
        destination: destination,
      );

      if (!mounted) return;

      if (result == null || result.polylinePoints.isEmpty) {
        _routeRequested = false;
        _routeKey = null;

        setState(() {
          _routeLoading = false;
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
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

        _routeLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fitMapToTrip();
        }
      });
    } catch (e) {
      _routeRequested = false;
      _routeKey = null;

      setState(() {
        _routeLoading = false;
      });
    }
  }

  void _startTracking() {
    if (_trackingStarted) return;

    _trackingStarted = true;

    _locationSubscription = FirebaseDatabase.instance
        .ref('active_trips/${widget.tripId}')
        .onValue
        .listen((event) {
          final value = event.snapshot.value;

          if (value is! Map) return;

          final lat = _readNum(value['latitude']);

          final lng = _readNum(value['longitude']);

          if (lat == null || lng == null) return;

          final position = LatLng(lat, lng);

          final heading = _readNum(value['heading']) ?? 0;

          final speed = _readNum(value['speed']) ?? 0;

          final safeHeading = heading.isFinite ? heading : 0.0;

          final safeSpeed = speed.isFinite && speed >= 0 ? speed : 0.0;

          _animateDriverTo(position, heading: safeHeading, speed: safeSpeed);
        });
  }

  void _animateDriverTo(
    LatLng target, {
    required double heading,
    required double speed,
  }) {
    final previous = _driverLocation;

    _lastDriverLocation = previous;
    _driverLocation = target;
    _driverHeading = heading;
    _driverSpeed = speed;

    _driverAnimationTimer?.cancel();

    if (previous == null) {
      if (mounted) {
        setState(() {
          _updateDriverMarker(target);
        });
      }

      _followDriverCamera(target);

      return;
    }

    final start = previous;

    const duration = Duration(milliseconds: 650);

    const frameDuration = Duration(milliseconds: 40);

    final totalFrames = duration.inMilliseconds ~/ frameDuration.inMilliseconds;

    var frame = 0;

    _driverAnimationTimer = Timer.periodic(frameDuration, (timer) {
      frame++;

      final progress = (frame / totalFrames).clamp(0.0, 1.0);

      final easedProgress = Curves.easeOut.transform(progress);

      final latitude =
          start.latitude + (target.latitude - start.latitude) * easedProgress;

      final longitude =
          start.longitude +
          (target.longitude - start.longitude) * easedProgress;

      final animatedPosition = LatLng(latitude, longitude);

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _driverLocation = animatedPosition;

        _updateDriverMarker(animatedPosition);
      });

      if (_followDriver) {
        _followDriverCamera(animatedPosition);
      }

      if (progress >= 1.0) {
        timer.cancel();

        if (mounted) {
          setState(() {
            _driverLocation = target;

            _updateDriverMarker(target);
          });

          if (_followDriver) {
            _followDriverCamera(target);
          }
        }
      }
    });
  }

  void _updateDriverMarker(LatLng position) {
    _markers.removeWhere((marker) => marker.markerId.value == 'driver');

    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        rotation: _driverHeading,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(
          title: 'Conductor',
          snippet: 'Ubicación en vivo',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _followDriverCamera(LatLng position) {
    if (!_followDriver) return;

    final controller = _mapController;

    if (controller == null) {
      return;
    }

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16.5,
          bearing: _driverHeading,
          tilt: 35,
        ),
      ),
    );
  }

  void _toggleFollowDriver() {
    setState(() {
      _followDriver = !_followDriver;
    });

    if (_followDriver && _driverLocation != null) {
      _followDriverCamera(_driverLocation!);
    }
  }

  Future<void> _finishTrip() async {
    if (_finishing) return;

    setState(() {
      _finishing = true;
    });

    try {
      await TransportService().completeTrip(widget.tripId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _finishing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo finalizar el viaje: $e'),
          backgroundColor: AppColors.error,
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _finishing = false;
    });
  }

  Future<void> _showRating(String driverId) async {
    if (_ratingShown || _ratingOpening) {
      return;
    }

    if (driverId.isEmpty) {
      return;
    }

    _ratingOpening = true;

    int rating = 5;

    final commentController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogBuilderContext, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text(
                  'Califica tu viaje',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¿Cómo fue tu experiencia con el conductor?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedInk),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final value = index + 1;

                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              rating = value;
                            });
                          },
                          icon: Icon(
                            value <= rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.sunrise,
                            size: 34,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Comentario opcional',
                        filled: true,
                        fillColor: AppColors.sand,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
                actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Después',
                      style: TextStyle(
                        color: AppColors.mutedInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      try {
                        await TransportService().createRating(
                          tripId: widget.tripId,
                          customerId: widget.customerId,
                          driverId: driverId,
                          rating: rating,
                          comment: commentController.text.trim(),
                        );

                        if (!dialogContext.mounted) {
                          return;
                        }

                        _ratingShown = true;

                        Navigator.of(dialogContext).pop();

                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (!dialogBuilderContext.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(dialogBuilderContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No se pudo guardar la calificación: $e',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Calificar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      commentController.dispose();

      _ratingOpening = false;
    }
  }

  void _fitMapToTrip() {
    if (_mapController == null) {
      return;
    }

    final points = <LatLng>[
      if (_origin != null) _origin!,
      if (_destination != null) _destination!,
      if (_driverLocation != null) _driverLocation!,
    ];

    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
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

    final latPadding = math.max((maxLat - minLat) * 0.15, 0.002);

    final lngPadding = math.max((maxLng - minLng) * 0.15, 0.002);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    _initialMapFitted = true;
  }

  void _scheduleStaticMarkersUpdate({
    required LatLng? origin,
    required LatLng? destination,
  }) {
    final originChanged = _origin != origin;

    final destinationChanged = _destination != destination;

    if (!originChanged && !destinationChanged) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      bool changed = false;

      if (origin != null && _origin == null) {
        _origin = origin;

        _markers.add(
          Marker(
            markerId: const MarkerId('origin'),
            position: origin,
            infoWindow: const InfoWindow(title: 'Origen'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );

        changed = true;
      }

      if (destination != null && _destination == null) {
        _destination = destination;

        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            infoWindow: const InfoWindow(title: 'Destino'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );

        changed = true;
      }

      if (changed) {
        setState(() {});
      }

      if (!_initialMapFitted) {
        _fitMapToTrip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Mi viaje',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.navy),
            );
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return _buildWaiting();
          }

          final status = (data['status'] as String? ?? 'accepted')
              .toLowerCase();

          final driverId = data['driverId'] as String? ?? '';

          _driverId = driverId;

          final origin = _readLocation(data['origin']);

          final destination = _readLocation(data['destination']);

          _scheduleStaticMarkersUpdate(
            origin: origin,
            destination: destination,
          );

          if (origin != null && destination != null) {
            _loadRoute(origin, destination);
          }

          if (status == 'active') {
            _startTracking();
          }

          if (status == 'completed' &&
              driverId.isNotEmpty &&
              !_ratingShown &&
              !_ratingOpening) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showRating(driverId);
              }
            });
          }

          final mapTarget =
              _driverLocation ??
              _origin ??
              _destination ??
              const LatLng(-16.5000, -68.1500);

          final price = _readDouble(data['price']);

          final commission = _readDouble(data['commission']);

          final driverNet = _readDouble(data['driverNet']);

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: mapTarget,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _fitMapToTrip();
                        });
                      },
                      markers: _markers,
                      polylines: _polylines,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                    ),

                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildStatusCard(status),
                    ),

                    if (status == 'active')
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: _buildLiveInfoCard(),
                      ),

                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        heroTag: 'customer_trip_location',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.navy,
                        elevation: 4,
                        onPressed: _toggleFollowDriver,
                        child: Icon(
                          _followDriver
                              ? Icons.gps_fixed_rounded
                              : Icons.my_location_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildBottomPanel(
                status: status,
                price: price,
                commission: commission,
                driverNet: driverNet,
                origin: origin,
                destination: destination,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLiveInfoCard() {
    final speedKmh = _driverSpeed * 3.6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.navigation_rounded,
              size: 17,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conductor en vivo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                speedKmh > 1
                    ? '${speedKmh.toStringAsFixed(0)} km/h'
                    : 'Actualizando ubicación...',
                style: const TextStyle(fontSize: 10, color: AppColors.mutedInk),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final isActive = status == 'active';

    final isCompleted = status == 'completed';

    final title = isCompleted
        ? 'Viaje finalizado'
        : isActive
        ? 'Conductor en camino'
        : 'Viaje confirmado';

    final subtitle = isCompleted
        ? 'Tu viaje ha terminado'
        : isActive
        ? 'Ubicación compartida en tiempo real'
        : 'Esperando inicio del viaje';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.mist
                  : isActive
                  ? AppColors.mist
                  : AppColors.sand,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : isActive
                  ? Icons.navigation_rounded
                  : Icons.schedule_rounded,
              color: isCompleted
                  ? AppColors.success
                  : isActive
                  ? AppColors.navy
                  : AppColors.warning,
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
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel({
    required String status,
    required double price,
    required double commission,
    required double driverNet,
    required LatLng? origin,
    required LatLng? destination,
  }) {
    final isCompleted = status == 'completed';

    final isActive = status == 'active';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_taxi_rounded,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servicio YAVÁ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Transporte',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 11, color: AppColors.mutedInk),
                    ),
                    Text(
                      'Bs ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (origin != null || destination != null) ...[
              const SizedBox(height: 16),
              _buildRouteSummary(),
            ],

            // if (isCompleted) ...[
            //   const SizedBox(
            //     height: 14,
            //   ),
            //   Container(
            //     width:
            //         double.infinity,
            //     padding:
            //         const EdgeInsets
            //             .all(12),
            //     decoration:
            //         BoxDecoration(
            //       color:
            //           AppColors.mist,
            //       borderRadius:
            //           BorderRadius
            //               .circular(
            //         14,
            //       ),
            //     ),
            //     child: Row(
            //       children: [
            //         const Icon(
            //           Icons
            //               .check_circle_rounded,
            //           color:
            //               AppColors
            //                   .success,
            //           size: 19,
            //         ),
            //         const SizedBox(
            //           width: 9,
            //         ),
            //         const Expanded(
            //           child: Text(
            //             'Viaje completado correctamente',
            //             style:
            //                 TextStyle(
            //               color:
            //                   AppColors
            //                       .navy,
            //               fontSize:
            //                   12,
            //               fontWeight:
            //                   FontWeight
            //                       .w700,
            //             ),
            //           ),
            //         ),
            //         if (commission >
            //             0)
            //           Text(
            //             'Bs ${driverNet.toStringAsFixed(0)} neto',
            //             style:
            //                 const TextStyle(
            //               color:
            //                   AppColors
            //                       .mutedInk,
            //               fontSize:
            //                   11,
            //             ),
            //           ),
            //       ],
            //     ),
            //   ),
            // ],

            // if (isActive) ...[
            //   const SizedBox(
            //     height: 14,
            //   ),
            //   SizedBox(
            //     width:
            //         double.infinity,
            //     height: 52,
            //     child:
            //         FilledButton(
            //       onPressed:
            //           _finishing
            //               ? null
            //               : _finishTrip,
            //       style:
            //           FilledButton
            //               .styleFrom(
            //         backgroundColor:
            //             AppColors
            //                 .navy,
            //         foregroundColor:
            //             AppColors
            //                 .white,
            //         disabledBackgroundColor:
            //             AppColors
            //                 .mist,
            //         shape:
            //             RoundedRectangleBorder(
            //           borderRadius:
            //               BorderRadius
            //                   .circular(
            //             16,
            //           ),
            //         ),
            //       ),
            //       child:
            //           _finishing
            //               ? const SizedBox(
            //                   width:
            //                       21,
            //                   height:
            //                       21,
            //                   child:
            //                       CircularProgressIndicator(
            //                     strokeWidth:
            //                         2.5,
            //                     color:
            //                         AppColors
            //                             .white,
            //                   ),
            //                 )
            //               : const Text(
            //                   'Finalizar viaje',
            //                   style:
            //                       TextStyle(
            //                     fontWeight:
            //                         FontWeight
            //                             .w800,
            //                   ),
            //                 ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSummary() {
    final distanceKm = _routeDistanceMeters / 1000.0;

    final durationMinutes = _routeDuration.inMinutes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (_origin != null)
            _routeRow(
              icon: Icons.radio_button_checked_rounded,
              color: AppColors.navyLight,
              title: 'Origen',
              value: 'Punto de recogida',
            ),

          if (_origin != null && _destination != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(height: 15, width: 1.5, color: AppColors.mist),
              ),
            ),

          if (_destination != null)
            _routeRow(
              icon: Icons.location_on_rounded,
              color: AppColors.clay,
              title: 'Destino',
              value: 'Destino del viaje',
            ),

          if (_routeLoading) ...[
            const SizedBox(height: 12),

            const Row(
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(width: 9),
                Text(
                  'Calculando ruta...',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          if (!_routeLoading && _routeDistanceMeters > 0) ...[
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 17,
                    color: AppColors.navy,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppColors.navy,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    durationMinutes > 0 ? '$durationMinutes min' : 'Calculando',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaiting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.route_rounded,
                size: 38,
                color: AppColors.navyLight,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Esperando confirmación...',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estamos preparando los detalles de tu viaje.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedInk, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No pudimos cargar el viaje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedInk, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  LatLng? _readLocation(dynamic value) {
    if (value is GeoPoint) {
      return LatLng(value.latitude, value.longitude);
    }

    if (value is Map) {
      final lat = value['latitude'] ?? value['lat'];

      final lng = value['longitude'] ?? value['lng'];

      if (lat is num && lng is num) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
    }

    return null;
  }

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _readNum(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}
