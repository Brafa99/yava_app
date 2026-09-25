import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:yava_delivery_driver/features/transport/customer_trip_page.dart';
import 'package:yava_delivery_driver/features/transport/transport_service.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class CustomerOffersPage extends StatefulWidget {
  const CustomerOffersPage({
    super.key,
    required this.requestId,
    required this.customerId,
  });

  final String requestId;
  final String customerId;

  static const routePath = '/customer/offers/:requestId';

  @override
  State<CustomerOffersPage> createState() => _CustomerOffersPageState();
}

class _CustomerOffersPageState extends State<CustomerOffersPage> {
  String? _selectingOfferId;

  Future<void> _acceptOffer(String offerId, Map<String, dynamic> data) async {
    if (_selectingOfferId != null) return;

    final driverId = data['driverId'] as String?;
    final rawPrice = data['price'];

    if (driverId == null || rawPrice is! num) {
      _showMessage('La oferta no contiene información válida.');
      return;
    }

    setState(() {
      _selectingOfferId = offerId;
    });

    try {
      final price = rawPrice.toDouble();

      await TransportService().acceptOffer(
        requestId: widget.requestId,
        offerId: offerId,
        driverId: driverId,
        price: price,
        customerId: widget.customerId,
      );

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

      setState(() {
        _selectingOfferId = null;
      });

      _showMessage('No se pudo aceptar la oferta.\n$e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
        ),
      );
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
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
          foregroundColor: AppColors.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'Ofertas disponibles',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('transport_requests')
              .doc(widget.requestId)
              .collection('offers')
              .orderBy('createdAt')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorState(message: '${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.navy),
              );
            }

            final offers = snapshot.data?.docs ?? [];

            if (offers.isEmpty) {
              return const _WaitingState();
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
              children: [
                _HeroHeader(count: offers.length),
                const SizedBox(height: 14),
                const _InfoBanner(),
                const SizedBox(height: 20),
                ...offers.map(
                  (doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _OfferCard(
                      offerId: doc.id,
                      data: doc.data(),
                      selecting: _selectingOfferId == doc.id,
                      onAccept: () => _acceptOffer(doc.id, doc.data()),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conductores disponibles',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  count == 1
                      ? 'Hay 1 oferta para tu viaje'
                      : 'Hay $count ofertas para tu viaje',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.78),
                    fontSize: 13,
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.navyLight.withValues(alpha: 0.10)),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt_rounded, color: AppColors.navyLight, size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Las nuevas ofertas aparecen automáticamente.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offerId,
    required this.data,
    required this.selecting,
    required this.onAccept,
  });

  final String offerId;
  final Map<String, dynamic> data;
  final bool selecting;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final driverId = data['driverId'] as String? ?? 'Conductor';

    final rawPrice = data['price'];

    final price = rawPrice is num ? rawPrice.toDouble() : 0.0;

    final createdAt = _readDate(data['createdAt']);

    final driverName = _readDriverName(data, driverId);

    final vehicle = _readVehicle(data);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mist, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.navy,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vehicle != null)
                      Text(
                        vehicle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedInk,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        color: AppColors.mutedInk,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'OFERTA',
                    style: TextStyle(
                      color: AppColors.mutedInk,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Bs ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: AppColors.success,
                  size: 19,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Oferta recibida en tiempo real',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: selecting ? null : onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.mutedInk,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: selecting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Elegir este conductor',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static String _readDriverName(Map<String, dynamic> data, String fallback) {
    final value =
        data['driverName'] ?? data['name'] ?? data['driverDisplayName'];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    return 'Conductor';
  }

  static String? _readVehicle(Map<String, dynamic> data) {
    final value =
        data['vehicle'] ?? data['vehicleName'] ?? data['vehicleModel'];

    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }

    return value.toString();
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

  static String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return 'Oferta reciente';
    }

    final local = date.toLocal();

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return 'Recibida a las $hour:$minute';
  }
}

class _WaitingState extends StatelessWidget {
  const _WaitingState();

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
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.radar_rounded,
                color: AppColors.navy,
                size: 45,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Buscando conductores',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Las ofertas aparecerán automáticamente '
              'cuando los conductores respondan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedInk, height: 1.5),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: AppColors.sunrise,
              strokeWidth: 3,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFF8E4E2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No pudimos cargar las ofertas',
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
              style: TextStyle(
                color: AppColors.mutedInk,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
