import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/features/transport/driver_trip_page.dart';
import 'package:yava_delivery_driver/features/transport/transport_service.dart';

class DriverRequestDetailPage extends StatefulWidget {
  const DriverRequestDetailPage({
    super.key,
    required this.requestId,
    this.data,
  });

  final String requestId;
  final Map<String, dynamic>? data;

  static const routePath = '/driver/requests/:requestId';

  @override
  State<DriverRequestDetailPage> createState() =>
      _DriverRequestDetailPageState();
}

class _DriverRequestDetailPageState extends State<DriverRequestDetailPage> {
  final _priceController = TextEditingController();

  bool _sendingOffer = false;
  bool _offerSent = false;

  @override
  void initState() {
    super.initState();
    _checkExistingOffer();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingOffer() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transport_requests')
          .doc(widget.requestId)
          .collection('offers')
          .where('driverId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (!mounted) return;

      setState(() {
        _offerSent = snapshot.docs.isNotEmpty;
      });
    } catch (_) {
      // No interrumpimos la pantalla si la comprobación falla.
    }
  }

  Future<void> _sendOffer() async {
    if (_sendingOffer || _offerSent) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('No hay un conductor autenticado.');
      return;
    }

    final priceText = _priceController.text.trim();

    if (priceText.isEmpty) {
      _showMessage('Ingresa un precio.');
      return;
    }

    final price = double.tryParse(priceText.replaceAll(',', '.'));

    if (price == null || price <= 0) {
      _showMessage('Ingresa un precio válido.');
      return;
    }

    setState(() {
      _sendingOffer = true;
    });

    try {
      final service = TransportService();

      await service.createOffer(
        requestId: widget.requestId,
        driverId: user.uid,
        price: price,
      );

      if (!mounted) return;

      setState(() {
        _offerSent = true;
        _sendingOffer = false;
      });

      _showMessage('Oferta enviada. Esperando respuesta del cliente.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sendingOffer = false;
      });

      _showMessage('No se pudo enviar la oferta.\n$e');
    }
  }

  void _openTripIfAccepted() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('No hay un conductor autenticado.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            DriverTripPage(tripId: widget.requestId, driverId: user.uid),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/driver/requests');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
  }

  String _serviceName(String value) {
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

  IconData _serviceIcon(String value) {
    switch (value) {
      case 'mototaxi':
        return Icons.two_wheeler;
      case 'camion':
        return Icons.local_shipping;
      case 'delivery':
        return Icons.inventory_2_outlined;
      case 'viaje':
        return Icons.route;
      case 'taxi':
      default:
        return Icons.local_taxi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        context.go('/driver/requests');
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Volver',
          ),
          title: const Text(
            'Detalle de solicitud',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('transport_requests')
              .doc(widget.requestId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorState(
                message:
                    'No pudimos cargar la solicitud.\n\n'
                    '${snapshot.error}',
                onRetry: () {
                  setState(() {});
                },
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.navyLight),
              );
            }

            final data = snapshot.data?.data();

            if (data == null) {
              return const _EmptyState();
            }

            return _buildContent(data);
          },
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final serviceType = data['serviceType'] as String? ?? 'taxi';

    final serviceName = _serviceName(serviceType);

    final status = data['status'] as String? ?? 'searching';

    final origin = data['origin'];
    final destination = data['destination'];

    final currentUser = FirebaseAuth.instance.currentUser;

    final currentDriverId = currentUser?.uid ?? '';

    final acceptedDriverId = data['driverId'] as String? ?? '';

    final isMyTrip =
        acceptedDriverId.isNotEmpty && acceptedDriverId == currentDriverId;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ServiceHeader(
            serviceName: serviceName,
            icon: _serviceIcon(serviceType),
            status: status,
          ),
          const SizedBox(height: 18),
          _LocationCard(
            title: 'Punto de recogida',
            icon: Icons.my_location_rounded,
            location: origin,
            accentColor: AppColors.navyLight,
          ),
          const SizedBox(height: 12),
          _LocationCard(
            title: 'Destino',
            icon: Icons.location_on_rounded,
            location: destination,
            accentColor: AppColors.clay,
          ),
          const SizedBox(height: 24),
          if (status == 'searching')
            _OfferCard(
              controller: _priceController,
              sending: _sendingOffer,
              offerSent: _offerSent,
              onSend: _sendOffer,
              onOpenTrip: _openTripIfAccepted,
            ),

          if (status == 'accepted' && isMyTrip)
            _AcceptedTripCard(onOpenTrip: _openTripIfAccepted),

          if (status != 'searching' && !(status == 'accepted' && isMyTrip))
            _StatusCard(status: status),
          const SizedBox(height: 20),
          _RequestInfoCard(
            requestId: widget.requestId,
            customerId: data['customerId'] as String?,
          ),
        ],
      ),
    );
  }
}

