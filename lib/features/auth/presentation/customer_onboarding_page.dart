import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CustomerOnboardingPage extends StatefulWidget {
  const CustomerOnboardingPage({super.key});

  static const routeName = 'customer-onboarding';
  static const routePath = '/onboarding/customer';

  @override
  State<CustomerOnboardingPage> createState() => _CustomerOnboardingPageState();
}

class _CustomerOnboardingPageState extends State<CustomerOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Configuración exacta de los 4 Sliders según los mockups
  final List<_CustomerSlideData> _slides = const [
    // SLIDER 1: Movilidad (Iconos verticales a la izquierda, botón rojo)
    _CustomerSlideData(
      bgAsset: 'assets/images/onboarding/customer_onboarding_1.png',
      titleLine1: 'Tu destino,',
      titleLine2: 'más cerca.',
      titleLine2Color: Color(0xFFFF1220),
      subtitle: 'Solicita movilidad de manera\nsencilla desde tu celular.',
      useVerticalSideLayout: true,
      isBlueButton: false,
      sideItems: [
        _SideFeatureItem(
          icon: Icons.directions_car_outlined,
          topRightLabel: 'Auto',
          bottomLabel: 'Auto',
        ),
        _SideFeatureItem(
          icon: Icons.two_wheeler_rounded,
          bottomLabel: 'Moto',
        ),
        _SideFeatureItem(
          icon: Icons.groups_outlined,
          rightLabel: 'Transporte',
        ),
      ],
    ),

    // SLIDER 2: Delivery (4 cards horizontales abajo, título celeste, botón azul)
    _CustomerSlideData(
      bgAsset: 'assets/images/onboarding/customer_onboarding_2.png',
      titleLine1: 'Lo que necesitas,',
      titleLine2: 'donde estés.',
      titleLine2Color: Color(0xFF00B8FF),
      subtitle: 'Restaurantes, tiendas, farmacias,\nmercados, envíos y mandados.',
      useVerticalSideLayout: false,
      isBlueButton: true,
      bottomGridItems: [
        _BottomGridFeatureItem(
          icon: Icons.restaurant_rounded,
          label: 'Comida',
          neonColor: Color(0xFFFF2A3C),
        ),
        _BottomGridFeatureItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Tiendas',
          neonColor: Color(0xFF00A6FF),
        ),
        _BottomGridFeatureItem(
          icon: Icons.add_box_outlined,
          label: 'Farmacias',
          neonColor: Color(0xFF00A6FF),
        ),
        _BottomGridFeatureItem(
          icon: Icons.inventory_2_outlined,
          label: 'Envíos',
          neonColor: Color(0xFF00A6FF),
        ),
      ],
    ),

    // SLIDER 3: Tracking en tiempo real (4 cards abajo, título rojo, botón azul)
    _CustomerSlideData(
      bgAsset: 'assets/images/onboarding/customer_onboarding_3.png',
      titleLine1: 'Sabes quién viene',
      titleLine2: 'y dónde está.',
      titleLine2Color: Color(0xFFFF1220),
      subtitle: 'Sigue tu servicio en tiempo real\ndesde la solicitud hasta su llegada.',
      useVerticalSideLayout: false,
      isBlueButton: true,
      bottomGridItems: [
        _BottomGridFeatureItem(
          icon: Icons.location_on_outlined,
          label: 'Tracking',
          neonColor: Color(0xFFFF2A3C),
        ),
        _BottomGridFeatureItem(
          icon: Icons.verified_user_outlined,
          label: 'Seguro',
          neonColor: Color(0xFF00A6FF),
        ),
        _BottomGridFeatureItem(
          icon: Icons.access_time_rounded,
          label: 'Tiempo real',
          neonColor: Color(0xFF00A6FF),
        ),
        _BottomGridFeatureItem(
          icon: Icons.timeline_rounded,
          label: 'Rutas',
          neonColor: Color(0xFFFFB300),
        ),
      ],
    ),

    // SLIDER 4: Ecosistema completo (3 líneas de título, ubicación matriz, botón "Comenzar con YAVÁ")
    _CustomerSlideData(
      bgAsset: 'assets/images/onboarding/customer_onboarding_4.png',
      titleLine1: 'La Chiquitanía',
      titleLine2: 'conectada',
      titleLine2Color: Color(0xFFFF1220),
      titleLine3: 'en una sola App.',
      subtitle: 'Movilidad, Delivery, Compras\ny más servicios para nuestra gente.',
      useVerticalSideLayout: false,
      isBlueButton: false,
      showHeadquartersFooter: true,
      bottomGridItems: [
        _BottomGridFeatureItem(
          icon: Icons.directions_car_outlined,
          label: 'Movilidad',
          neonColor: Color(0xFF00A6FF),
        ),
        _BottomGridFeatureItem(
          icon: Icons.two_wheeler_rounded,
          label: 'Delivery',
          neonColor: Color(0xFFFF2A3C),
        ),
        _BottomGridFeatureItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Compras',
          neonColor: Color(0xFFFFB300),
        ),
        _BottomGridFeatureItem(
          icon: Icons.groups_outlined,
          label: 'Más servicios',
          neonColor: Color(0xFFB347FF),
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToRegister() {
    context.push('/register', extra: 'client');
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final currentSlide = _slides[_currentPage];
    final isLastSlide = _currentPage == _slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030812),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. PageView de los 4 Sliders
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _CustomerSlideView(
                  data: _slides[index],
                  topPadding: topPadding,
                );
              },
            ),

            // 2. Barra de Controles Inferior (Omitir • 4 Puntos • Botón Dinámico Rojo/Azul)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Omitir
                      TextButton(
                        onPressed: _goToRegister,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Omitir',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // 4 Puntos indicadores
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_slides.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4.5),
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFFF1E27)
                                  : const Color(0xFF2B3E58),
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? const [
                                      BoxShadow(
                                        color: Color(0xFFFF1E27),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),

                      // Botón Siguiente / Comenzar con YAVÁ (Cambia entre Rojo y Azul según el Slide)
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLastSlide ? 18 : 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: currentSlide.isBlueButton
                                  ? const [Color(0xFF0066FF), Color(0xFF003BB5)]
                                  : const [Color(0xFFE50914), Color(0xFFB3000C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: currentSlide.isBlueButton
                                  ? const Color(0xFF4DC3FF)
                                  : const Color(0xFFFF6B72),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (currentSlide.isBlueButton
                                        ? const Color(0xFF0075FF)
                                        : const Color(0xFFE50914))
                                    .withValues(alpha: 0.65),
                                blurRadius: 18,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isLastSlide
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Comenzar con ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
          height: 12,
          child: Image.asset(
            'assets/images/yava_home_bg_empty.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: 'YAV'),
                  TextSpan(
                    text: 'Á',
                    style: TextStyle(color: Color(0xFFE50914)),
                  ),
                ],
              ),
            ),
          ),
        ),
                                   
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Siguiente',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- VISTA INDIVIDUAL DE CADA SLIDE ---
class _CustomerSlideView extends StatelessWidget {
  final _CustomerSlideData data;
  final double topPadding;

