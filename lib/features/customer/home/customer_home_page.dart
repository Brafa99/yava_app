import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/yava_ui_tokens.dart';
import '../../../shared/models/service_category_model.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/application/auth_controller.dart';
import 'customer_home_sections.dart';

// Provider reactivo para alternar entre Modo Día y Noche
final homeNightModeProvider = StateProvider<bool>((ref) => true);

// Provider conectado a GET /api/service-categories/list-all de Laravel CON LOGS
final serviceCategoriesProvider = FutureProvider.autoDispose<List<ServiceCategoryModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  
  print('\n\n🔴 === PRUEBA DE CONEXIÓN API YAVÁ === 🔴');
  print('Llamando a: GET /api/service-categories/list-all');
  
  try {
    final response = await apiClient.get(ApiEndpoints.serviceCategories, requiresAuth: true);
    print('✅ RESPUESTA DE LARAVEL:');
    print(response.toString());
    print('🔴 ==================================== 🔴\n\n');
    
    final List data = response is Map ? (response['data'] ?? []) : response;
    final categories = data.map((json) => ServiceCategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    
    return categories;
  } catch (e) {
    print('❌ ERROR CRÍTICO EN LA API: $e');
    return [];
  }
});

class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  static const routeName = 'customer-home';
  static const routePath = '/customer/home';

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isNight = ref.watch(homeNightModeProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    // Manejo seguro del estado de Riverpod con .maybeWhen
    final allCategories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <ServiceCategoryModel>[],
    );
    final isLoading = categoriesAsync.isLoading;
    
    final mobilityCategories = allCategories.where((c) => c.type == 'MOVILIDAD').toList();
    final deliveryCategories = allCategories.where((c) => c.type == 'DELIVERY').toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: YavaUiTokens.background,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: YavaBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (i) {
            setState(() => _currentNavIndex = i);
            if (i == 1) context.push('/customer/trips');
            if (i == 3) context.push('/delivery/categories');
            if (i == 4) context.push('/customer/profile');
          },
        ),
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 430,
                child: Stack(
                  fit: isNight ? StackFit.expand : StackFit.loose,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Image.asset(
                        isNight
                            ? 'assets/images/concepcion_catedral_night.png'
                            : 'assets/images/concepcion_catedral.png',
                        key: ValueKey(isNight),
                        fit: BoxFit.contain,
                        alignment: const Alignment(0, 2),
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF061426)),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                            YavaUiTokens.background.withValues(alpha: 0.55),
                            YavaUiTokens.background,
                          ],
                          stops: const [0.0, 0.45, 0.82, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12, topPadding + 0, 12, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomerTopBar(
                      isNight: isNight,
                      onToggleTheme: () {
                        ref.read(homeNightModeProvider.notifier).state = !isNight;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomerHeroTitle(isNight: ref.watch(homeNightModeProvider)),
                    const SizedBox(height: 24),

                    // Mostramos indicador de carga nativo si está obteniendo los servicios
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFFE50914)),
                        ),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MobilityMainCard(
                              categories: mobilityCategories,
                              onActionTap: () => context.push('/transport/customer-quick-request?category=auto'),
                              onCategoryTap: (slug) {
                                log('👉 Clic en acceso directo de Movilidad: $slug', name: 'UI_ACTION');
                                context.push(
                                  '/transport/customer-quick-request?category=$slug',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DeliveryMainCard(
                              isNight: isNight,
                              categories: deliveryCategories,
                              onActionTap: () => context.push('/delivery/categories'),
                              onCategoryTap: (slug) {
                                log('👉 Clic en acceso directo de Delivery: $slug', name: 'UI_ACTION');
                                context.push('/delivery/store-list?category=$slug');
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),

                    const ConcepcionPromoBanner(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}