import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/core/services/onboarding_service.dart';

import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/auth/domain/entities/app_user.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({
    super.key,
    this.onFinished,
  });

  /// La navegación real debe ser gestionada por GoRouter.
  /// Este callback únicamente notifica que terminó la animación.
  final VoidCallback? onFinished;

  @override
  ConsumerState<SplashPage> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(milliseconds: 3200);

  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _navigationTimer = Timer(
      _splashDuration,
      _handleStartup,
    );
  }

  Future<void> _handleStartup() async {
  if (!mounted) return;

  final user = await ref
      .read(authControllerProvider.notifier)
      .loadCurrentUser();

  if (!mounted) return;

  // Hay una sesión activa.
  if (user != null) {
    switch (user.role) {
      case UserRole.customer:
        context.go('/customer/home');
        break;

      case UserRole.driver:
        context.go('/driver/home');
        break;
    }

    return;
  }

  // No hay sesión.
  final onboardingCompleted =
      await ref.read(onboardingServiceProvider).hasCompleted();

  if (!mounted) return;

  if (onboardingCompleted) {
    context.go('/login');
  } else {
    context.go('/welcome');
  }
}

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------------
          // Background
          // ------------------------------------------------------------
          Image.asset(
            'assets/chiquitania.jpeg',
            fit: BoxFit.cover,
          ),

          // ------------------------------------------------------------
          // Top dark gradient
          // ------------------------------------------------------------
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Color(0xDD001A2B),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------
          // Bottom dark gradient
          // ------------------------------------------------------------
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xEE000A14),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------
          // Main content
          // ------------------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ------------------------------------------------------
                // YAVA Logo + animated glow
                // ------------------------------------------------------
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withValues(
                              alpha: _glowAnimation.value * 0.25,
                            ),
                            blurRadius: 35,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/yava_azul_bg.png',
                    width: 190,
                  ),
                ),

                const SizedBox(height: 24),

                // ------------------------------------------------------
                // Main message
                // ------------------------------------------------------
                const Text(
                  'La Chiquitanía\nconectada en una sola App.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                ),

                const Spacer(flex: 5),

                // ------------------------------------------------------
                // Animated light line
                // ------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 95),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white70,
                              Colors.white,
                              Colors.cyanAccent.withValues(
                                alpha: _glowAnimation.value,
                              ),
                              Colors.white,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ------------------------------------------------------
                // Brand message
                // ------------------------------------------------------
                const Text(
                  'BIENVENIDO A\nNUESTRAS RAÍCES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}