import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverRequestsPage extends StatelessWidget {
  const DriverRequestsPage({super.key});

  static const routePath = '/driver/requests';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
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
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('transport_requests')
              .where('status', isEqualTo: 'searching')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorState(
                message:
                    'No pudimos cargar las solicitudes.\n\n'
                    '${snapshot.error}',
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.navy),
              );
            }

            final documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return const _EmptyRequests();
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final doc = documents[index];

                return _RequestCard(requestId: doc.id, data: doc.data());
              },
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.requestId, required this.data});

  final String requestId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final serviceType = data['serviceType'] as String? ?? 'taxi';

    final serviceName = _serviceName(serviceType);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.push('/driver/requests/$requestId', extra: data);
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
                  _ServiceIcon(serviceType: serviceType),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Solicitud disponible',
                          style: TextStyle(
                            color: AppColors.mutedInk,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Activa',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 19),

              _InfoRow(
                icon: Icons.my_location_rounded,
                iconColor: AppColors.navyLight,
                text: 'Recogida en ubicación indicada',
              ),

              const SizedBox(height: 11),

              _InfoRow(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.clay,
                text: 'Destino indicado por cliente',
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/driver/requests/$requestId', extra: data);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Ver solicitud',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _serviceName(String value) {
    switch (value) {
      case 'mototaxi':
        return 'Mototaxi';
      case 'camion':
        return 'Camión';
      case 'delivery':
        return 'Delivery';
      case 'viaje':
        return 'Viaje';
      case 'taxi':
      default:
        return 'Taxi';
    }
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.serviceType});

  final String serviceType;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForService(serviceType);
    final accent = _accentForService(serviceType);

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.11),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: accent, size: 27),
    );
  }

  IconData _iconForService(String value) {
    switch (value) {
      case 'mototaxi':
        return Icons.two_wheeler_rounded;
      case 'camion':
        return Icons.local_shipping_rounded;
      case 'delivery':
        return Icons.inventory_2_outlined;
      case 'viaje':
        return Icons.route_rounded;
      case 'taxi':
      default:
        return Icons.local_taxi_rounded;
    }
  }

  Color _accentForService(String value) {
    switch (value) {
      case 'mototaxi':
        return AppColors.navyLight;
      case 'camion':
        return AppColors.clay;
      case 'delivery':
        return AppColors.success;
      case 'viaje':
        return AppColors.sunrise;
      case 'taxi':
      default:
        return AppColors.navyLight;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.mutedInk,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 43,
                color: AppColors.navyLight,
              ),
            ),

            const SizedBox(height: 21),

            const Text(
              'No hay solicitudes cercanas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Cuando un cliente solicite un servicio, '
              'aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedInk,
                height: 1.5,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.mist),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.navyLight,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Actualización automática',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 34,
              ),
            ),

            const SizedBox(height: 17),

            const Text(
              'No pudimos cargar las solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedInk,
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
