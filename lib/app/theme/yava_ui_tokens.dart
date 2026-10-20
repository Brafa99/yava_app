import 'package:flutter/material.dart';

class YavaUiTokens {
  // --- FONDOS PRINCIPALES ---
  static const Color background = Color(0xFF030811);
  static const Color surfaceCard = Color(0xFF071220);
  static const Color surfaceCardDark = Color(0xFF040A14);
  static const Color surfaceElevated = Color(0xFF09182B);

  // --- TONOS MOVILIDAD (AZULES / CIAN) ---
  static const Color mobilityBlue = Color(0xFF0075FF);
  static const Color mobilityDeepBlue = Color(0xFF003882);
  static const Color mobilityDarkBlue = Color(0xFF041E42);
  static const Color mobilityBottomBlue = Color(0xFF021024);
  static const Color mobilityCyan = Color(0xFF00D2FF);
  static const Color mobilityLightCyan = Color(0xFF80E5FF);

  // --- TONOS DELIVERY (ROJOS / CORAL) ---
  static const Color deliveryRed = Color(0xFFE50914);
  static const Color deliveryDeepRed = Color(0xFF8B0008);
  static const Color deliveryDarkRed = Color(0xFF4A0005);
  static const Color deliveryBottomRed = Color(0xFF220002);
  static const Color deliveryCoral = Color(0xFFFF3B30);

  // --- ESTADOS Y CONTROL (CONDUCTOR) ---
  static const Color onlineGreen = Color(0xFF00E676);
  static const Color onlineGreenDark = Color(0xFF003822);
  static const Color offlineGrey = Color(0xFF1E2430);
  static const Color warningAmber = Color(0xFFFFB300);
  static const Color warningAmberDark = Color(0xFF382500);

  // --- BORDES Y SEPARADORES ---
  static const Color borderBlue = Color(0xFF0088FF);
  static const Color borderRed = Color(0xFFFF2E3A);
  static const Color borderSubtle = Color(0x26FFFFFF); // White 15%

  // --- GRADIENTES OFICIALES ---
  static const LinearGradient mobilityCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF044899),
      Color(0xFF041E42),
      Color(0xFF021024),
    ],
  );

  static const LinearGradient deliveryCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8B0008),
      Color(0xFF4A0005),
      Color(0xFF220002),
    ],
  );

  static const LinearGradient incomingRideGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF081C38),
      Color(0xFF030D1C),
    ],
  );

  // --- SOMBRAS Y RESPLANDORES NEÓN (GLOW) ---
  static List<BoxShadow> neonGlow(Color color, {double spread = 0, double blur = 16}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: blur,
        spreadRadius: spread,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> softGlow(Color color, {double blur = 10}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: blur,
        offset: const Offset(0, 2),
      ),
    ];
  }
}