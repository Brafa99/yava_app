import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_client.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/transport/customer_offer_page.dart';


class CustomerQuickRequestPage extends ConsumerStatefulWidget {
  const CustomerQuickRequestPage({super.key, required this.service});

  final String service; // 'auto', 'moto', 'trufi', etc.

  @override
  ConsumerState<CustomerQuickRequestPage> createState() => _CustomerQuickRequestPageState();
}

class _CustomerQuickRequestPageState extends ConsumerState<CustomerQuickRequestPage> {
  final TextEditingController _originController =
      TextEditingController(text: 'Plaza Principal, Concepción');
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _fareController = TextEditingController(text: '15');

  bool _loading = false;
  String _paymentMethod = 'EFECTIVO';

  // Coordenadas base en Concepción, Santa Cruz
  final double _originLat = -16.1311;
  final double _originLng = -62.0298;
  final double _destLat = -16.1380;
  final double _destLng = -62.0350;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  int get _serviceCategoryId {
    switch (widget.service.toLowerCase()) {
      case 'moto':
        return 3;
      case 'trufi':
        return 4;
      case 'viaje-interprovincial':
        return 5;
      default:
        return 2; // Auto
    }
  }

  Future<void> _createRideRequest() async {
    final destination = _destinationController.text.trim();
    final fare = double.tryParse(_fareController.text.trim()) ?? 0.0;

    if (destination.isEmpty) {
      _showMessage('Ingresa un destino para tu viaje.');
      return;
    }

    if (fare <= 0) {
      _showMessage('Ingresa una tarifa válida.');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = ref.read(authControllerProvider).user;
      final apiClient = ref.read(apiClientProvider);

      final payload = {
        'service_category_id': _serviceCategoryId,
        'origin_address': _originController.text.trim(),
        'origin_latitude': _originLat,
        'origin_longitude': _originLng,
        'destination_address': destination,
        'destination_latitude': _destLat,
        'destination_longitude': _destLng,
        'offered_fare': fare,
        'payment_method': _paymentMethod,
        'distance_km': 3.5,
        'estimated_time_minutes': 10,
      };

      final response = await apiClient.post(
        ApiEndpoints.rideRequests,
        body: payload,
        requiresAuth: true,
      );

      final rideData = response['data'] ?? response['ride_request'] ?? response;
      final int rideId = int.parse((rideData['id'] ?? response['id']).toString());

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CustomerOffersPage(
            requestId: rideId.toString(),
            customerId: user?.id.toString() ?? '1',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error al crear solicitud: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message.replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Pedir Transporte', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceBadge(),
            const SizedBox(height: 20),
            _buildLocationCard(),
            const SizedBox(height: 18),
            _buildFareCard(),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _createRideRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Publicar Solicitud', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            widget.service == 'moto' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
            color: AppColors.navy,
            size: 26,
          ),
          const SizedBox(width: 12),
          Text(
            'Servicio: ${widget.service.toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        children: [
          TextField(
            controller: _originController,
            decoration: const InputDecoration(
              labelText: 'Punto de partida (Origen)',
              prefixIcon: Icon(Icons.my_location_rounded, color: AppColors.navyLight),
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              labelText: '¿A dónde vas? (Destino)',
              hintText: 'Ej. Barrio San José Obrero',
              prefixIcon: Icon(Icons.location_on_rounded, color: Colors.redAccent),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mist),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_outlined, color: AppColors.navy),
          const SizedBox(width: 12),
          const Text('Tarifa ofrecida (Bs):', style: TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _fareController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.sand,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}