  const _CustomerSlideView({
    required this.data,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Imagen de fondo 9:16
        Image.asset(
          data.bgAsset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF041226),
          ),
        ),

        // 2. Sombreado superior e inferior para lectura nítida
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF030B18).withValues(alpha: 0.40),
                Colors.transparent,
                Colors.transparent,
                const Color(0xFF020710).withValues(alpha: 0.90),
              ],
              stops: const [0.0, 0.35, 0.72, 1.0],
            ),
          ),
        ),

        // 3. Contenido Superpuesto
        Padding(
          padding: EdgeInsets.fromLTRB(22, topPadding + 24, 22, 86),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo YAVÁ + NACE EN CONCEPCIÓN
              _buildLogoHeader(),

              const SizedBox(height: 8),

              // Línea bicolor roja/azul debajo del logo
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1E27),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Títulos principales (2 o 3 líneas según el Slide)
              Text(
                data.titleLine1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.05,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                data.titleLine2,
                style: TextStyle(
                  color: data.titleLine2Color,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.05,
                  letterSpacing: -0.8,
                ),
              ),
              if (data.titleLine3 != null)
                Text(
                  data.titleLine3!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                    letterSpacing: -0.6,
                  ),
                ),

              const SizedBox(height: 4),

              // Subtítulo descriptivo
              Text(
                data.subtitle,
                style: TextStyle(
                  color: const Color.fromARGB(255, 230, 224, 224),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.32,
                ),
              ),

              const Spacer(),

              // Layout Condicional: Columna izquierda (Slider 1) vs Grid de 4 tarjetas abajo (Sliders 2, 3 y 4)
              if (data.useVerticalSideLayout)
                _SideFeaturesTimeline(items: data.sideItems)
              else
                _BottomFourCardsRow(items: data.bottomGridItems),

              // Pie de Casa Matriz exclusivo del Slider 4
              if (data.showHeadquartersFooter) ...[
                const SizedBox(height: 14),
                const _HeadquartersLocationRow(),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 58,
          child: Image.asset(
            'assets/images/yava_home_bg_empty.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: 'YAV'),
                  TextSpan(
                    text: 'Á',
                    style: TextStyle(color: Color(0xFFE50914)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'N A C E   E N   C O N C E P C I Ó N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.1,
          ),
        ),
      ],
    );
  }
}

