import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverOffersPage extends StatefulWidget {
  const DriverOffersPage({super.key});

  static const routePath = '/driver/offers';

  @override
  State<DriverOffersPage> createState() => _DriverOffersPageState();
}

class _DriverOffersPageState extends State<DriverOffersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_DriverOffer> _offers = [
    _DriverOffer(
      service: 'Taxi',
      icon: Icons.local_taxi_rounded,
      accent: AppColors.sunrise,
      origin: 'Barrio El Carmen',
      destination: 'Centro de San José',
      price: 28.0,
      distance: '4.8 km',
      time: '12 min',
      status: _OfferStatus.pending,
      customer: 'Cliente',
      created: 'Hace 3 min',
    ),
    _DriverOffer(
      service: 'Moto',
      icon: Icons.two_wheeler_rounded,
      accent: AppColors.navyLight,
      origin: 'Av. Chiquitos',
      destination: 'Mercado Central',
      price: 15.0,
      distance: '2.6 km',
      time: '8 min',
      status: _OfferStatus.accepted,
      customer: 'Cliente',
      created: 'Hace 18 min',
    ),
    _DriverOffer(
      service: 'Delivery',
      icon: Icons.delivery_dining_rounded,
      accent: AppColors.clay,
      origin: 'Zona Centro',
      destination: 'Barrio La Estación',
      price: 18.0,
      distance: '3.2 km',
      time: '10 min',
      status: _OfferStatus.rejected,
      customer: 'Cliente',
      created: 'Ayer',
    ),
  ];

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
      context.go('/driver/home');
    }
  }

  void _showOfferDetails(_DriverOffer offer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.sand,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mutedInk.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _buildServiceIcon(
                      icon: offer.icon,
                      color: offer.accent,
                      size: 48,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.service,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Oferta realizada ${offer.created}',
                            style: const TextStyle(
                              color: AppColors.mutedInk,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(offer.status),
                  ],
                ),
                const SizedBox(height: 22),
                _buildRoutePreview(offer),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.straighten_rounded,
                  'Distancia',
                  offer.distance,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.schedule_rounded,
                  'Tiempo estimado',
                  offer.time,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.person_outline_rounded,
                  'Cliente',
                  offer.customer,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tu oferta',
                          style: TextStyle(
                            color: AppColors.mist,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Bs ${offer.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
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
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'Mis ofertas',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeaderSummary(),
              const SizedBox(height: 4),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOffersList(_offers),
                    _buildOffersList(
                      _offers
                          .where(
                            (offer) => offer.status == _OfferStatus.accepted,
                          )
                          .toList(),
                    ),
                    _buildOffersList(
                      _offers
                          .where(
                            (offer) => offer.status == _OfferStatus.pending,
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSummary() {
    final accepted = _offers
        .where((offer) => offer.status == _OfferStatus.accepted)
        .length;

    final pending = _offers
        .where((offer) => offer.status == _OfferStatus.pending)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              icon: Icons.send_rounded,
              value: '${_offers.length}',
              label: 'Enviadas',
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              icon: Icons.check_circle_outline_rounded,
              value: '$accepted',
              label: 'Aceptadas',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              icon: Icons.hourglass_top_rounded,
              value: '$pending',
              label: 'Pendientes',
              color: AppColors.sunrise,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.mutedInk.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.navyLight,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.mist.withOpacity(0.65),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.mutedInk,
        indicatorColor: AppColors.navy,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Aceptadas'),
          Tab(text: 'Pendientes'),
        ],
      ),
    );
  }

  Widget _buildOffersList(List<_DriverOffer> offers) {
    if (offers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final offer = offers[index];

        return _buildOfferCard(offer);
      },
    );
  }

  Widget _buildOfferCard(_DriverOffer offer) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => _showOfferDetails(offer),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.mutedInk.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withOpacity(0.035),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildServiceIcon(icon: offer.icon, color: offer.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              offer.service,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 7),
                            _buildStatusChip(offer.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.created,
                          style: const TextStyle(
                            color: AppColors.mutedInk,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Bs ${offer.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildRoutePreview(offer),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildSmallInfo(Icons.straighten_rounded, offer.distance),
                  const SizedBox(width: 15),
                  _buildSmallInfo(Icons.schedule_rounded, offer.time),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.mutedInk,
                    size: 21,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePreview(_DriverOffer offer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.navy,
                size: 15,
              ),
              Container(width: 1, height: 20, color: AppColors.navyLight),
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.clay,
                size: 17,
              ),
            ],
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.origin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  offer.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.mutedInk, size: 15),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.mutedInk,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcon({
    required IconData icon,
    required Color color,
    double size = 46,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }

  Widget _buildStatusChip(_OfferStatus status) {
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case _OfferStatus.pending:
        label = 'Pendiente';
        color = AppColors.sunrise;
        icon = Icons.hourglass_top_rounded;
        break;

      case _OfferStatus.accepted:
        label = 'Aceptada';
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;

      case _OfferStatus.rejected:
        label = 'No aceptada';
        color = AppColors.mutedInk;
        icon = Icons.remove_circle_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.navy, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.mutedInk, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.mist,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: AppColors.navy,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No hay ofertas aquí',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Las ofertas que realices aparecerán '
              'en esta sección.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedInk,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _OfferStatus { pending, accepted, rejected }

class _DriverOffer {
  final String service;
  final IconData icon;
  final Color accent;
  final String origin;
  final String destination;
  final double price;
  final String distance;
  final String time;
  final _OfferStatus status;
  final String customer;
  final String created;

  const _DriverOffer({
    required this.service,
    required this.icon,
    required this.accent,
    required this.origin,
    required this.destination,
    required this.price,
    required this.distance,
    required this.time,
    required this.status,
    required this.customer,
    required this.created,
  });
}
