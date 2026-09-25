import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverTrackingPage extends StatelessWidget {
  const DriverTrackingPage({super.key});

  static const routePath = '/driver/tracking';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/driver/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/home');
              }
            },
          ),
          title: const Text(
            'Seguimiento',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.mist,
                child: CustomPaint(painter: _MapDemoPainter()),
              ),
            ),

            Positioned(top: 18, left: 18, right: 18, child: _StatusCard()),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: _TrackingBottomCard(
                onOpenTrip: () {
                  context.go('/driver/trips');
                },
              ),
            ),

            Positioned(
              right: 18,
              top: 110,
              child: FloatingActionButton.small(
                heroTag: 'driver_location',
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.navy,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La ubicación se sincronizará con el viaje activo.',
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.my_location_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.mist,
            child: Icon(Icons.navigation_rounded, color: AppColors.navy),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Viaje en curso',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Ubicación compartida en tiempo real',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.circle, color: AppColors.success, size: 11),
        ],
      ),
    );
  }
}

class _TrackingBottomCard extends StatelessWidget {
  const _TrackingBottomCard({required this.onOpenTrip});

  final VoidCallback onOpenTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taxi · Servicio activo',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Cliente: María R.',
                      style: TextStyle(
                        color: AppColors.mutedInk,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Bs 28',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _RouteLine(
            title: 'Plaza Principal',
            subtitle: 'Origen',
            icon: Icons.radio_button_checked_rounded,
            color: AppColors.navyLight,
          ),
          _RouteLine(
            title: 'Barrio San Antonio',
            subtitle: 'Destino',
            icon: Icons.location_on_rounded,
            color: AppColors.clay,
            showLine: false,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onOpenTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.route_rounded),
              label: const Text(
                'Ver viaje',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.showLine = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Icon(icon, color: color, size: 15),
                if (showLine)
                  Expanded(child: Container(width: 1, color: AppColors.mist)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final roadPaintSmall = Paint()
      ..color = AppColors.white.withOpacity(0.75)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = AppColors.navyLight
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.50,
        size.width * 0.52,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.63,
        size.width * 0.82,
        size.height * 0.30,
      );

    canvas.drawLine(
      Offset(0, size.height * 0.28),
      Offset(size.width, size.height * 0.72),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.82),
      Offset(size.width * 0.92, size.height * 0.18),
      roadPaintSmall,
    );

    canvas.drawPath(routePath, routePaint);

    _drawMarker(
      canvas,
      Offset(size.width * 0.18, size.height * 0.72),
      AppColors.navyLight,
    );

    _drawMarker(
      canvas,
      Offset(size.width * 0.82, size.height * 0.30),
      AppColors.clay,
    );

    _drawDriverMarker(canvas, Offset(size.width * 0.53, size.height * 0.56));
  }

  void _drawMarker(Canvas canvas, Offset position, Color color) {
    final paint = Paint()..color = color;

    canvas.drawCircle(position, 9, paint);

    final inner = Paint()..color = AppColors.white;

    canvas.drawCircle(position, 4, inner);
  }

  void _drawDriverMarker(Canvas canvas, Offset position) {
    final shadow = Paint()..color = AppColors.navy.withOpacity(0.16);

    canvas.drawCircle(position, 19, shadow);

    final paint = Paint()..color = AppColors.navy;

    canvas.drawCircle(position, 14, paint);

    final iconPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 5, iconPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
