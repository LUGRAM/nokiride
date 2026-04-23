import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../model/place_model.dart';

class MiniMapWidget extends StatefulWidget {
  const MiniMapWidget({
    super.key,
    this.pickup,
    this.dropoff,
    this.showDriver = false,
  });

  final PlaceModel? pickup;
  final PlaceModel? dropoff;
  final bool        showDriver;

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _driverCtrl;
  late final Animation<double>   _driverAnim;

  @override
  void initState() {
    super.initState();
    _driverCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _driverAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _driverCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _driverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      painter: _MapPainter(isDark: isDark),
      child: Stack(
        children: [
          // Marqueur départ
          if (widget.pickup != null)
            const Positioned(
              left:   80,
              top:    160,
              child: _MapPin(color: AppColors.primaryBlue,
                             icon:  Icons.radio_button_checked_rounded),
            ),

          // Marqueur arrivée
          if (widget.dropoff != null)
            const Positioned(
              right: 90,
              top:   280,
              child: _MapPin(color: AppColors.success,
                             icon:  Icons.location_on_rounded),
            ),

          // Marqueur coursier animé
          if (widget.showDriver)
            AnimatedBuilder(
              animation: _driverAnim,
              builder: (_, __) {
                final t = _driverAnim.value;
                final left = 80 + (200 * t);
                final top  = 160 + (120 * t);
                return Positioned(
                  left: left,
                  top:  top,
                  child: const _MapPin(
                    color: AppColors.warning,
                    icon:  Icons.sports_motorsports_rounded,
                    size:  38,
                  ),
                );
              },
            ),

          // Badge lieu départ
          if (widget.pickup != null)
            Positioned(
              top:  16,
              left: 16,
              child: _LocationBadge(
                label:  widget.pickup!.name,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Painter carte stylisée ───────────────────────────────────
class _MapPainter extends CustomPainter {
  const _MapPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor   = isDark ? const Color(0xFF0A1628) : const Color(0xFFE8EDF2);
    final gridColor = isDark
        ? Colors.white.withOpacity(.04)
        : Colors.black.withOpacity(.05);
    final roadColor = isDark
        ? Colors.white.withOpacity(.08)
        : Colors.black.withOpacity(.07);
    final routeColor = isDark
        ? AppColors.primaryBlue.withOpacity(.55)
        : AppColors.primaryBlue.withOpacity(.45);

    // Fond
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    // Grille
    final gPaint = Paint()..color = gridColor ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gPaint);
    }
    for (double y = 0; y <= size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gPaint);
    }

    // Routes horizontales
    final rPaint = Paint()..color = roadColor ..strokeWidth = 6 ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * .35), Offset(size.width, size.height * .35), rPaint);
    canvas.drawLine(Offset(0, size.height * .60), Offset(size.width, size.height * .60), rPaint);
    canvas.drawLine(Offset(0, size.height * .80), Offset(size.width, size.height * .80), rPaint);

    // Routes verticales
    canvas.drawLine(Offset(size.width * .28, 0), Offset(size.width * .28, size.height), rPaint);
    canvas.drawLine(Offset(size.width * .62, 0), Offset(size.width * .62, size.height), rPaint);

    // Tracé de route A→B
    final path = Path()
      ..moveTo(size.width * .22, size.height * .42)
      ..quadraticBezierTo(
          size.width * .40, size.height * .28,
          size.width * .62, size.height * .45)
      ..quadraticBezierTo(
          size.width * .78, size.height * .60,
          size.width * .85, size.height * .72);

    canvas.drawPath(
      path,
      Paint()
        ..color       = routeColor
        ..strokeWidth = 4
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );

    // Halo lumineux sur la route
    canvas.drawPath(
      path,
      Paint()
        ..color       = routeColor.withOpacity(.18)
        ..strokeWidth = 12
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );

    // Blocs de bâtiments
    _drawBlock(canvas, size, .05, .05, .18, .28, isDark);
    _drawBlock(canvas, size, .32, .05, .58, .28, isDark);
    _drawBlock(canvas, size, .66, .05, .90, .28, isDark);
    _drawBlock(canvas, size, .05, .65, .24, .88, isDark);
    _drawBlock(canvas, size, .66, .48, .90, .55, isDark);
  }

  void _drawBlock(Canvas canvas, Size s,
      double x1, double y1, double x2, double y2, bool dark) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        s.width * x1, s.height * y1,
        s.width * x2, s.height * y2,
        const Radius.circular(4),
      ),
      Paint()
        ..color = dark
            ? Colors.white.withOpacity(.04)
            : Colors.black.withOpacity(.05),
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.isDark != isDark;
}

// ─── Pin de localisation ──────────────────────────────────────
class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.icon,
    this.size = 32,
  });
  final Color    color;
  final IconData icon;
  final double   size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        color:  color.withOpacity(.18),
        shape:  BoxShape.circle,
        border: Border.all(color: color.withOpacity(.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      color.withOpacity(.25),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * .5),
    );
  }
}

// ─── Badge lieu ───────────────────────────────────────────────
class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.label, required this.isDark});
  final String label;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final textC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_rounded,
               color: AppColors.primaryBlue, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      textC,
            ),
          ),
        ],
      ),
    );
  }
}
