import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';
import '../widget/mini_map_widget.dart';

class TripTrackingPage extends GetView<TripController> {
  const TripTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Carte ─────────────────────────────────────────
          Positioned.fill(
            child: Obx(() => MiniMapWidget(
              pickup:     controller.pickup.value,
              dropoff:    controller.dropoff.value,
              showDriver: true,
            )),
          ),

          // ── Bouton SOS ────────────────────────────────────
          Positioned(
            top:   60,
            right: 16,
            child: SafeArea(child: _SosButton()),
          ),

          // ── Fiche coursier ────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _DriverSheet(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton SOS ───────────────────────────────────────────────
class _SosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.dialog(
        AlertDialog(
          title: const Text('Urgence SOS'),
          content: const Text(
              'Votre position sera partagée avec nos équipes de sécurité.'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: Get.back,
              child: const Text('Confirmer SOS'),
            ),
          ],
        ),
      ),
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color:     AppColors.error,
          shape:     BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:      AppColors.error.withOpacity(.40),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'SOS',
            style: TextStyle(
              color:      Colors.white,
              fontSize:   13,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fiche coursier ───────────────────────────────────────────
class _DriverSheet extends GetView<TripController> {
  const _DriverSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;
    final primary = isDark ? AppColors.primaryBlue    : AppColors.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border:       Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(.12),
            blurRadius: 20,
            offset:     const Offset(0, -6),
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
              color:        border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Label "Coursier en route"
          Row(
            children: [
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Coursier en route',
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Infos coursier
          Row(
            children: [
              // Avatar
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color:  primary.withOpacity(.12),
                  shape:  BoxShape.circle,
                  border: Border.all(color: primary.withOpacity(.25)),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: primary,
                  size:  26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jean-Baptiste M.',
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w700,
                        color:      titleC,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Moto Honda CB125 • LBV-4821-A',
                      style: TextStyle(fontSize: 12.5, color: subC),
                    ),
                  ],
                ),
              ),
              // Note
              Column(
                children: [
                  Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w700,
                      color:      titleC,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: border, height: 1),
          const SizedBox(height: 16),

          // Prix
          Obx(() {
            final trip = controller.currentTrip.value;
            if (trip == null) return const SizedBox.shrink();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trip.pickup.name} → ${trip.dropoff.name}',
                  style: TextStyle(
                    fontSize:   13,
                    color:      subC,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  trip.formattedPrice,
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w800,
                    color:      primary,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 18),

          // Bouton terminer
          SizedBox(
            width:  double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: controller.completeTrip,
              child: const Text(
                'Course terminée',
                style: TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}