// --- FILA DE 4 TARJETAS GLASSMORPHISM CON ICONOS NEÓN (SLIDERS 2, 3 Y 4) ---
class _BottomFourCardsRow extends StatelessWidget {
  final List<_BottomGridFeatureItem> items;

  const _BottomFourCardsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: 84,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071324).withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: item.neonColor,
                        size: 28,
                        shadows: [
                          Shadow(color: item.neonColor, blurRadius: 12),
                          Shadow(
                            color: item.neonColor.withValues(alpha: 0.7),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// --- TEXTO DE UBICACIÓN CASA MATRIZ (SLIDER 4) ---
class _HeadquartersLocationRow extends StatelessWidget {
  const _HeadquartersLocationRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Color(0xFFFF1E27),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'C a s a   M a t r i z   ·   C o n c e p c i ó n',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'Ñ u f l o   d e   C h á v e z   ·   S a n t a   C r u z   ·   B o l i v i a',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: 9.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// --- COLUMNA DE ICONOS CIRCULARES A LA IZQUIERDA (SLIDER 1) ---
class _SideFeaturesTimeline extends StatelessWidget {
  final List<_SideFeatureItem> items;

  const _SideFeaturesTimeline({required this.items});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -10,
          top: 24,
          bottom: 14,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 182, 94, 53),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // gradient: RadialGradient(
                              //   colors: [
                              //     const Color(0xFF8B1A24).withValues(alpha: 0.72),
                              //     const Color(0xFF2B0910).withValues(alpha: 0.82),
                              //   ],
                              // ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.65),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              color:  Color(0xFF8B1A24).withValues(alpha: 0.72),
                              // const Color(0xFF8B1A24).withValues(alpha: 0.72),
                              // const Color(0xFF2B0910).withValues(alpha: 0.82),
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                      if (item.topRightLabel != null || item.rightLabel != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          item.rightLabel ?? item.topRightLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 8),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.bottomLabel != null) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 38,
                      child: Text(
                        item.bottomLabel!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// --- MODELOS DE DATOS INTERNOS ---
class _CustomerSlideData {
  final String bgAsset;
  final String titleLine1;
  final String titleLine2;
  final Color titleLine2Color;
  final String? titleLine3;
  final String subtitle;
  final bool useVerticalSideLayout;
  final bool isBlueButton;
  final bool showHeadquartersFooter;
  final List<_SideFeatureItem> sideItems;
  final List<_BottomGridFeatureItem> bottomGridItems;

  const _CustomerSlideData({
    required this.bgAsset,
    required this.titleLine1,
    required this.titleLine2,
    required this.titleLine2Color,
    this.titleLine3,
    required this.subtitle,
    required this.useVerticalSideLayout,
    required this.isBlueButton,
    this.showHeadquartersFooter = false,
    this.sideItems = const [],
    this.bottomGridItems = const [],
  });
}

class _SideFeatureItem {
  final IconData icon;
  final String? topRightLabel;
  final String? bottomLabel;
  final String? rightLabel;

  const _SideFeatureItem({
    required this.icon,
    this.topRightLabel,
    this.bottomLabel,
    this.rightLabel,
  });
}

class _BottomGridFeatureItem {
  final IconData icon;
  final String label;
  final Color neonColor;

  const _BottomGridFeatureItem({
    required this.icon,
    required this.label,
    required this.neonColor,
  });
}