import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/core/services/onboarding_service.dart';

class AuthEntryPage extends ConsumerStatefulWidget {
  const AuthEntryPage({super.key});

  static const routeName = 'auth-entry';
  static const routePath = '/auth-entry';

  @override
  ConsumerState<AuthEntryPage> createState() => _AuthEntryPageState();
}

class _AuthEntryPageState extends ConsumerState<AuthEntryPage> {
  bool _hasExistingAccount = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    try {
      // Verificamos si el usuario ya vio el onboarding o creó una cuenta antes
      final completed = await ref.read(onboardingServiceProvider).hasCompleted();
      if (mounted) {
        setState(() {
          _hasExistingAccount = completed;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasExistingAccount = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Textos dinámicos según si ya tiene cuenta o es totalmente nuevo

    final String subtitleText = _hasExistingAccount
        ? 'Inicia sesión en tu cuenta\ny sigue disfrutando de YAVÁ'
        : 'Inicia sesión si ya tienes cuenta\no comienza un viaje nuevo.';
        // Textos dinámicos según si ya tiene cuenta o es totalmente nuevo
final String topSubHeader = _hasExistingAccount
    ? 'B I E N V E N I D O   D E   N U E V O'
    : 'B I E N V E N I D O   A   Y A V Á';

final String mainTitleLine1 = _hasExistingAccount ? 'Continúa' : 'Tu destino,';
final String mainTitleLine2 = _hasExistingAccount ? 'tu viaje' : 'más cerca.';

// Aquí definimos el color dinámico: rojo para "tu viaje" o "más cerca", blanco para lo demás
final Color mainTitleLine2Color = _hasExistingAccount
    ? const Color(0xFFFF122E) // Rojo para "tu viaje"
    : const Color(0xFFFF122E); // Rojo también para "más cerca." (o blanco si prefieres)

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030812),
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Imagen completa de fondo
              Image.asset(
                'assets/images/auth_entry_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/login/auth_entry_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF06152D),
                  ),
                ),
              ),

              // 2. Sombreado inferior para resaltar textos y botones
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.62),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                    stops: const [0.0, 0.45, 0.70, 1.0],
                  ),
                ),
              ),

              // 3. Contenido Interactivo en la mitad inferior
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 34),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título superior del bloque (Dinámico)
                      Text(
                        topSubHeader,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Línea 1 del Título principal
                      // Línea 1 del Título principal
Text(
  mainTitleLine1,
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: -0.8,
    shadows: [
      Shadow(
        color: Colors.black87,
        blurRadius: 12,
        offset: Offset(0, 3),
      ),
    ],
  ),
),
// Línea 2 del Título principal (Dinámica y en color rojo)
Text(
  mainTitleLine2,
  textAlign: TextAlign.center,
  style: TextStyle(
    color: mainTitleLine2Color, // Aplicará el color rojo dinámicamente
    fontSize: 40,
    fontWeight: FontWeight.w900,
    height: 1.05,
    letterSpacing: -0.8,
    shadows: const [
      Shadow(
        color: Colors.black87,
        blurRadius: 12,
        offset: Offset(0, 3),
      ),
    ],
  ),
),
                      const SizedBox(height: 12),

                      // Subtítulo dinámico
                      Text(
                        subtitleText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      // --- BOTÓN 1: INICIAR SESIÓN ---
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => context.push('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF122E),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0xFFFF122E).withValues(alpha: 0.55),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.person_outline_rounded, color: Colors.white, size: 23),
                              Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 25),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // --- BOTÓN 2: COMENZAR ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.80),
                                width: 1.3,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => context.push('/welcome'),
                              borderRadius: BorderRadius.circular(30),
                              child: const SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 22),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.add_rounded, color: Colors.white, size: 26),
                                      Text(
                                        'Comenzar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}