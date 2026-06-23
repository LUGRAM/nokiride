import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      painter: _MapPainter(
        isDark: isDark,
        bgColor: AppColors.background(context),
        routeColor: AppColors.accent(context).withOpacity(0.5),
      ),
      child: Stack(
        children: [
          // Marqueur départ
          if (widget.pickup != null)
            Positioned(
              left:   80,
              top:    160,
              child: _MapPin(color: AppColors.accent(context),
                             icon:  FontAwesomeIcons.circleDot),
            ),

          // Marqueur arrivée
          if (widget.dropoff != null)
            Positioned(
              right: 90,
              top:   280,
              child: _MapPin(color: AppColors.accent(context),
                             icon:  FontAwesomeIcons.locationDot),
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
                  child: _MapPin(
                    color: AppColors.accent(context),
                    icon:  FontAwesomeIcons.motorcycle,
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
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Painter carte stylisée ───────────────────────────────────
class _MapPainter extends CustomPainter {
  const _MapPainter({required this.isDark, required this.bgColor, required this.routeColor});
  final bool isDark;
  final Color bgColor;
  final Color routeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridColor = isDark
        ? Colors.white.withOpacity(.02)
        : Colors.black.withOpacity(.03);
    final roadColor = isDark
        ? Colors.white.withOpacity(.04)
        : Colors.black.withOpacity(.05);

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
            ? Colors.white.withOpacity(.02)
            : Colors.black.withOpacity(.03),
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
        color:  color.withOpacity(.25),
        shape:  BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color:      color.withOpacity(.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(child: FaIcon(icon, color: color, size: size * .45)),
    );
  }
}

// ─── Badge lieu ───────────────────────────────────────────────
class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final bg    = AppColors.surface(context);
    final textC = AppColors.textPrimary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.locationDot,
               color: AppColors.accent(context), size: 10),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w800,
              color:      textC,
            ),
          ),
        ],
      ),
    );
  }
}
