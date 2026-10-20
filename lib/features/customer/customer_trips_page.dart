import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_client.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';


class CustomerTripsPage extends ConsumerStatefulWidget {
  const CustomerTripsPage({super.key});

  static const routePath = '/customer/trips';

  @override
  ConsumerState<CustomerTripsPage> createState() => _CustomerTripsPageState();
}

class _CustomerTripsPageState extends ConsumerState<CustomerTripsPage> {
  List<RideRequestModel> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    try {
      final user = ref.read(authControllerProvider).user;
      final apiClient = ref.read(apiClientProvider);

      if (user != null) {
        // En Laravel consultamos el perfil o lista de solicitudes del cliente
        final response = await apiClient.get(
          ApiEndpoints.clientProfile(user.id),
          requiresAuth: true,
        );
        final list = (response['data']?['ride_requests'] ?? response['ride_requests'] ?? []) as List<dynamic>;
        if (mounted) {
          setState(() {
            _trips = list.map((e) => RideRequestModel.fromJson(e as Map<String, dynamic>)).toList();
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Mis Viajes', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : _trips.isEmpty
              ? _emptyView()
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: _trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.mist,
                          child: Icon(Icons.directions_car_rounded, color: AppColors.navy),
                        ),
                        title: Text(
                          trip.destinationAddress ?? 'Destino',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('Estado: ${trip.status}'),
                        trailing: Text(
                          'Bs ${(trip.agreedFare ?? trip.offeredFare).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.history_rounded, size: 36, color: AppColors.navy),
            ),
            const SizedBox(height: 16),
            const Text('Aún no tienes viajes registrados', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Tus solicitudes y viajes completados aparecerán aquí.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedInk)),
          ],
        ),
      ),
    );
  }
}