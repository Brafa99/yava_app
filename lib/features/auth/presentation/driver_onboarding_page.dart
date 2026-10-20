import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DriverOnboardingPage extends StatefulWidget {
  const DriverOnboardingPage({super.key});

  static const routeName = 'driver-onboarding';
  static const routePath = '/onboarding/driver';

  @override
  State<DriverOnboardingPage> createState() => _DriverOnboardingPageState();
}

class _DriverOnboardingPageState extends State<DriverOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_DriverSlideData> _slides = const [
    // SLIDE 1: Tu vehículo, tus oportunidades. (Botón azul)
    _DriverSlideData(
      bgAsset: 'assets/images/onboarding/driver_onboarding_1.png',
      titleWhite: 'Tu vehículo,',
      titleRed: 'tus oportunidades.',
      subtitle:
          'Conecta con nuevas\noportunidades de servicio\nen Concepción y toda la Chiquitanía.',
      isBlueButton: true,
      bottomCards: [
        _DriverBottomCardData(
          icon: Icons.directions_car_outlined,
          title: 'Movilidad',
          subtitle: 'Lleva personas\na su destino.',
          neonColor: Color(0xFFFF2A3C),
        ),
        _DriverBottomCardData(
          icon: Icons.two_wheeler_rounded,
          title: 'Moto',
          subtitle: 'Gana más en\nmenos tiempo.',
          neonColor: Color(0xFF00A6FF),
        ),
        _DriverBottomCardData(
          icon: Icons.inventory_2_outlined,
          title: 'Envíos',
          subtitle: 'Entrega paquetes\ny mandados.',
          neonColor: Color(0xFF00A6FF),
        ),
        _DriverBottomCardData(
          icon: Icons.groups_outlined,
          title: 'Más servicios',
          subtitle: 'Formá parte\nde toda la plataforma.',
          neonColor: Color(0xFF00A6FF),
        ),
      ],
    ),

    // SLIDE 2: Diferentes formas de trabajar. (5 tarjetas abajo, subtítulo "Un solo YAVÁ.")
    _DriverSlideData(
      bgAsset: 'assets/images/onboarding/driver_onboarding_2.png',
      titleWhite: 'Diferentes formas',
      titleRed: 'de trabajar.',
      boldSubHeader: 'Un solo YAVÁ.',
      subtitle:
          'Diferentes maneras de generar ingresos\ndesde Concepción y toda la Chiquitanía.',
      isBlueButton: false,
      bottomCards: [
        _DriverBottomCardData(
          icon: Icons.directions_car_outlined,
          title: 'Movilidad',
          subtitle: 'Lleva personas\na su destino.',
          neonColor: Color(0xFFFF2A3C),
        ),
        _DriverBottomCardData(
          icon: Icons.two_wheeler_rounded,
          title: 'Moto',
          subtitle: 'Muévete rápido\ny gana más.',
          neonColor: Color(0xFF00A6FF),
        ),
        _DriverBottomCardData(
          icon: Icons.shopping_bag_outlined,
          title: 'Delivery',
          subtitle: 'Entrega pedidos\nde restaurantes\ny comercios.',
          neonColor: Color(0xFFFF2A3C),
        ),
        _DriverBottomCardData(
          icon: Icons.inventory_2_outlined,
          title: 'Compras\nXpress',
          subtitle: 'Retira y entrega\nproductos.',
          neonColor: Color(0xFFFFB300),
        ),
        _DriverBottomCardData(
          icon: Icons.local_shipping_outlined,
          title: 'Carga y\nTransporte',
          subtitle: 'Envíos, encomiendas\ny transporte\nganadero.',
          neonColor: Color(0xFF00E676),
        ),
      ],
    ),

    // SLIDE 3: Todo tu trabajo en un solo lugar.
    _DriverSlideData(
      bgAsset: 'assets/images/onboarding/driver_onboarding_3.png',
      titleWhite: 'Todo tu trabajo',
      titleRed: 'en un solo lugar.',
      subtitle:
          'Solicitudes, rutas, actividad\ny ganancias desde la App\nYAVÁ Driver.',
      isBlueButton: false,
      bottomCards: [
        _DriverBottomCardData(
          icon: Icons.list_alt_rounded,
          title: 'Solicitudes',
          subtitle: 'Recibe servicios\ncerca de ti.',
          neonColor: Color(0xFFFF2A3C),
        ),
        _DriverBottomCardData(
          icon: Icons.route_outlined,
          title: 'Rutas',
          subtitle: 'Navegación integrada\ny en tiempo real.',
          neonColor: Color(0xFF00A6FF),
        ),
        _DriverBottomCardData(
          icon: Icons.bar_chart_rounded,
          title: 'Ganancias',
          subtitle: 'Controla tus ingresos\ndiarios y semanales.',
          neonColor: Color(0xFFFFB300),
        ),
        _DriverBottomCardData(
          icon: Icons.access_time_rounded,
          title: 'Actividad',
          subtitle: 'Historial completo\nde tus servicios.',
          neonColor: Color(0xFFB347FF),
        ),
      ],
    ),

    // SLIDE 4: Tecnología que te acompaña. (Con las 5 cápsulas flotantes a la derecha)
    _DriverSlideData(
      bgAsset: 'assets/images/onboarding/driver_onboarding_4.png',
      titleWhite: 'Tecnología',
      titleRed: 'que te acompaña.',
      subtitle:
          'Herramientas para hacer\ntu trabajo más seguro, rápido\ny eficiente.',
      isBlueButton: false,
      rightCapsules: [
        _RightCapsuleData(
          icon: Icons.location_on_outlined,
          title: 'GPS',
          subtitle: 'en tiempo real',
          neonColor: Color(0xFFFF2A3C),
        ),
        _RightCapsuleData(
          icon: Icons.verified_user_outlined,
          title: 'Seguridad',
          subtitle: 'en cada recorrido',
          neonColor: Color(0xFF00A6FF),
        ),
        _RightCapsuleData(
          icon: Icons.sos_outlined,
          title: 'Botón SOS',
          subtitle: 'ante emergencias',
          neonColor: Color(0xFFFFB300),
        ),
        _RightCapsuleData(
          icon: Icons.cloud_done_outlined,
          title: 'Funciona',
          subtitle: 'también offline',
          neonColor: Color(0xFFB347FF),
        ),
        _RightCapsuleData(
          icon: Icons.headset_mic_outlined,
          title: 'Soporte',
          subtitle: 'siempre disponible',
          neonColor: Color(0xFF00E676),
        ),
      ],
      bottomCards: [
        _DriverBottomCardData(
          icon: Icons.map_outlined,
          title: 'Navegación',
          subtitle: 'Rutas óptimas\ny tráfico en tiempo real.',
          neonColor: Color(0xFFFF2A3C),
        ),
        _DriverBottomCardData(
          icon: Icons.verified_user_outlined,
          title: 'Mayor seguridad',
          subtitle: 'Viaja con respaldo\nde YAVÁ.',
          neonColor: Color(0xFF00A6FF),
        ),
        _DriverBottomCardData(
          icon: Icons.bar_chart_rounded,
          title: 'Más ganancias',
          subtitle: 'Más servicios\nen tu zona.',
          neonColor: Color(0xFFFFB300),
        ),
        _DriverBottomCardData(
          icon: Icons.groups_outlined,
          title: 'Comunidad',
          subtitle: 'Somos conductores\nde la Chiquitanía.',
          neonColor: Color(0xFFB347FF),
        ),
      ],
    ),

    // SLIDE 5: Crecemos con nuestra gente. (Botón "Ser parte de YAVÁ >")
    _DriverSlideData(
      bgAsset: 'assets/images/onboarding/driver_onboarding_5.png',
      titleWhite: 'Crecemos con',
      titleRed: 'nuestra gente.',
      subtitle: 'Nacemos en Concepción\npara toda la Chiquitanía.',
      isBlueButton: false,
      bottomCards: [
        _DriverBottomCardData(
          icon: Icons.groups_outlined,
          title: 'Comunidad',
          subtitle: 'Formá parte\nde un equipo\nque crece contigo.',
          neonColor: Color(0xFFFF2A3C),
        ),
        _DriverBottomCardData(
          icon: Icons.bar_chart_rounded,
          title: 'Más ingresos',
          subtitle: 'Aumenta tus\noportunidades\nde trabajo.',
          neonColor: Color(0xFF00A6FF),
        ),
        _DriverBottomCardData(
          icon: Icons.star_border_rounded,
          title: 'Reconocimiento',
          subtitle: 'Tu esfuerzo\nimpulsa el desarrollo\nde nuestra región.',
          neonColor: Color(0xFFFFB300),
        ),
        _DriverBottomCardData(
          icon: Icons.eco_outlined,
          title: 'Impacto local',
          subtitle: 'Juntos movemos\nla Chiquitanía hacia\nun mejor futuro.',
          neonColor: Color(0xFF00E676),
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
    context.push('/register', extra: 'driver');
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
            // 1. PageView con las 5 vistas del Conductor
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _DriverSlideView(
                  data: _slides[index],
                  topPadding: topPadding,
                );
              },
            ),

            // 2. Botón "Saltar" fijo arriba a la derecha
            Positioned(
              top: topPadding + 10,
              right: 16,
              child: TextButton(
                onPressed: _goToRegister,
                child: const Text(
                  'Saltar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // 3. Controles Inferiores Fijos (Omitir • 5 Puntos • Siguiente / Ser parte de YAVÁ)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 18, 18),
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

                      // 5 Puntos Indicadores
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_slides.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8.5,
                            height: 8.5,
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

                      // Botón Dinámico (Azul en Slide 1, Rojo en 2-5, "Ser parte de YAVÁ" en 5)
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLastSlide ? 16 : 22,
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
                                      'Ser parte de ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
          height: 10,
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

// --- VISTA INDIVIDUAL DE CADA SLIDE DEL CONDUCTOR ---
class _DriverSlideView extends StatelessWidget {
  final _DriverSlideData data;
  final double topPadding;

  const _DriverSlideView({
    required this.data,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final hasRightCapsules = data.rightCapsules.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fondo vertical 9:16
        // 1. Fondo vertical con Zoom Out (muestra el 100% del ancho sin cortar los lados)
        // 1. Cubre toda la pantalla de arriba a abajo y de lado a lado sin recortar bordes
        Image.asset(
          data.bgAsset,
          fit: BoxFit.fill, // <-- Muestra el 100% de la imagen en toda la pantalla
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF041226),
          ),
        ),

        // 2. Gradiente sutil superior e inferior
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF030B18).withValues(alpha: 0.45),
                Colors.transparent,
                Colors.transparent,
                const Color(0xFF020710).withValues(alpha: 0.90),
              ],
              stops: const [0.0, 0.36, 0.70, 1.0],
            ),
          ),
        ),

        // 3. Columna de 5 Cápsulas Flotantes a la derecha (Exclusivo del Slide 4)
        if (hasRightCapsules)
          Positioned(
            top: topPadding + 52,
            right: 12,
            width: 158,
            child: Column(
              children: data.rightCapsules
                  .map((cap) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: _FloatingRightCapsule(data: cap),
                      ))
                  .toList(),
            ),
          ),

        // 4. Contenido Principal
        Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding + 22, 16, 82),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: YAVÁ DRIVER • CONDUCTOR
              _buildDriverLogoHeader(),

              const SizedBox(height: 8),

              // Línea bicolor roja/azul
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1E27),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Títulos principales (Si estamos en Slide 4 dejamos margen derecho para no chocar con las cápsulas)
              Padding(
                padding: EdgeInsets.only(right: hasRightCapsules ? 148 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.titleWhite,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: hasRightCapsules ? 30 : 35,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.titleRed,
                        style: TextStyle(
                          color: const Color(0xFFFF1220),
                          fontSize: hasRightCapsules ? 28 : 35,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    if (data.boldSubHeader != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        data.boldSubHeader!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: hasRightCapsules ? 13 : 14.5,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Fila Responsiva de 4 o 5 Tarjetas Glassmorphism en la parte inferior
              _DriverBottomCardsRow(cards: data.bottomCards),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverLogoHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
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
        const SizedBox(height: 4),
        const Text(
          'DRIVER • CONDUCTOR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }
}

// --- FILA RESPONSIVA DE 4 O 5 TARJETAS GLASSMORPHISM ---
class _DriverBottomCardsRow extends StatelessWidget {
  final List<_DriverBottomCardData> cards;

  const _DriverBottomCardsRow({required this.cards});

  @override
  Widget build(BuildContext context) {
    final isFiveCards = cards.length >= 5;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards.map((card) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isFiveCards ? 2.2 : 3.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: isFiveCards ? 116 : 112,
                  padding: EdgeInsets.symmetric(
                    horizontal: isFiveCards ? 3 : 5,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071324).withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        card.icon,
                        color: card.neonColor,
                        size: isFiveCards ? 22 : 26,
                        shadows: [
                          Shadow(color: card.neonColor, blurRadius: 10),
                          Shadow(
                            color: card.neonColor.withValues(alpha: 0.65),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          card.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isFiveCards ? 9.5 : 11,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: Center(
                          child: Text(
                            card.subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: isFiveCards ? 7.2 : 8.2,
                              fontWeight: FontWeight.w400,
                              height: 1.15,
                            ),
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

// --- CÁPSULA FLOTANTE DERECHA (SLIDE 4: GPS, SEGURIDAD, SOS, OFFLINE, SOPORTE) ---
class _FloatingRightCapsule extends StatelessWidget {
  final _RightCapsuleData data;

  const _FloatingRightCapsule({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF081629).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 0.9,
            ),
          ),
          child: Row(
            children: [
              Icon(
                data.icon,
                color: data.neonColor,
                size: 20,
                shadows: [
                  Shadow(color: data.neonColor, blurRadius: 10),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w400,
                      ),
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
}

// --- MODELOS DE DATOS DEL ONBOARDING DE CONDUCTOR ---
class _DriverSlideData {
  final String bgAsset;
  final String titleWhite;
  final String titleRed;
  final String? boldSubHeader;
  final String subtitle;
  final bool isBlueButton;
  final List<_DriverBottomCardData> bottomCards;
  final List<_RightCapsuleData> rightCapsules;

  const _DriverSlideData({
    required this.bgAsset,
    required this.titleWhite,
    required this.titleRed,
    this.boldSubHeader,
    required this.subtitle,
    required this.isBlueButton,
    required this.bottomCards,
    this.rightCapsules = const [],
  });
}

class _DriverBottomCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color neonColor;

  const _DriverBottomCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.neonColor,
  });
}

class _RightCapsuleData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color neonColor;

  const _RightCapsuleData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.neonColor,
  });
}