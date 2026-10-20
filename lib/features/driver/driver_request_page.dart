import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/features/driver/home/driver_home_page.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';

class DriverRequestsPage extends ConsumerStatefulWidget {
  const DriverRequestsPage({super.key});

  static const routePath = '/driver/requests';

  @override
  ConsumerState<DriverRequestsPage> createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends ConsumerState<DriverRequestsPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Actualización periódica de solicitudes disponibles
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      ref.invalidate(availableRidesProvider);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ridesAsync = ref.watch(availableRidesProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/driver/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/home');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'Solicitudes cercanas',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(availableRidesProvider),
            ),
          ],
        ),
        body: ridesAsync.when(
          data: (rides) {
            if (rides.isEmpty) {
              return const _EmptyRequests();
            }

            return RefreshIndicator(
              color: AppColors.navy,
              onRefresh: () async => ref.invalidate(availableRidesProvider),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                itemCount: rides.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return _RequestCard(ride: ride);
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.navy),
          ),
          error: (err, _) => _ErrorState(
            message: 'No pudimos cargar las solicitudes.\n\n$err',
            onRetry: () => ref.invalidate(availableRidesProvider),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RideRequestModel ride;

  const _RequestCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.push('/driver/requests/${ride.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mist),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: AppColors.navy, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Viaje #${ride.id}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${ride.distanceKm ?? 3.5} km • ${ride.estimatedTimeMinutes ?? 10} min aprox.',
                          style: const TextStyle(
                            color: AppColors.mutedInk,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Bs ${ride.offeredFare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _InfoRow(
                icon: Icons.my_location_rounded,
                iconColor: AppColors.navyLight,
                text: ride.originAddress ?? 'Origen no especificado',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.clay,
                text: ride.destinationAddress ?? 'Destino no especificado',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/driver/requests/${ride.id}');
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Ver solicitud y ofertar',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoRow({required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.ink, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: AppColors.navyLight),
            ),
            const SizedBox(height: 18),
            const Text(
              'No hay solicitudes cercanas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            const Text(
              'Las solicitudes de clientes aparecerán automáticamente aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedInk, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 44),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedInk, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}