import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/driver/home/driver_home_page.dart';
import 'package:yava_delivery_driver/features/driver/widgets/drive_active_trip_panel.dart';
import 'package:yava_delivery_driver/features/driver/widgets/driver_complete_modal.dart';
import '../../app/theme/app_colors.dart';
import '../../core/network/api_endpoints.dart';

class DriverTrackingPage extends ConsumerStatefulWidget {
  const DriverTrackingPage({super.key, this.rideId = '1'});

  final String rideId;
  static const routePath = '/driver/tracking';

  @override
  ConsumerState<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends ConsumerState<DriverTrackingPage> {
  GoogleMapController? _mapController;
  
  // Estados oficiales de la BD MySQL: ACEPTADO -> EN_ORIGEN -> EN_CURSO -> FINALIZADO[cite: 1, 60]
  String _currentStatus = 'ACEPTADO';
  bool _updating = false;

  // Datos de ejemplo o en vivo del viaje
  double _totalFare = 18.00;
  double _driverNet = 14.40;
  double _commission = 3.60;

  // Ubicación base en Concepción, Santa Cruz
  static const LatLng _concepcionCenter = LatLng(-16.1311, -62.0298);

  // Estilo Dark Map para lograr el efecto futurista de los mockups[cite: 61]
  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#081528"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a3646"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#0f2c4a"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#1f5682"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#020d1a"}]}
  ]
  ''';

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    try {
      final ds = ref.read(transportRemoteDataSourceProvider);
      final id = int.tryParse(widget.rideId) ?? 1;

      // PATCH /api/ride-requests/{id}/status
      await ds.updateRideStatus(id, newStatus);

      if (!mounted) return;
      setState(() {
        _currentStatus = newStatus;
        _updating = false;
      });

      if (newStatus == 'FINALIZADO') {
        // Al finalizar, mostramos el modal de calificaciones (Mockup 6)[cite: 97]
        _showCompletedModal();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _updating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar estado: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showCompletedModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DriverCompletedModal(
        totalFare: _totalFare,
        driverNet: _driverNet,
        commission: _commission,
        onSubmitRating: (score, comment) async {
          try {
            final apiClient = ref.read(apiClientProvider);
            final user = ref.read(authControllerProvider).user;
            if (user != null) {
              await apiClient.post(
                ApiEndpoints.ratings,
                body: {
                  'ride_id': int.tryParse(widget.rideId) ?? 1,
                  'driver_id': user.id,
                  'client_id': 5, // ID temporal o dinámico del cliente
                  'evaluator_role': 'driver',
                  'score': score,
                  'comment': comment,
                  'is_anonymous': false,
                },
                requiresAuth: true,
              );
            }
          } catch (_) {}
        },
        onBackHome: () {
          Navigator.pop(ctx);
          context.go('/driver/home');
        },
        onGoAvailable: () {
          Navigator.pop(ctx);
          context.go('/driver/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030812),
      body: Stack(
        children: [
          // 1. Google Maps en pantalla completa con estilo Oscuro Futurista
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _concepcionCenter,
                zoom: 15.0,
                tilt: 45.0, // Inclinación 3D idéntica a los mockups[cite: 61, 93, 95]
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController?.setMapStyle(_darkMapStyle);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

          // 2. Banner Superior Dinámico según el Estado del Viaje
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: _buildDynamicTopBanner(),
          ),

          // 3. Panel Inferior Interactivo con el Deslizador "Slide to Act"
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DriverActiveTripPanel(
              status: _currentStatus,
              clientName: 'María Fernanda',
              origin: 'Plaza Principal - Concepción',
              destination: 'Barrio Zapocó',
              distanceText: '2,1 km',
              timeText: '6 min',
              onSlideComplete: () {
                if (_currentStatus == 'ACEPTADO') {
                  _updateStatus('EN_ORIGEN');
                } else if (_currentStatus == 'EN_ORIGEN') {
                  _updateStatus('EN_CURSO');
                } else if (_currentStatus == 'EN_CURSO') {
                  _updateStatus('FINALIZADO');
                }
              },
              onCancel: () {
                // Cancelar servicio endpoint POST /api/ride-requests/{id}/cancel[cite: 60]
                context.go('/driver/home');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTopBanner() {
    String title = 'Solicitud aceptada';
    String subtitle = 'Dirígete al punto de recogida';
    Color glowColor = const Color(0xFF0075FF);

    if (_currentStatus == 'EN_ORIGEN') {
      title = '¡Has llegado al punto de recogida!';
      subtitle = 'Espera al pasajero en el punto indicado.';
      glowColor = AppColors.success;
    } else if (_currentStatus == 'EN_CURSO') {
      title = 'Pasajero a bordo';
      subtitle = 'Ahora dirígete al destino.';
      glowColor = const Color(0xFF0075FF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF071220).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glowColor, width: 1.5),
        boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.4), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Icon(Icons.navigation_rounded, color: glowColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}