import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverTripsPage extends StatelessWidget {
  const DriverTripsPage({super.key});

  static const routePath = '/driver/trips';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/home');
              }
            },
          ),
          title: const Text(
            'Mis viajes',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
        ),
        body: user == null
            ? const _NotAuthenticatedState()
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('trips')
                    .where('driverId', isEqualTo: user.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _ErrorState(
                      message:
                          'No pudimos cargar tu historial.\n\n'
                          '${snapshot.error}',
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.navyLight,
                      ),
                    );
                  }

                  final documents = snapshot.data?.docs ?? [];

                  if (documents.isEmpty) {
                    return const _MockTripsView();
                  }

                  return _TripsList(documents: documents);
                },
              ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LISTA REAL
// -----------------------------------------------------------------------------

class _TripsList extends StatelessWidget {
  const _TripsList({required this.documents});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;

  @override
  Widget build(BuildContext context) {
    double total = 0;
    int completed = 0;

    for (final document in documents) {
      final data = document.data();

      final price = _toDouble(data['price']);

      if (data['status'] == 'completed') {
        completed++;
        total += price;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _SummaryCard(completedTrips: completed, totalEarned: total),
        const SizedBox(height: 24),
        const Text(
          'Historial',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...documents.map(
          (document) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TripCard(tripId: document.id, data: document.data()),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// MOCK
// -----------------------------------------------------------------------------

class _MockTripsView extends StatelessWidget {
  const _MockTripsView();

  @override
  Widget build(BuildContext context) {
    final trips = [
      _MockTrip(
        service: 'Taxi',
        origin: 'Plaza Principal',
        destination: 'Barrio San Antonio',
        price: 28,
        date: 'Hoy, 15:40',
        status: 'Completado',
        rating: 5,
      ),
      _MockTrip(
        service: 'Moto',
        origin: 'Mercado Central',
        destination: 'Av. Circunvalación',
        price: 18,
        date: 'Ayer, 18:20',
        status: 'Completado',
        rating: 5,
      ),
      _MockTrip(
        service: 'Taxi',
        origin: 'Terminal',
        destination: 'Barrio Equipetrol',
        price: 35,
        date: '18 Sep, 11:15',
        status: 'Completado',
        rating: 4,
      ),
    ];

    const total = 81.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _SummaryCard(completedTrips: 3, totalEarned: total),
        const SizedBox(height: 24),
        const Text(
          'Historial',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...trips.map(
          (trip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MockTripCard(trip: trip),
          ),
        ),
        const SizedBox(height: 8),
        const _DemoNotice(),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// RESUMEN
// -----------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.completedTrips, required this.totalEarned});

  final int completedTrips;
  final double totalEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.route_rounded, color: AppColors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mist.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Resumen',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Tus viajes completados',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completedTrips',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.white.withOpacity(0.12)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.sunrise,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ingresos brutos',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Bs ${totalEarned.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARD REAL
// -----------------------------------------------------------------------------

class _TripCard extends StatelessWidget {
  const _TripCard({required this.tripId, required this.data});

  final String tripId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data['status']?.toString() ?? 'unknown';
    final price = _toDouble(data['price']);

    final origin = _locationLabel(data['origin']);
    final destination = _locationLabel(data['destination']);

    final service =
        data['serviceType']?.toString() ??
        data['service']?.toString() ??
        'Servicio';

    final createdAt = _formatDate(data['createdAt']);

    final isCompleted = status == 'completed';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _showTripDetails(
          context,
          tripId: tripId,
          service: service,
          origin: origin,
          destination: destination,
          price: price,
          status: status,
          date: createdAt,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mist),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _ServiceIcon(service: service),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          color: AppColors.mutedInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(
                  text: isCompleted ? 'Completado' : status,
                  completed: isCompleted,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RoutePreview(origin: origin, destination: destination),
            const SizedBox(height: 15),
            Container(height: 1, color: AppColors.mist),
            const SizedBox(height: 13),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Bs ${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedInk,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MOCK CARD
// -----------------------------------------------------------------------------

class _MockTripCard extends StatelessWidget {
  const _MockTripCard({required this.trip});

  final _MockTrip trip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _showTripDetails(
          context,
          tripId: 'demo',
          service: trip.service,
          origin: trip.origin,
          destination: trip.destination,
          price: trip.price,
          status: 'completed',
          date: trip.date,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mist),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _ServiceIcon(service: trip.service),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.service,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        trip.date,
                        style: const TextStyle(
                          color: AppColors.mutedInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const _StatusPill(text: 'Completado', completed: true),
              ],
            ),
            const SizedBox(height: 16),
            _RoutePreview(origin: trip.origin, destination: trip.destination),
            const SizedBox(height: 15),
            Container(height: 1, color: AppColors.mist),
            const SizedBox(height: 13),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Bs ${trip.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedInk,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COMPONENTES
// -----------------------------------------------------------------------------

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.service});

  final String service;

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (service.toLowerCase()) {
      case 'moto':
        icon = Icons.two_wheeler_rounded;
        break;
      case 'delivery':
        icon = Icons.inventory_2_rounded;
        break;
      case 'encomienda':
        icon = Icons.local_shipping_rounded;
        break;
      default:
        icon = Icons.local_taxi_rounded;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: AppColors.navy, size: 23),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.completed});

  final String text;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = completed ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.access_time_rounded,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  const _RoutePreview({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          child: Column(
            children: [
              const Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.navyLight,
                size: 14,
              ),
              Container(width: 1, height: 20, color: AppColors.mist),
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.clay,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                destination,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navyLight.withOpacity(0.12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.navyLight,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mostrando viajes de demostración mientras '
              'se generan viajes reales en Firestore.',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotAuthenticatedState extends StatelessWidget {
  const _NotAuthenticatedState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No hay una sesión activa.',
        style: TextStyle(
          color: AppColors.mutedInk,
          fontWeight: FontWeight.w700,
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
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 40,
              ),
              const SizedBox(height: 14),
              const Text(
                'No pudimos cargar los viajes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mutedInk,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELO MOCK
// -----------------------------------------------------------------------------

class _MockTrip {
  const _MockTrip({
    required this.service,
    required this.origin,
    required this.destination,
    required this.price,
    required this.date,
    required this.status,
    required this.rating,
  });

  final String service;
  final String origin;
  final String destination;
  final double price;
  final String date;
  final String status;
  final int rating;
}

// -----------------------------------------------------------------------------
// DETALLE
// -----------------------------------------------------------------------------

void _showTripDetails(
  BuildContext context, {
  required String tripId,
  required String service,
  required String origin,
  required String destination,
  required double price,
  required String status,
  required String date,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'Detalle del viaje',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.mutedInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.local_taxi_rounded,
                label: 'Servicio',
                value: service,
              ),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Fecha',
                value: date,
              ),
              _DetailRow(
                icon: Icons.trip_origin_rounded,
                label: 'Origen',
                value: origin,
              ),
              _DetailRow(
                icon: Icons.location_on_rounded,
                label: 'Destino',
                value: destination,
              ),
              _DetailRow(
                icon: Icons.check_circle_rounded,
                label: 'Estado',
                value: status,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_rounded,
                      color: AppColors.sunrise,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Total del viaje',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Bs ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (tripId != 'demo') ...[
                const SizedBox(height: 12),
                Text(
                  'ID: $tripId',
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.navyLight, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _locationLabel(dynamic value) {
  if (value == null) return 'Ubicación no disponible';

  if (value is Map) {
    final address =
        value['address'] ??
        value['name'] ??
        value['label'] ??
        value['description'];

    if (address != null && address.toString().trim().isNotEmpty) {
      return address.toString();
    }

    final lat = value['latitude'] ?? value['lat'];
    final lng = value['longitude'] ?? value['lng'];

    if (lat != null && lng != null) {
      return '${lat.toString()}, ${lng.toString()}';
    }
  }

  return value.toString();
}

String _formatDate(dynamic value) {
  if (value == null) return 'Fecha no disponible';

  DateTime? date;

  if (value is Timestamp) {
    date = value.toDate();
  } else if (value is DateTime) {
    date = value;
  }

  if (date == null) {
    return value.toString();
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/${date.year} · $hour:$minute';
}
