import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/features/transport/customer_trip_page.dart';

class CustomerTripsPage extends StatefulWidget {
  static const routePath = '/customer/trips';

  const CustomerTripsPage({super.key});

  @override
  State<CustomerTripsPage> createState() => _CustomerTripsPageState();
}

class _CustomerTripsPageState extends State<CustomerTripsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customer/home');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _tripsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('trips')
        .where('customerId', isEqualTo: user.uid)
        .snapshots();
  }

  List<_TripData> _mockTrips() {
    return [
      _TripData(
        id: 'mock-trip-1',
        service: 'Taxi',
        icon: Icons.local_taxi_rounded,
        origin: 'Plaza Principal',
        destination: 'Barrio San Antonio',
        price: 28,
        status: 'completed',
        dateLabel: 'Hoy, 14:32',
        driverName: 'Carlos M.',
        vehicle: 'Toyota Corolla • YAV-021',
        rating: 5,
      ),
      _TripData(
        id: 'mock-trip-2',
        service: 'Moto',
        icon: Icons.two_wheeler_rounded,
        origin: 'Mercado Central',
        destination: 'Av. Circunvalación',
        price: 18,
        status: 'completed',
        dateLabel: 'Ayer, 18:10',
        driverName: 'Luis R.',
        vehicle: 'Honda XR • YAV-114',
        rating: 4,
      ),
      _TripData(
        id: 'mock-trip-3',
        service: 'Taxi',
        icon: Icons.local_taxi_rounded,
        origin: 'Terminal',
        destination: 'Barrio Equipetrol',
        price: 35,
        status: 'active',
        dateLabel: 'En curso',
        driverName: 'María P.',
        vehicle: 'Suzuki Swift • YAV-087',
        rating: null,
      ),
    ];
  }

  List<_TripData> _parseTrips(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final trips = documents.map((doc) {
      final data = doc.data();

      return _TripData.fromFirestore(id: doc.id, data: data);
    }).toList();

    trips.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });

    return trips;
  }

  List<_TripData> _filterTrips(List<_TripData> trips, int tabIndex) {
    if (tabIndex == 0) {
      return trips;
    }

    if (tabIndex == 1) {
      return trips.where((trip) {
        return trip.status == 'active' ||
            trip.status == 'accepted' ||
            trip.status == 'searching';
      }).toList();
    }

    return trips.where((trip) {
      return trip.status == 'completed';
    }).toList();
  }

  Future<void> _openTrip(_TripData trip) async {
    if (trip.id.startsWith('mock-')) {
      if (!mounted) return;

      _showTripDetails(trip);
      return;
    }

    final user = _auth.currentUser;

    if (user == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerTripPage(tripId: trip.id, customerId: user.uid),
      ),
    );
  }

  void _showTripDetails(_TripData trip) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _ServiceIcon(icon: trip.icon, background: AppColors.mist),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.service,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusLabel(trip.status),
                            style: TextStyle(
                              color: _statusColor(trip.status),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Bs ${trip.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DetailLocation(
                  icon: Icons.radio_button_checked_rounded,
                  label: 'Origen',
                  value: trip.origin,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Container(height: 22, width: 2, color: AppColors.mist),
                ),
                _DetailLocation(
                  icon: Icons.location_on_rounded,
                  label: 'Destino',
                  value: trip.destination,
                ),
                const SizedBox(height: 20),
                if (trip.driverName != null)
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Conductor',
                    value: trip.driverName!,
                  ),
                if (trip.vehicle != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.directions_car_rounded,
                    label: 'Vehículo',
                    value: trip.vehicle!,
                  ),
                ],
                if (trip.dateLabel != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Fecha',
                    value: trip.dateLabel!,
                  ),
                ],
                if (trip.rating != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.star_rounded,
                    label: 'Tu calificación',
                    value: '${trip.rating}/5',
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();

                      if (trip.status == 'active' ||
                          trip.status == 'accepted') {
                        _openTrip(trip);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      trip.status == 'active' || trip.status == 'accepted'
                          ? 'Ver viaje'
                          : 'Cerrar',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.sand,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink,
            ),
          ),
          title: const Text(
            'Mis viajes',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _tripsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildContent(trips: _mockTrips(), isMock: true);
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            final documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return _buildContent(trips: _mockTrips(), isMock: true);
            }

            final trips = _parseTrips(documents);

            return _buildContent(trips: trips, isMock: false);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.navy),
    );
  }

  Widget _buildContent({required List<_TripData> trips, required bool isMock}) {
    final completed = trips.where((trip) => trip.status == 'completed');

    final active = trips.where(
      (trip) =>
          trip.status == 'active' ||
          trip.status == 'accepted' ||
          trip.status == 'searching',
    );

    final totalSpent = completed.fold<double>(
      0,
      (sum, trip) => sum + trip.price,
    );

    return Column(
      children: [
        _buildSummary(
          totalTrips: trips.length,
          activeTrips: active.length,
          totalSpent: totalSpent,
        ),
        const SizedBox(height: 4),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTripList(trips: trips, tabIndex: 0, isMock: isMock),
              _buildTripList(trips: trips, tabIndex: 1, isMock: isMock),
              _buildTripList(trips: trips, tabIndex: 2, isMock: isMock),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary({
    required int totalTrips,
    required int activeTrips,
    required double totalSpent,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.navy, AppColors.navyLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.route_rounded,
                value: '$totalTrips',
                label: 'Viajes',
              ),
            ),
            Container(
              width: 1,
              height: 38,
              color: AppColors.white.withValues(alpha: 0.18),
            ),
            Expanded(
              child: _SummaryItem(
                icon: Icons.navigation_rounded,
                value: '$activeTrips',
                label: 'Activos',
              ),
            ),
            Container(
              width: 1,
              height: 38,
              color: AppColors.white.withValues(alpha: 0.18),
            ),
            Expanded(
              child: _SummaryItem(
                icon: Icons.payments_rounded,
                value: 'Bs ${totalSpent.toStringAsFixed(0)}',
                label: 'Gastado',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: AppColors.mutedInk,
          indicatorColor: AppColors.navy,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Activos'),
            Tab(text: 'Completados'),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList({
    required List<_TripData> trips,
    required int tabIndex,
    required bool isMock,
  }) {
    final filtered = _filterTrips(trips, tabIndex);

    if (filtered.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      itemCount: filtered.length + (isMock ? 1 : 0),
      itemBuilder: (context, index) {
        if (isMock && index == filtered.length) {
          return _buildDemoNote();
        }

        final trip = filtered[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TripCard(
            trip: trip,
            onTap: () => _showTripDetails(trip),
            onViewTrip: () {
              if (trip.status == 'active' || trip.status == 'accepted') {
                _openTrip(trip);
              } else {
                _showTripDetails(trip);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;

    if (tabIndex == 1) {
      title = 'No tienes viajes activos';
      subtitle = 'Cuando aceptes un viaje, aparecerá aquí.';
      icon = Icons.navigation_rounded;
    } else if (tabIndex == 2) {
      title = 'Aún no tienes viajes completados';
      subtitle = 'Tus viajes finalizados aparecerán aquí.';
      icon = Icons.check_circle_outline_rounded;
    } else {
      title = 'Todavía no tienes viajes';
      subtitle = 'Solicita tu primer servicio YAVÁ.';
      icon = Icons.route_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 38, color: AppColors.navyLight),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedInk, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoNote() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.navyLight,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vista demo: estos ejemplos aparecen mientras tu cuenta todavía no tiene viajes registrados.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.navy,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completado';
      case 'active':
        return 'En curso';
      case 'accepted':
        return 'Aceptado';
      case 'searching':
        return 'Buscando conductor';
      case 'cancelled':
      case 'canceled':
        return 'Cancelado';
      default:
        return 'Viaje';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'active':
      case 'accepted':
        return AppColors.navyLight;
      case 'searching':
        return AppColors.warning;
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.mutedInk;
    }
  }
}

class _TripData {
  final String id;
  final String service;
  final IconData icon;
  final String origin;
  final String destination;
  final double price;
  final String status;
  final String? dateLabel;
  final String? driverName;
  final String? vehicle;
  final int? rating;
  final DateTime? createdAt;

  const _TripData({
    required this.id,
    required this.service,
    required this.icon,
    required this.origin,
    required this.destination,
    required this.price,
    required this.status,
    this.dateLabel,
    this.driverName,
    this.vehicle,
    this.rating,
    this.createdAt,
  });

  factory _TripData.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final serviceValue =
        data['serviceType'] ?? data['service'] ?? data['type'] ?? 'Taxi';

    final service = serviceValue.toString();

    final status = (data['status'] ?? 'completed').toString().toLowerCase();

    final price = _readDouble(
      data['price'] ?? data['acceptedPrice'] ?? data['fare'] ?? data['total'],
    );

    final createdAt = _readDate(data['createdAt']);

    return _TripData(
      id: id,
      service: _serviceLabel(service),
      icon: _serviceIcon(service),
      origin: _locationLabel(
        data['origin'] ?? data['pickup'],
        fallback: 'Origen del viaje',
      ),
      destination: _locationLabel(
        data['destination'] ?? data['dropoff'],
        fallback: 'Destino del viaje',
      ),
      price: price,
      status: status,
      dateLabel: createdAt != null ? _formatDate(createdAt) : null,
      driverName: _readString(
        data['driverName'] ?? data['driverDisplayName'] ?? data['driver'],
      ),
      vehicle: _readString(
        data['vehicle'] ?? data['vehicleName'] ?? data['vehicleModel'],
      ),
      rating: _readInt(data['rating'] ?? data['customerRating']),
      createdAt: createdAt,
    );
  }

  static String _serviceLabel(String value) {
    switch (value.toLowerCase()) {
      case 'taxi':
        return 'Taxi';
      case 'moto':
      case 'mototaxi':
        return 'Moto';
      case 'delivery':
        return 'Delivery';
      case 'courier':
        return 'Courier';
      default:
        return value.isEmpty ? 'Servicio' : value;
    }
  }

  static IconData _serviceIcon(String value) {
    switch (value.toLowerCase()) {
      case 'taxi':
        return Icons.local_taxi_rounded;
      case 'moto':
      case 'mototaxi':
        return Icons.two_wheeler_rounded;
      case 'delivery':
      case 'courier':
        return Icons.inventory_2_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  static String _locationLabel(dynamic value, {required String fallback}) {
    if (value == null) return fallback;

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    if (value is Map) {
      final address =
          value['address'] ??
          value['name'] ??
          value['label'] ??
          value['description'];

      if (address != null && address.toString().trim().isNotEmpty) {
        return address.toString();
      }

      final lat = value['lat'] ?? value['latitude'];
      final lng = value['lng'] ?? value['longitude'];

      if (lat != null && lng != null) {
        return '${_formatCoordinate(lat)}, ${_formatCoordinate(lng)}';
      }
    }

    return fallback;
  }

  static String _formatCoordinate(dynamic value) {
    final number = double.tryParse(value.toString());

    if (number == null) return value.toString();

    return number.toStringAsFixed(5);
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} • $hour:$minute';
  }
}

class _TripCard extends StatelessWidget {
  final _TripData trip;
  final VoidCallback onTap;
  final VoidCallback onViewTrip;

  const _TripCard({
    required this.trip,
    required this.onTap,
    required this.onViewTrip,
  });

  @override
  Widget build(BuildContext context) {
    final isActive =
        trip.status == 'active' ||
        trip.status == 'accepted' ||
        trip.status == 'searching';

    final statusColor = _CustomerTripsPageState._statusColor(trip.status);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _ServiceIcon(icon: trip.icon, background: AppColors.mist),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.service,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.dateLabel ?? 'Viaje',
                          style: const TextStyle(
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
                      Text(
                        'Bs ${trip.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _CustomerTripsPageState._statusLabel(trip.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RoutePreview(origin: trip.origin, destination: trip.destination),
              if (trip.driverName != null || trip.vehicle != null) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.mist),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 17,
                      color: AppColors.mutedInk,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        trip.driverName ?? trip.vehicle ?? 'Conductor asignado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isActive)
                      TextButton(
                        onPressed: onViewTrip,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Ver viaje',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
              ] else if (isActive) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onViewTrip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                    ),
                    child: const Text(
                      'Ver viaje',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  final String origin;
  final String destination;

  const _RoutePreview({required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(
              Icons.radio_button_checked_rounded,
              size: 15,
              color: AppColors.navyLight,
            ),
            Container(
              height: 24,
              width: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 2),
              color: AppColors.mist,
            ),
            const Icon(
              Icons.location_on_rounded,
              size: 17,
              color: AppColors.clay,
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                destination,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final IconData icon;
  final Color background;

  const _ServiceIcon({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppColors.navy, size: 25),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 19, color: AppColors.white.withValues(alpha: 0.85)),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.68),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DetailLocation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLocation({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: label == 'Origen' ? AppColors.navyLight : AppColors.clay,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.navyLight),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.mutedInk, fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
