import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../client/trip/widget/mini_map_widget.dart';
import '../../trip_mgt/controller/driver_trip_controller.dart';
import '../../trip_mgt/model/driver_trip_request.dart';
import '../../trip_mgt/widget/new_request_overlay.dart';
import '../controller/driver_dashboard_controller.dart';

class DriverDashboardPage extends GetView<DriverDashboardController> {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tripController = Get.find<DriverTripController>();

    return Stack(
      children: [
        // 1. Fond Immersif (Carte plein écran - SANS SAFE AREA pour aller sous la status bar)
        Positioned.fill(
          child: Obx(() {
            final currentTrip = tripController.currentTrip.value;
            return MiniMapWidget(
              pickup: currentTrip?.pickup ?? controller.currentLocation.value,
              dropoff: currentTrip?.dropoff,
              driverLocation: controller.currentLocation.value,
              showDriver: true,
              showHeatmap: controller.isOnline.value,
            );
          }),
        ),

        // 2. Header Flottant (Profil + Gains rapides)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: const _TopFloatingHeader(),
        ),

        // 3. Bouton "GO" Central Bas
        Positioned(
          bottom: 220,
          left: 0,
          right: 0,
          child: Center(child: _GoButton(controller: controller)),
        ),

        // 4. Panel d'état et stats flottant
        Positioned(
          bottom: 120,
          left: 16,
          right: 16,
          child: _DriverFloatingStatus(
            dashboardController: controller,
            tripController: tripController,
          ),
        ),

        // 5. Overlay des nouvelles requêtes (Géré dans la stack pour éviter le blocage)
        Positioned.fill(
          child: const NewRequestOverlay(),
        ),
      ],
    );
  }
}

class _TopFloatingHeader extends StatelessWidget {
  const _TopFloatingHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9);

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent(context).withValues(alpha: 0.1),
                child: FaIcon(FontAwesomeIcons.user, size: 14, color: AppColors.accent(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text(
                      Get.find<DriverDashboardController>().isOnline.value ? 'En ligne' : 'Hors ligne',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Get.find<DriverDashboardController>().isOnline.value ? AppColors.success : Colors.grey,
                      ),
                    )),
                    Text(
                      AppStorage.user?['name'] ?? 'Chauffeur',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() {
                  final ctrl = Get.find<DriverDashboardController>();
                  return Text(
                    '${ctrl.todayRevenue.value.toStringAsFixed(0)} F',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoButton extends StatelessWidget {
  const _GoButton({required this.controller});
  final DriverDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOnline = controller.isOnline.value;
      return GestureDetector(
        onTap: () => controller.toggleOnline(!isOnline),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? AppColors.error : AppColors.success,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: (isOnline ? AppColors.error : AppColors.success).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              isOnline ? 'OFF' : 'GO',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _DriverFloatingStatus extends StatelessWidget {
  const _DriverFloatingStatus({
    required this.dashboardController,
    required this.tripController,
  });

  final DriverDashboardController dashboardController;
  final DriverTripController tripController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final trip = tripController.currentTrip.value;

      if (trip != null) {
        return _ActiveTripOverlay(controller: tripController);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.slate900.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'TEMPS',
                  value: dashboardController.formattedOnlineDuration,
                  icon: FontAwesomeIcons.clock,
                ),
                _StatItem(
                  label: 'COURSES',
                  value: '${dashboardController.completedTrips.value}',
                  icon: FontAwesomeIcons.route,
                ),
                _StatItem(
                  label: 'NOTE',
                  value: '4.9',
                  icon: FontAwesomeIcons.star,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 14, color: color ?? AppColors.textSub(context)),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textSub(context),
          ),
        ),
      ],
    );
  }
}

class _ActiveTripOverlay extends StatelessWidget {
  const _ActiveTripOverlay({required this.controller});
  final DriverTripController controller;

  @override
  Widget build(BuildContext context) {
    final trip = controller.currentTrip.value!;
    
    final title = switch (controller.stage.value) {
      DriverTripStage.goingToPickup => 'Vers le client',
      DriverTripStage.arrivedAtPickup => 'Client récupéré ?',
      DriverTripStage.inProgress => 'En route...',
      _ => 'Course en cours',
    };

    final buttonLabel = switch (controller.stage.value) {
      DriverTripStage.goingToPickup => 'JE SUIS ARRIVÉ',
      DriverTripStage.arrivedAtPickup => 'DÉMARRER LA COURSE',
      DriverTripStage.inProgress => 'TERMINER LA COURSE',
      _ => 'CONTINUER',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent(context).withValues(alpha: 0.1),
                child: const FaIcon(FontAwesomeIcons.user, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent(context))),
                    Text(trip.passengerName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white, size: 20)),
              )
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip.dropoff.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (controller.stage.value == DriverTripStage.goingToPickup) controller.markArrivedAtPickup();
                else if (controller.stage.value == DriverTripStage.arrivedAtPickup) controller.startTrip();
                else if (controller.stage.value == DriverTripStage.inProgress) controller.completeTrip();
              },
              child: Text(buttonLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}
