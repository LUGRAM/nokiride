import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../client/trip/widget/mini_map_widget.dart';
import '../../trip_mgt/controller/driver_trip_controller.dart';
import '../../trip_mgt/model/driver_trip_request.dart';
import '../../trip_mgt/widget/new_request_overlay.dart';
import '../controller/driver_dashboard_controller.dart';

class DriverDashboardPage extends GetView<DriverDashboardController> {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Espace chauffeur',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.notifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      drawer: const _DriverDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(
                  () {
                    final tripController = Get.find<DriverTripController>();
                    final currentTrip = tripController.currentTrip.value;
                    return MiniMapWidget(
                      pickup: currentTrip?.pickup ??
                          controller.currentLocation.value,
                      dropoff: currentTrip?.dropoff,
                      driverLocation: controller.currentLocation.value,
                      showDriver: controller.isOnline.value,
                    );
                  },
                ),
              ),
              _DriverTripPanel(
                dashboardController: controller,
                tripController: Get.find<DriverTripController>(),
              ),
            ],
          ),
          const NewRequestOverlay(),
        ],
      ),
    );
  }
}

class _DriverDrawer extends StatelessWidget {
  const _DriverDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background(context),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.accent(context)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            accountName: Text(
              AppStorage.user?['name'] ?? 'Chauffeur',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
            accountEmail: Text(AppStorage.user?['phone'] ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mon Profil'),
            onTap: () => Get.toNamed(Routes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Mon Véhicule'),
            onTap: () => Get.toNamed(Routes.driverVehicleRegistration),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique des courses'),
            onTap: () => Get.toNamed(Routes.driverEarnings),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Portefeuille'),
            onTap: () => Get.toNamed(Routes.wallet),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Passer en mode Client'),
            onTap: () {
              Get.back(); // Ferme le drawer
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().switchRole();
              } else {
                AppStorage.saveLastActiveRole('client');
                Get.offAllNamed(Routes.clientHome);
              }
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              // On s'assure que AuthController est là pour déconnecter
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().logout();
              } else {
                AppStorage.clearAuth();
                Get.offAllNamed(Routes.login);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DriverTripPanel extends StatelessWidget {
  const _DriverTripPanel({
    required this.dashboardController,
    required this.tripController,
  });

  final DriverDashboardController dashboardController;
  final DriverTripController tripController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tripController.currentTrip.value != null) ...[
              _ActiveTripCard(controller: tripController),
              const SizedBox(height: 18),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dashboardController.isOnline.value
                            ? 'Vous êtes en ligne'
                            : 'Vous êtes hors ligne',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dashboardController.hasVehicle
                            ? 'Prêt à recevoir des courses'
                            : 'Véhicule requis avant activation',
                        style: GoogleFonts.inter(
                          color: AppColors.textSub(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: dashboardController.isOnline.value,
                  activeThumbColor: AppColors.accent(context),
                  onChanged: dashboardController.toggleOnline,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _StatTile(
                  label: 'Gains',
                  value:
                      '${dashboardController.todayRevenue.value.toStringAsFixed(0)} FCFA',
                ),
                const SizedBox(width: 10),
                _StatTile(
                  label: 'Temps',
                  value: dashboardController.formattedOnlineDuration,
                ),
                const SizedBox(width: 10),
                _StatTile(
                  label: 'Courses',
                  value: '${dashboardController.completedTrips.value}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _WeeklyRevenue(controller: tripController),
          ],
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({required this.controller});

  final DriverTripController controller;

  @override
  Widget build(BuildContext context) {
    final trip = controller.currentTrip.value;
    if (trip == null) return const SizedBox.shrink();

    final title = switch (controller.stage.value) {
      DriverTripStage.goingToPickup => 'Aller chercher ${trip.passengerName}',
      DriverTripStage.arrivedAtPickup => 'Client récupéré ?',
      DriverTripStage.inProgress => 'Navigation vers la destination',
      _ => 'Course active',
    };
    final buttonLabel = switch (controller.stage.value) {
      DriverTripStage.goingToPickup => 'Je suis arrivé',
      DriverTripStage.arrivedAtPickup => 'Démarrer la course',
      DriverTripStage.inProgress => 'Arrivé à destination',
      _ => 'Continuer',
    };
    final action = switch (controller.stage.value) {
      DriverTripStage.goingToPickup => controller.markArrivedAtPickup,
      DriverTripStage.arrivedAtPickup => controller.startTrip,
      DriverTripStage.inProgress => controller.completeTrip,
      _ => () {},
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${trip.pickup.address} → ${trip.dropoff.address}',
            style: GoogleFonts.inter(
              color: AppColors.textSub(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: action,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRevenue extends StatelessWidget {
  const _WeeklyRevenue({required this.controller});

  final DriverTripController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Cette semaine : ${controller.weeklyRevenue.value} FCFA nets',
        style: GoogleFonts.inter(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textSub(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
