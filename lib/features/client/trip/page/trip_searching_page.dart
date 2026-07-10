import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';

class TripSearchingPage extends GetView<TripController> {
  const TripSearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.cancelTrip,
                  child: Text(
                    'cancel'.tr,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Animation pulsation
              _PulseAnimation(color: primary),
              const SizedBox(height: 40),

              Text(
                'searching_driver'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'finding_best_driver'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDark ? AppColors.textDarkSub : AppColors.textLightSub,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Infos course
              Obx(() {
                final trip = controller.currentTrip.value;
                if (trip == null) return const SizedBox.shrink();
                return _TripSummaryRow(trip: trip, isDark: isDark);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animation cercles pulsants ──────────────────────────────
class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation({required this.color});
  final Color color;

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: false);

    _scale = Tween(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: .15),
              shape: BoxShape.circle,
              border: Border.all(color: widget.color, width: 2),
            ),
            child: Icon(
              Icons.sports_motorsports_rounded,
              color: widget.color,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Résumé course ─────────────────────────────────────────
class _TripSummaryRow extends StatelessWidget {
  const _TripSummaryRow({required this.trip, required this.isDark});
  final dynamic trip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textC =
        isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.pickup.name} → ${trip.dropoff.name}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textC,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${trip.formattedDistance} • ${trip.formattedDuration}',
                  style: TextStyle(fontSize: 12, color: subC),
                ),
              ],
            ),
          ),
          Text(
            trip.formattedPrice,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color:
                  isDark ? AppColors.primaryBlueLight : AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