class _AcceptedTripCard extends StatelessWidget {
  const _AcceptedTripCard({required this.onOpenTrip});

  final VoidCallback onOpenTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navyLight.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 36,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            '¡Tu oferta fue aceptada!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'El cliente eligió tu oferta. Ya puedes iniciar el viaje.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedInk, height: 1.4),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onOpenTrip,
              icon: const Icon(Icons.navigation_rounded),
              label: const Text(
                'Abrir viaje',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceHeader extends StatelessWidget {
  const _ServiceHeader({
    required this.serviceName,
    required this.icon,
    required this.status,
  });

  final String serviceName;
  final IconData icon;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.mist),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.navy, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: status == 'searching'
                            ? AppColors.sunrise
                            : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        _statusText(status),
                        style: const TextStyle(
                          color: AppColors.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Solicitud aceptada';
      case 'completed':
        return 'Servicio completado';
      case 'searching':
      default:
        return 'Buscando conductor';
    }
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.title,
    required this.icon,
    required this.location,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final dynamic location;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    String locationText = 'Ubicación disponible';

    if (location is GeoPoint) {
      locationText =
          '${location.latitude.toStringAsFixed(6)}, '
          '${location.longitude.toStringAsFixed(6)}';
    } else if (location is Map) {
      final latitude = location['latitude'];
      final longitude = location['longitude'];

      if (latitude != null && longitude != null) {
        final parsedLatitude = double.tryParse(latitude.toString());
        final parsedLongitude = double.tryParse(longitude.toString());

        if (parsedLatitude != null && parsedLongitude != null) {
          locationText =
              '${parsedLatitude.toStringAsFixed(6)}, '
              '${parsedLongitude.toStringAsFixed(6)}';
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mist),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationText,
                  style: const TextStyle(
                    color: AppColors.ink,
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
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.controller,
    required this.sending,
    required this.offerSent,
    required this.onSend,
    required this.onOpenTrip,
  });

  final TextEditingController controller;
  final bool sending;
  final bool offerSent;
  final VoidCallback onSend;
  final VoidCallback onOpenTrip;

  @override
  Widget build(BuildContext context) {
    if (offerSent) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.navyLight.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Oferta enviada',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Espera a que el cliente seleccione tu oferta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedInk, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.sunrise,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cuando el cliente acepte, podrás iniciar el viaje.',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.mist),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.05),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Enviar oferta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Indica cuánto cobrarías por realizar este servicio.',
            style: TextStyle(color: AppColors.mutedInk, height: 1.4),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Precio',
              hintText: 'Ej. 25',
              prefixText: 'Bs. ',
              prefixIcon: const Icon(
                Icons.payments_outlined,
                color: AppColors.navyLight,
              ),
              filled: true,
              fillColor: AppColors.sand,
              labelStyle: const TextStyle(color: AppColors.mutedInk),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.navyLight,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppColors.mist),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: sending ? null : onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.mutedInk.withOpacity(0.35),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: sending
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : const Text(
                      'Enviar oferta',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navyLight.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.navyLight),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Esta solicitud ya no está disponible para nuevas ofertas.',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestInfoCard extends StatelessWidget {
  const _RequestInfoCard({required this.requestId, required this.customerId});

  final String requestId;
  final String? customerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la solicitud',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.tag_rounded, label: 'ID', value: requestId),
          const SizedBox(height: 9),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Cliente',
            value: customerId ?? 'No disponible',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.mutedInk),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(color: AppColors.mutedInk, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedInk, height: 1.4),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: AppColors.mutedInk, size: 48),
            SizedBox(height: 14),
            Text(
              'No se encontró la solicitud.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
