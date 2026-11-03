import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // <-- Inyectado Geolocator
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/core/services/onboarding_service.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/auth/domain/entities/app_user.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  int _currentSlide = 0;
  AppUser? _loadedUser;
  bool _authCheckCompleted = false;
  bool _locationCheckCompleted = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        if (_progressController.value >= 0.50 && _currentSlide == 0) {
          setState(() => _currentSlide = 1);
        }
      });

    _progressController.forward().whenComplete(_navigateNext);

    Future.microtask(() {
      _checkSessionInParallel();
      _requestLocationPermissions(); // <-- Solicitar permisos en paralelo
    });
  }

  Future<void> _checkSessionInParallel() async {
    try {
      final user = await ref.read(authControllerProvider.notifier).loadCurrentUser();
      _loadedUser = user;
    } catch (_) {
      _loadedUser = null;
    } finally {
      _authCheckCompleted = true;
    }
  }

  /// Solicita el permiso de GPS del sistema operativo mientras carga el splash
  /// Solicita el permiso de la app y fuerza el encendido del sensor GPS
  Future<void> _requestLocationPermissions() async {
    try {
      // 1. Pedir permisos a nivel de aplicación ANTES de revisar el sensor
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Si nos dio permiso, revisamos si tiene el sensor GPS apagado de raíz
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Fuerza al usuario a ir a los ajustes del celular para prender el GPS
          await Geolocator.openLocationSettings();
          
          // Opcional: Esperamos unos segundos para darle tiempo de prenderlo y volver
          await Future.delayed(const Duration(seconds: 3)); 
        }
      }
    } catch (_) {
      // Ignorar errores silenciosamente para que la app no se congele en el Splash
    } finally {
      _locationCheckCompleted = true;
    }
  }

  Future<void> _navigateNext() async {
    if (!_authCheckCompleted || !_locationCheckCompleted) {
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (!mounted) return;

    if (_loadedUser != null) {
      if (_loadedUser!.role == 'driver') {
        context.go('/driver/home');
      } else {
        context.go('/customer/home');
      }
      return;
    }

    try {
      final completed = await ref.read(onboardingServiceProvider).hasCompleted();
      if (!mounted) return;
      context.go(completed ? '/login' : '/auth-entry');
    } catch (_) {
      if (mounted) context.go('/auth-entry');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030812),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: Image.asset(
                _currentSlide == 0
                    ? 'assets/images/splash_images/splash1.png'
                    : 'assets/images/splash_images/splash2.png',
                key: ValueKey<int>(_currentSlide),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF041432), Color(0xFF1A0F1E), Color(0xFF030812)],
                    ),
                  ),
                ),
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
                    Colors.black.withValues(alpha: 0.40),
                    const Color(0xFF020710).withValues(alpha: 0.90),
                  ],
                  stops: const [0.0, 0.38, 0.72, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, topPadding + 54, 20, 26),
              child: Column(
                children: [
                  _buildBrandHeader(),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 650),
                    child: _currentSlide == 0
                        ? _buildFirstSlideTitle()
                        : _buildSecondSlideTitle(),
                  ),
                  const Spacer(),
                  _buildNeonServicesBar(),
                  const SizedBox(height: 58),
                  _buildFooterProgress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        SizedBox(
          height: 58,
          child: Image.asset(
            'assets/images/yava_home_bg.png',
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
        const SizedBox(height: 6),
        const Text(
          'N A C E   E N   C O N C E P C I Ó N',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 46,
          height: 3.5,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE50914),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFirstSlideTitle() {
    return Column(
      key: const ValueKey('slide_1_title'),
      children: [
        Transform.rotate(
          angle: -0.03,
          child: const Text(
            'Para toda la Chiquitanía',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomPaint(
          size: const Size(240, 16),
          painter: _GlowingSwooshPainter(),
        ),
      ],
    );
  }

  Widget _buildSecondSlideTitle() {
    return Column(
      key: const ValueKey('slide_2_title'),
      children: [
        const Text(
          'La Chiquitanía',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'conectada',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF00C8FF),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Color(0x8800C8FF),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'en una sola App',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        CustomPaint(
          size: const Size(220, 12),
          painter: _GlowingSwooshPainter(),
        ),
      ],
    );
  }

  Widget _buildNeonServicesBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF050E1D).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: _NeonServiceItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Movilidad',
                  neonColor: Color(0xFF00A6FF),
                ),
              ),
              _verticalDivider(),
              const Expanded(
                child: _NeonServiceItem(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Delivery',
                  neonColor: Color(0xFFFF2A3C),
                ),
              ),
              _verticalDivider(),
              const Expanded(
                child: _NeonServiceItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Compras',
                  neonColor: Color(0xFFFF8C00),
                ),
              ),
              _verticalDivider(),
              const Expanded(
                child: _NeonServiceItem(
                  icon: Icons.groups_outlined,
                  label: 'Más servicios',
                  neonColor: Color(0xFFB347FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.16),
    );
  }

  Widget _buildFooterProgress() {
    return Column(
      children: [
        const Text(
          'C A S A   M A T R I Z   •   C O N C E P C I Ó N',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Ñ U F L O   D E   C H Á V E Z   •   S A N T A   C R U Z   •   B O L I V I A',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, _) {
            return Container(
              width: 150,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF152942),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _progressController.value.clamp(0.08, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1E27), Color(0xFFFF5252)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFF1E27),
                        blurRadius: 8,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NeonServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color neonColor;

  const _NeonServiceItem({
    required this.icon,
    required this.label,
    required this.neonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: neonColor,
          size: 28,
          shadows: [
            Shadow(color: neonColor, blurRadius: 12),
            Shadow(color: neonColor.withValues(alpha: 0.7), blurRadius: 22),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GlowingSwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        -size.height * 0.4,
        size.width,
        size.height * 0.35,
      );

    final glowPaint = Paint()
      ..color = const Color(0xFFE50914).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final corePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xFFE50914),
          Colors.white,
          Color(0xFFE50914),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}