import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_client.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/driver/models/driver_vehicle_model.dart';

final driverVehicleProvider = FutureProvider.autoDispose<DriverVehicleModel?>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiEndpoints.driverVehicle, requiresAuth: true);
    final data = response['data'] ?? response;
    if (data == null) return null;
    return DriverVehicleModel.fromJson(data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

class DriverVehiclesPage extends ConsumerWidget {
  const DriverVehiclesPage({super.key});

  static const routePath = '/driver/vehicles';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(driverVehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Mi Vehículo', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 64, color: AppColors.mutedInk),
                  const SizedBox(height: 12),
                  const Text('No tienes un vehículo registrado aún.', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
                    child: const Text('Registrar Vehículo'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 54),
                    const SizedBox(height: 12),
                    Text('${vehicle.marca} ${vehicle.modelo}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${vehicle.color} • Año ${vehicle.anho}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.sunrise, borderRadius: BorderRadius.circular(12)),
                      child: Text(vehicle.placa, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.navy)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _item(Icons.people_alt_outlined, 'Capacidad', '${vehicle.capacidad} pasajeros'),
              _item(Icons.category_outlined, 'Tipo de Vehículo', vehicle.tipoVehiculo),
              _item(Icons.verified_user_outlined, 'Estado RUAT / SOAT', vehicle.status ? 'Habilitado' : 'En revisión'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navy)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _item(IconData icon, String title, String value) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navy),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.mutedInk)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
        ],
      ),
    );
  }
}