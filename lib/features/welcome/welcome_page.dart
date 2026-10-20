import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/yava_ui_tokens.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const routeName = 'welcome';
  static const routePath = '/welcome';

  void _continueAsClient(BuildContext context) {
    // Redirige al onboarding de cliente o directo al registro con rol 'client'
    context.push('/onboarding/customer');
  }

  void _registerAsDriver(BuildContext context) {
    // Redirige al onboarding de conductor o directo al registro con rol 'driver'
    context.push('/onboarding/driver');
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
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Fondo completo 9:16 (Catedral + Cliente + Conductor + Horizonte)
              Image.asset(
                'assets/images/welcome/welcome_bg_full.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF06152D), Color(0xFF030812)],
                    ),
                  ),
                ),
              ),

              // 2. Gradiente sutil para integrar las tarjetas sobre la mitad inferior
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      const Color(0xFF030812).withValues(alpha: 0.70),
                      const Color(0xFF030812).withValues(alpha: 0.88),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.34, 0.48, 0.86, 1.0],
                  ),
                ),
              ),

              // 3. Contenido Principal Superpuesto
              SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(14, topPadding + 10, 14, 14),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // --- CABECERA SUPERIOR: LOGO Y SLOGAN ---
                      const _WelcomeTopHeader(),

                      // Espacio calibrado para dejar libres los rostros del fondo
                      const SizedBox(height: 155),

                      // --- BANNER CENTRAL: BIENVENIDO A YAVÁ ---
                      const _WelcomeCenterBanner(),

                      const SizedBox(height: 14),

                      // --- TARJETAS LADO A LADO: USUARIO (AZUL) Y CONDUCTOR (ROJO) ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _RoleActionCard(
                              isDriver: false,
                              headerAsset: 'assets/images/welcome/welcome_card_user.png',
                              badgeIcon: Icons.person_rounded,
                              accentColor: const Color(0xFF0075FF),
                              borderColor: const Color(0xFF00A6FF),
                              titleLine1: 'Quiero usar',
                              titleLine2: 'YAVÁ',
                              description:
                                  'Viaja, pide delivery\ny accede a más servicios\nde forma fácil y segura.',
                              buttonText: 'Continuar como usuario',
                              onTap: () => _continueAsClient(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _RoleActionCard(
                              isDriver: true,
                              headerAsset: 'assets/images/welcome/welcome_card_driver.png',
                              badgeIcon: Icons.sports_motorsports_rounded,
                              accentColor: const Color(0xFFE50914),
                              borderColor: const Color(0xFFFF3845),
                              titleLine1: 'Quiero trabajar',
                              titleLine2: 'con YAVÁ',
                              description:
                                  'Genera ingresos\ncon tu vehículo y sé parte\nde nuestra comunidad.',
                              buttonText: 'Registrarme como conductor',
                              onTap: () => _registerAsDriver(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // --- PÍLDORA INFORMATIVA / ACCESO A LOGIN ---
                      _SwitchProfilePill(
                        onTap: () => context.push('/login'),
                      ),

                      const SizedBox(height: 18),

                      // --- PIE DE PÁGINA: NACE EN CONCEPCIÓN ---
                      const _WelcomeFooter(),
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

// --- CABECERA SUPERIOR ---
class _WelcomeTopHeader extends StatelessWidget {
  const _WelcomeTopHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: Image.asset(
            'assets/images/yava_home_bg.png',
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
          'L A   C H I Q U I T A N Í A\nC O N E C T A D A',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Movilidad, Delivery\ny más servicios\nen una sola App',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 34,
          height: 3.5,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Color(0xFFE50914), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

// --- TARJETA CENTRAL "BIENVENIDO A YAVÁ" ---
class _WelcomeCenterBanner extends StatelessWidget {
  const _WelcomeCenterBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          decoration: BoxDecoration(
            // Azul profundo y nocturno idéntico al mockup
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF031024).withValues(alpha: 0.94),
                const Color(0xFF01060E).withValues(alpha: 0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF0088FF).withValues(alpha: 0.55),
              width: 1.3,
            ),
            boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 20),
          ),
          child: Column(
            children: [
              const Text(
                'Bienvenido a',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              
              // Logo corporativo completo en sustitución del texto plano
              SizedBox(
                height: 38,
                child: Image.asset(
                  'assets/images/yava_home_bg_empty.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 34,
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

              const SizedBox(height: 6),
              const Text(
                'Tu ciudad, tus rutas, más oportunidades.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TARJETA INTERACTIVA DE ROL (AZUL / ROJA) ---
class _RoleActionCard extends StatelessWidget {
  final bool isDriver;
  final String headerAsset;
  final IconData badgeIcon;
  final Color accentColor;
  final Color borderColor;
  final String titleLine1;
  final String titleLine2;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _RoleActionCard({
    required this.isDriver,
    required this.headerAsset,
    required this.badgeIcon,
    required this.accentColor,
    required this.borderColor,
    required this.titleLine1,
    required this.titleLine2,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDriver
                ? const [Color(0xFF42060B), Color(0xFF1F0306), Color(0xFF0A0508)]
                : const [Color(0xFF052B5C), Color(0xFF031530), Color(0xFF020B18)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.75),
            width: 1.5,
          ),
          boxShadow: YavaUiTokens.neonGlow(accentColor, blur: 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           // Cabecera con imagen y medallón circular superpuesto (Reducida a height: 102)
            SizedBox(
              height: 102,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                 Positioned.fill(
                    bottom: 16,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: Transform.translate(
                        // Valor negativo en Y sube la imagen (ajusta entre -14 y -24 según prefieras)
                        offset: const Offset(0, -9),
                        child: Transform.scale(
                          scale: 1.2, // Un ligero extra de escala evita que quede hueco abajo al subirla
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            headerAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Container(
                              color: accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Medallón circular central con brillo neón
                  Positioned(
                    bottom: -2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.8),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          badgeIcon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cuerpo de texto y botón
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleLine1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              titleLine2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white60,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón inferior con borde luminoso
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDriver
                            ? const [Color(0xFFE50914), Color(0xFFB8000A)]
                            : const [Color(0xFF0088FF), Color(0xFF0051CC)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            buttonText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PÍLDORA INFERIOR "PODRÁS HABILITAR OTROS PERFILES MÁS ADELANTE" ---
class _SwitchProfilePill extends StatelessWidget {
  final VoidCallback onTap;

  const _SwitchProfilePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF071222).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.person_rounded, color: Color(0xFF4CA6FF), size: 18),
            SizedBox(width: 3),
            Icon(Icons.swap_horiz_rounded, color: Colors.white54, size: 14),
            SizedBox(width: 3),
            Icon(Icons.directions_car_rounded, color: Colors.white70, size: 16),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Podrás habilitar otros perfiles más adelante',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}

// --- PIE DE PÁGINA ---
class _WelcomeFooter extends StatelessWidget {
  const _WelcomeFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'N A C E   E N   C O N C E P C I Ó N',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'P A R A   T O D A   L A   C H I Q U I T A N Í A',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}