import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';

class TripEstimatePage extends GetView<TripController> {
  const TripEstimatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.bgDark : AppColors.bgLight;
    final trip    = controller.currentTrip.value;

    if (trip == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _PriceCard(trip: trip, isDark: isDark),
                    const SizedBox(height: 16),
                    _RouteCard(trip: trip, isDark: isDark),
                    const SizedBox(height: 16),
                    _TarifInfoCard(isDark: isDark),
                  ],
                ),
              ),
            ),
            _BottomActions(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(
              Icons.arrow_back_rounded,
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'trip_estimate_title'.tr,
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prix principal ───────────────────────────────────────────
class _PriceCard extends GetView<TripController> {
  const _PriceCard({required this.trip, required this.isDark});
  final dynamic trip;
  final bool    isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg  = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue    : AppColors.primaryGreen;
    final titleC  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC    = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: border, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.sports_motorsports_rounded, color: primary, size: 40),
          const SizedBox(height: 14),
          Text(
            'moto_taxi_standard'.tr,
            style: TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w600,
              color:      subC,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trip.formattedPrice,
            style: TextStyle(
              fontSize:   36,
              fontWeight: FontWeight.w800,
              color:      primary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon:   Icons.route_rounded,
                label:  trip.formattedDistance,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon:   Icons.timer_outlined,
                label:  trip.formattedDuration,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });
  final IconData icon;
  final String   label;
  final bool     isDark;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final color = isDark ? AppColors.textDarkSub    : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trajet A→B ───────────────────────────────────────────────
class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.trip, required this.isDark});
  final dynamic trip;
  final bool    isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark     : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: border, width: 1),
      ),
      child: Column(
        children: [
          _RouteRow(
            icon:      Icons.radio_button_checked_rounded,
            iconColor: AppColors.primaryBlue,
            label:     trip.pickup.name,
            sub:       trip.pickup.address,
            isDark:    isDark,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              width: 1.5,
              height: 20,
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
          ),
          _RouteRow(
            icon:      Icons.location_on_rounded,
            iconColor: AppColors.success,
            label:     trip.dropoff.name,
            sub:       trip.dropoff.address,
            isDark:    isDark,
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.isDark,
  });
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   sub;
  final bool     isDark;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: TextStyle(
                  fontSize:   14,
                  fontWeight: FontWeight.w700,
                  color:      titleC,
                ),
              ),
              Text(sub,
                style: TextStyle(
                  fontSize:   11.5,
                  color:      subC,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info tarif ───────────────────────────────────────────────
class _TarifInfoCard extends StatelessWidget {
  const _TarifInfoCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.infoFill : AppColors.accentBlueFill;
    final color = isDark ? AppColors.primaryBlueLight : AppColors.accentBlueLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'trip_pricing_info'.tr,
              style: TextStyle(
                fontSize:   12,
                color:      color,
                fontWeight: FontWeight.w500,
                height:     1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Actions bas de page ──────────────────────────────────────
class _BottomActions extends GetView<TripController> {
  const _BottomActions({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue    : AppColors.primaryGreen;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      decoration: BoxDecoration(
        color:  bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width:  double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: controller.confirmTrip,
              child: Text(
                'confirm_trip'.tr,
                style: const TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width:  double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? AppColors.textDarkSub
                    : AppColors.textLightSub,
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: Get.back,
              child: Text(
                'edit'.tr,
                style: const TextStyle(
                  fontSize:   14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
