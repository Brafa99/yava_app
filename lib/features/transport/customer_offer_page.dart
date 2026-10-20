import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_client.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/transport/customer_trip_page.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';

class CustomerOffersPage extends ConsumerStatefulWidget {
  const CustomerOffersPage({
    super.key,
    required this.requestId,
    required this.customerId,
  });

  final String requestId;
  final String customerId;

  @override
  ConsumerState<CustomerOffersPage> createState() => _CustomerOffersPageState();
}

class _CustomerOffersPageState extends ConsumerState<CustomerOffersPage> {
  RideRequestModel? _rideDetail;
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;
  String? _acceptingOfferId;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchRideStatus();
    // Consultar periódicamente mientras el cliente espera contraofertas
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchRideStatus());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRideStatus() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final rideId = int.parse(widget.requestId);

      final response = await apiClient.get(
        ApiEndpoints.rideDetail(rideId),
        requiresAuth: true,
      );

      final data = response['data'] ?? response;
      final ride = RideRequestModel.fromJson(data);

      if (!mounted) return;

      setState(() {
        _rideDetail = ride;
        _offers = (data['offers'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _loading = false;
      });

      // Si el viaje ya fue aceptado por un conductor directamente
      if (ride.status == 'ACEPTADO' || ride.status == 'EN_ORIGEN' || ride.status == 'EN_CURSO') {
        _pollingTimer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CustomerTripPage(
              tripId: widget.requestId,
              customerId: widget.customerId,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptOffer(int offerId) async {
    setState(() => _acceptingOfferId = offerId.toString());

    try {
      final apiClient = ref.read(apiClientProvider);
      final rideId = int.parse(widget.requestId);

      await apiClient.post(
        ApiEndpoints.acceptOffer(rideId, offerId),
        requiresAuth: true,
      );

      _pollingTimer?.cancel();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CustomerTripPage(
            tripId: widget.requestId,
            customerId: widget.customerId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _acceptingOfferId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Ofertas recibidas', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _loading && _rideDetail == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : _offers.isEmpty
              ? _buildWaitingView()
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      'Hay ${_offers.length} ofertas para tu viaje',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    ..._offers.map((offer) {
                      final id = offer['id'] as int? ?? 0;
                      final fare = offer['offered_fare'] ?? offer['fare'] ?? 0;
                      final driverName = offer['driver_name'] ?? 'Conductor';
                      final vehicle = offer['vehicle'] ?? 'Vehículo verificado';

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.mist,
                                child: Icon(Icons.person, color: AppColors.navy),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(driverName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(vehicle, style: const TextStyle(color: AppColors.mutedInk, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text('Bs $fare', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.navy)),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _acceptingOfferId != null ? null : () => _acceptOffer(id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: Colors.white,
                                ),
                                child: _acceptingOfferId == id.toString()
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Aceptar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  Widget _buildWaitingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.navy, strokeWidth: 3),
            const SizedBox(height: 24),
            const Text(
              'Buscando conductores...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu solicitud a "${_rideDetail?.destinationAddress ?? 'Destino'}" está activa para conductores cercanos.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedInk, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}