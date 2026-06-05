import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';
import '../model/place_model.dart';
import '../widget/mini_map_widget.dart';
import '../widget/address_search_sheet.dart';

class TripBookingPage extends GetView<TripController> {
  const TripBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Carte plein écran ─────────────────────────────
          Positioned.fill(
            child: Obx(() => MiniMapWidget(
              pickup:  controller.pickup.value,
              dropoff: controller.dropoff.value,
            )),
          ),

          // ── AppBar transparente ───────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _BackButton(isDark: isDark),
                    const SizedBox(width: 12),
                    Text(
                      'Nouvelle course',
                      style: TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.w800,
                        color:      isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom sheet de saisie ────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BookingSheet(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom sheet de saisie
// ─────────────────────────────────────────────────────────────
class _BookingSheet extends GetView<TripController> {
  const _BookingSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg  = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue    : AppColors.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(.12),
            blurRadius: 24,
            offset:     const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38, height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Champ départ
          Obx(() => _AddressField(
            isDark:       isDark,
            hint:         "Point d'enlèvement",
            value:        controller.pickup.value?.name,
            dotColor:     primary,
            onTap:        () => _openSearch(context, isPickup: true),
            onClear:      () => controller.clearPickup(),
          )),

          // Ligne connecteur
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Container(
              width: 1.5,
              height: 18,
              color: border,
            ),
          ),

          // Champ destination
          Obx(() => _AddressField(
            isDark:   isDark,
            hint:     'Destination',
            value:    controller.dropoff.value?.name,
            dotColor: AppColors.success,
            onTap:    () => _openSearch(context, isPickup: false),
            onClear:  () => controller.clearDropoff(),
          )),

          const SizedBox(height: 20),

          // Bouton estimer
          Obx(() => AnimatedOpacity(
            opacity:  controller.canEstimate ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width:  double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: controller.canEstimate
                    ? () => controller.estimateTrip()
                    : null,
                child: const Text(
                  'Estimer le prix',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, {required bool isPickup}) {
    showModalBottomSheet(
      context:       context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressSearchSheet(
        isDark:   isDark,
        isPickup: isPickup,
        onSelect: (place) {
          if (isPickup) {
            controller.selectPickup(place);
          } else {
            controller.selectDropoff(place);
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Champ adresse
// ─────────────────────────────────────────────────────────────
class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.isDark,
    required this.hint,
    required this.dotColor,
    required this.onTap,
    this.value,
    this.onClear,
  });

  final bool         isDark;
  final String       hint;
  final String?      value;
  final Color        dotColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final textC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final hintC = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;
    final filled = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:  52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: filled ? dotColor : dotColor.withOpacity(.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filled ? value! : hint,
                style: TextStyle(
                  fontSize:   14,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                  color:      filled ? textC : hintC,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filled && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size:  18,
                  color: hintC,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bouton retour
// ─────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final fg  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color:        bg,
          shape:        BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(.10),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, color: fg, size: 20),
      ),
    );
  }
}
