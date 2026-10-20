import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_client.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';

class CustomerTripPage extends ConsumerStatefulWidget {
  const CustomerTripPage({
    super.key,
    required this.tripId,
    required this.customerId,
  });

  final String tripId;
  final String customerId;

  @override
  ConsumerState<CustomerTripPage> createState() => _CustomerTripPageState();
}

class _CustomerTripPageState extends ConsumerState<CustomerTripPage> {
  RideRequestModel? _ride;
  Timer? _statusTimer;
  bool _loading = true;
  bool _ratingShown = false;

  @override
  void initState() {
    super.initState();
    _fetchTripStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchTripStatus());
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTripStatus() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final id = int.parse(widget.tripId);

      final response = await apiClient.get(
        ApiEndpoints.rideDetail(id),
        requiresAuth: true,
      );

      final data = response['data'] ?? response;
      final ride = RideRequestModel.fromJson(data);

      if (!mounted) return;

      setState(() {
        _ride = ride;
        _loading = false;
      });

      if (ride.status == 'FINALIZADO' && !_ratingShown) {
        _statusTimer?.cancel();
        _showRatingDialog(ride.driverId ?? 0);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showRatingDialog(int driverId) async {
    _ratingShown = true;
    int score = 5;
    final commentController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Califica tu viaje', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cómo estuvo el servicio del conductor?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setDialogState(() => score = index + 1),
                    icon: Icon(
                      index < score ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Comentario opcional...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                try {
                  final apiClient = ref.read(apiClientProvider);
                  final user = ref.read(authControllerProvider).user;

                  await apiClient.post(
                    '/ratings',
                    body: {
                      'ride_id': int.parse(widget.tripId),
                      'evaluator_id': user?.id ?? int.parse(widget.customerId),
                      'evaluated_id': driverId,
                      'evaluator_role': 'client',
                      'score': score,
                      'comment': commentController.text.trim(),
                      'tags': ['Puntual', 'Amable'],
                    },
                    requiresAuth: true,
                  );
                } catch (_) {}
                if (!dialogCtx.mounted) return;
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop(); // Vuelve al Home
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
              child: const Text('Enviar calificación'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _ride == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }

    final origin = LatLng(_ride?.originLatitude ?? -16.1311, _ride?.originLongitude ?? -62.0298);
    final destination = LatLng(_ride?.destinationLatitude ?? -16.1380, _ride?.destinationLongitude ?? -62.0350);

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text('Estado: ${_ride?.status ?? 'En curso'}', style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: origin, zoom: 14),
              markers: {
                Marker(markerId: const MarkerId('origin'), position: origin, infoWindow: const InfoWindow(title: 'Origen')),
                Marker(markerId: const MarkerId('dest'), position: destination, infoWindow: const InfoWindow(title: 'Destino')),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.mist,
                        child: Icon(Icons.directions_car, color: AppColors.navy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_ride?.destinationAddress ?? 'Destino', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text('Tarifa: Bs ${(_ride?.agreedFare ?? _ride?.offeredFare ?? 0).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.mist,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _ride?.status ?? 'ACTIVO',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.navy),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}