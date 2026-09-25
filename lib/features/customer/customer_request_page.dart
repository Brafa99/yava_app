import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class CustomerRequestsPage extends StatelessWidget {
  static const routePath = '/customer/requests';

  const CustomerRequestsPage({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customer/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.sand,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => _goBack(context),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          ),
          title: const Text(
            'Mis solicitudes',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: user == null
            ? _buildNotAuthenticated()
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('transport_requests')
                    .where('customerId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.navy),
                    );
                  }

                  final docs = [...?snapshot.data?.docs];

                  docs.sort((a, b) {
                    final aDate = _readDate(a.data()['createdAt']);
                    final bDate = _readDate(b.data()['createdAt']);

                    return bDate.compareTo(aDate);
                  });

                  return _buildContent(context, docs);
                },
              ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) {
      return _buildEmpty();
    }

    final activeCount = docs.where((doc) {
      final status = _readStatus(doc.data());
      return status == 'searching' ||
          status == 'accepted' ||
          status == 'active';
    }).length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu actividad',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aquí puedes revisar tus solicitudes y viajes recientes.',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryCard(total: docs.length, active: activeCount),
                const SizedBox(height: 26),
                const Text(
                  'Solicitudes',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRequestCard(context, doc),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required int total, required int active}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              value: '$total',
              label: 'Solicitudes',
              light: true,
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: AppColors.white.withValues(alpha: 0.20),
          ),
          Expanded(
            child: _summaryItem(
              value: '$active',
              label: 'En curso',
              light: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String value,
    required String label,
    required bool light,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: light ? AppColors.white : AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: light
                ? AppColors.white.withValues(alpha: 0.78)
                : AppColors.mutedInk,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final service = _readService(data);
    final status = _readStatus(data);
    final origin = _locationLabel(
      data['origin'],
      fallback: 'Origen no disponible',
    );
    final destination = _locationLabel(
      data['destination'],
      fallback: 'Destino no disponible',
    );
    final date = _readDate(data['createdAt']);
    final price = _readPrice(data);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          _showDetails(context, data: data, requestId: doc.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _serviceIcon(service),
                      color: AppColors.navyLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _serviceName(service),
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDate(date),
                          style: const TextStyle(
                            color: AppColors.mutedInk,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(status),
                ],
              ),
              const SizedBox(height: 16),
              _routeRow(
                icon: Icons.radio_button_checked_rounded,
                color: AppColors.navyLight,
                label: origin,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Container(width: 1, height: 14, color: AppColors.mist),
              ),
              _routeRow(
                icon: Icons.location_on_rounded,
                color: AppColors.clay,
                label: destination,
              ),
              if (price != null) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.mist),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: AppColors.navyLight,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Precio',
                      style: TextStyle(color: AppColors.mutedInk, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      'Bs ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String status) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _showDetails(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String requestId,
  }) {
    final service = _readService(data);
    final status = _readStatus(data);
    final origin = _locationLabel(
      data['origin'],
      fallback: 'Origen no disponible',
    );
    final destination = _locationLabel(
      data['destination'],
      fallback: 'Destino no disponible',
    );
    final price = _readPrice(data);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _serviceIcon(service),
                        color: AppColors.navyLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _serviceName(service),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Solicitud ${requestId.substring(0, requestId.length > 8 ? 8 : requestId.length)}',
                            style: const TextStyle(
                              color: AppColors.mutedInk,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusPill(status),
                  ],
                ),
                const SizedBox(height: 22),
                _detailLocation(
                  icon: Icons.radio_button_checked_rounded,
                  color: AppColors.navyLight,
                  title: 'Origen',
                  value: origin,
                ),
                const SizedBox(height: 14),
                _detailLocation(
                  icon: Icons.location_on_rounded,
                  color: AppColors.clay,
                  title: 'Destino',
                  value: destination,
                ),
                if (price != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: AppColors.navyLight,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Precio registrado',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          'Bs ${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navyLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w800),
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

  Widget _detailLocation({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.mutedInk, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.navyLight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Todavía no tienes solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando solicites un servicio, aparecerá aquí tu historial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedInk,
                fontSize: 14,
                height: 1.45,
              ),
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
            const Icon(
              Icons.cloud_off_rounded,
              size: 46,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar tus solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisa tu conexión e inténtalo nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedInk, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAuthenticated() {
    return const Center(
      child: Text(
        'Inicia sesión para ver tus solicitudes.',
        style: TextStyle(
          color: AppColors.mutedInk,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _readService(Map<String, dynamic> data) {
    final value = data['serviceType'] ?? data['service'] ?? data['type'];

    return value?.toString().toLowerCase() ?? 'taxi';
  }

  static String _readStatus(Map<String, dynamic> data) {
    return (data['status'] ?? 'unknown').toString().toLowerCase();
  }

  static double? _readPrice(Map<String, dynamic> data) {
    final value = data['price'] ?? data['acceptedPrice'] ?? data['fare'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _locationLabel(dynamic location, {required String fallback}) {
    if (location == null) {
      return fallback;
    }

    if (location is String && location.trim().isNotEmpty) {
      return location;
    }

    if (location is Map) {
      final values = [
        location['address'],
        location['name'],
        location['label'],
        location['description'],
      ];

      for (final value in values) {
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }

      final lat = location['lat'] ?? location['latitude'];
      final lng = location['lng'] ?? location['longitude'];

      if (lat != null && lng != null) {
        return '${lat.toString()}, ${lng.toString()}';
      }
    }

    return fallback;
  }

  static IconData _serviceIcon(String service) {
    switch (service) {
      case 'moto':
      case 'mototaxi':
        return Icons.two_wheeler_rounded;
      case 'delivery':
        return Icons.inventory_2_rounded;
      case 'van':
        return Icons.airport_shuttle_rounded;
      case 'taxi':
      default:
        return Icons.local_taxi_rounded;
    }
  }

  static String _serviceName(String service) {
    switch (service) {
      case 'moto':
      case 'mototaxi':
        return 'Moto';
      case 'delivery':
        return 'Delivery';
      case 'van':
        return 'Van';
      case 'taxi':
      default:
        return 'Taxi';
    }
  }

  static _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'searching':
        return const _StatusConfig(
          label: 'Buscando',
          foreground: AppColors.warning,
          background: Color(0xFFFFF1DC),
        );

      case 'accepted':
        return const _StatusConfig(
          label: 'Aceptada',
          foreground: AppColors.navyLight,
          background: AppColors.mist,
        );

      case 'active':
        return const _StatusConfig(
          label: 'En curso',
          foreground: AppColors.navy,
          background: Color(0xFFDDEFE4),
        );

      case 'completed':
        return const _StatusConfig(
          label: 'Completada',
          foreground: AppColors.success,
          background: Color(0xFFE2F2E8),
        );

      case 'cancelled':
      case 'canceled':
        return const _StatusConfig(
          label: 'Cancelada',
          foreground: AppColors.error,
          background: Color(0xFFF8E4E2),
        );

      default:
        return const _StatusConfig(
          label: 'Pendiente',
          foreground: AppColors.mutedInk,
          background: AppColors.mist,
        );
    }
  }

  static String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return 'Fecha no disponible';
    }

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year · $hour:$minute';
  }
}

class _StatusConfig {
  final String label;
  final Color foreground;
  final Color background;

  const _StatusConfig({
    required this.label,
    required this.foreground,
    required this.background,
  });
}
