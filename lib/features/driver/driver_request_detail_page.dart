import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_client.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/driver/home/driver_home_page.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';


class DriverRequestDetailPage extends ConsumerStatefulWidget {
  const DriverRequestDetailPage({super.key, required this.requestId});

  final String requestId;
  static const routePath = '/driver/requests/:requestId';

  @override
  ConsumerState<DriverRequestDetailPage> createState() => _DriverRequestDetailPageState();
}

class _DriverRequestDetailPageState extends ConsumerState<DriverRequestDetailPage> {
  final _fareController = TextEditingController();
  RideRequestModel? _ride;
  bool _loading = true;
  bool _sendingOffer = false;
  bool _offerSent = false;
  Timer? _statusPolling;

  @override
  void initState() {
    super.initState();
    _loadRideDetail();
    // Verifica si el cliente ya aceptó nuestra oferta
    _statusPolling = Timer.periodic(const Duration(seconds: 4), (_) => _checkIfAccepted());
  }

  @override
  void dispose() {
    _statusPolling?.cancel();
    _fareController.dispose();
    super.dispose();
  }

  Future<void> _loadRideDetail() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final id = int.parse(widget.requestId);
      final response = await apiClient.get(ApiEndpoints.rideDetail(id), requiresAuth: true);
      final data = response['data'] ?? response;

      if (!mounted) return;
      final rideModel = RideRequestModel.fromJson(data);
      setState(() {
        _ride = rideModel;
        _fareController.text = rideModel.offeredFare.toStringAsFixed(0);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIfAccepted() async {
    if (_ride == null) return;
    try {
      final apiClient = ref.read(apiClientProvider);
      final id = int.parse(widget.requestId);
      final response = await apiClient.get(ApiEndpoints.rideDetail(id), requiresAuth: true);
      final data = response['data'] ?? response;
      final rideModel = RideRequestModel.fromJson(data);

      if (!mounted) return;
      if (rideModel.status == 'ACEPTADO' || rideModel.status == 'EN_ORIGEN') {
        _statusPolling?.cancel();
        context.pushReplacement('/driver/tracking?rideId=${widget.requestId}');
      }
    } catch (_) {}
  }

  Future<void> _sendOffer() async {
    final fare = double.tryParse(_fareController.text.trim());
    if (fare == null || fare <= 0) {
      _showMessage('Ingresa un monto válido.');
      return;
    }

    setState(() => _sendingOffer = true);

    try {
      final ds = ref.read(transportRemoteDataSourceProvider);
      final rideId = int.parse(widget.requestId);

      // Endpoint real: POST /api/ride-requests/{id}/offer
      await ds.sendDriverOffer(rideId, fare);

      if (!mounted) return;
      setState(() {
        _offerSent = true;
        _sendingOffer = false;
      });
      _showMessage('Oferta enviada. Esperando aceptación del cliente.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendingOffer = false);
      _showMessage('Error al enviar oferta: $e');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.replaceFirst('Exception: ', '')), backgroundColor: AppColors.navy),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Detalle de Solicitud', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : _ride == null
              ? const Center(child: Text('Solicitud no encontrada.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de Ruta
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.mist),
                        ),
                        child: Column(
                          children: [
                            _routeTile(Icons.my_location_rounded, AppColors.navyLight, 'Origen', _ride!.originAddress ?? 'Origen'),
                            const Padding(padding: EdgeInsets.only(left: 14), child: Divider()),
                            _routeTile(Icons.location_on_rounded, AppColors.clay, 'Destino', _ride!.destinationAddress ?? 'Destino'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tarifa sugerida por el cliente
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.mist,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tarifa inicial del cliente:', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text('Bs ${_ride!.offeredFare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.navy)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Formulario de Oferta
                      if (!_offerSent) ...[
                        const Text('Tu contraoferta (Bs):', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _fareController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: 'Bs ',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _sendingOffer ? null : _sendOffer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _sendingOffer
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Enviar Contraoferta', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Oferta enviada.\nEsperando confirmación del cliente...',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _routeTile(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedInk, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}