import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/yava_ui_tokens.dart';
import '../../../shared/models/service_category_model.dart';
import '../../driver/home/driver_home_page.dart';
import 'customer_home_sections.dart';

// Provider reactivo para alternar entre Modo Día y Noche
final homeNightModeProvider = StateProvider<bool>((ref) => true);

// Provider conectado a GET /api/service-categories de Laravel
final serviceCategoriesProvider = FutureProvider.autoDispose<List<ServiceCategoryModel>>((ref) async {
  final ds = ref.watch(transportRemoteDataSourceProvider);
  return ds.getServiceCategories();
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

    final allCategories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <ServiceCategoryModel>[],
    );
    final mobilityCategories = allCategories.where((c) => c.type == 'MOVILIDAD').toList();
    final deliveryCategories = allCategories.where((c) => c.type == 'DELIVERY').toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: YavaUiTokens.background,
        extendBodyBehindAppBar: true,
        // Anclamos el BottomNavBar al fondo real del Scaffold para eliminar el hueco negro
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
              // 1. Fondo de la Catedral con mayor visibilidad antes de los cards
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 430,
                child: Stack(
                  fit:
                  isNight
                  ? StackFit.expand
                  : StackFit.loose,
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

              // 2. Contenido Scrollable con espaciado estético arriba
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
                    const SizedBox(height: 24), // Espacio limpio para lucir la catedral y separar textos
                    CustomerHeroTitle(isNight: ref.watch(homeNightModeProvider)),
                    const SizedBox(height: 24), // Espacio antes de las tarjetas

                    // 3. Módulos Principales de Movilidad y Delivery
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MobilityMainCard(
                            categories: mobilityCategories,
                            onActionTap: () => context.push('/customer/new-request'),
                            onCategoryTap: (slug) {
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
                              context.push('/delivery/store-list?category=$slug');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4. Banner Promocional Inferior
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