import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/trip_controller.dart';
import '../widget/mini_map_widget.dart';

class TripPage extends GetView<TripController> {
  const TripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fond Carte Stylisée
          Obx(() => MiniMapWidget(
            pickup: controller.pickup.value,
            dropoff: controller.dropoff.value,
            showDriver: controller.currentStep.value == TripStep.tracking,
          )),

          // 2. Bouton Retour Flottant
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: _CircleBackButton(onTap: controller.prevStep),
          ),

          // 3. UI Dynamique (Bottom Sheets)
          Obx(() {
            switch (controller.currentStep.value) {
              case TripStep.destination:
                return const _DestinationSheet();
              case TripStep.selecting:
                return const _ServiceSelectionSheet();
              case TripStep.matching:
                return const _MatchingOverlay();
              case TripStep.tracking:
                return const _TrackingSheet();
            }
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPOSANTS ÉCRAN 1 : SAISIE DESTINATION
// ─────────────────────────────────────────────────────────────
class _DestinationSheet extends StatelessWidget {
  const _DestinationSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchInput(
              context,
              icon: FontAwesomeIcons.circleDot,
              color: AppColors.accent(context),
              hint: "Position actuelle",
              value: controller.pickup.value?.name ?? "Chargement...",
            ),
            const SizedBox(height: 12),
            _buildSearchInput(
              context,
              icon: FontAwesomeIcons.locationDot,
              color: AppColors.accent(context),
              hint: "Où allez-vous ?",
              autofocus: true,
              onChanged: controller.searchPlace,
            ),
            const SizedBox(height: 20),
            
            // Résultats de recherche
            Obx(() {
              if (controller.searchResults.isEmpty) {
                return _buildRecentPlaces(context);
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final place = controller.searchResults[index];
                    return ListTile(
                      leading: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 14, color: AppColors.textSub(context)),
                      title: Text(place.name, style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
                      subtitle: Text(place.address, style: TextStyle(fontSize: 12, color: AppColors.textSub(context))),
                      onTap: () => controller.selectDropoff(place),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(
    BuildContext context, {
    required dynamic icon,
    required Color color,
    required String hint,
    String? value,
    bool autofocus = false,
    Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 1.5),
      ),
      child: Row(
        children: [
          FaIcon(icon, color: color, size: 16),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              autofocus: autofocus,
              onChanged: onChanged,
              controller: value != null ? TextEditingController(text: value) : null,
              readOnly: value != null,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.textSub(context), fontWeight: FontWeight.w500),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPlaces(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RÉCENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSub(context), letterSpacing: 1.0)),
        const SizedBox(height: 12),
        const _RecentPlaceItem(icon: FontAwesomeIcons.house, title: "Maison", address: "Akanda, Cité de la Caisse"),
        const _RecentPlaceItem(icon: FontAwesomeIcons.briefcase, title: "Travail", address: "Centre-ville, Immeuble inter-bancaire"),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPOSANTS ÉCRAN 2 : SÉLECTION SERVICE
// ─────────────────────────────────────────────────────────────
class _ServiceSelectionSheet extends StatelessWidget {
  const _ServiceSelectionSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.divider(context), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            
            _ServiceCard(
              id: 'eco',
              title: "Moto-Eco",
              price: "${controller.currentTrip.value?.priceFCFA ?? 0} F",
              desc: "Chauffeur certifié · ${controller.currentTrip.value?.estimatedMinutes ?? 0} min",
              icon: FontAwesomeIcons.motorcycle,
            ),
            const SizedBox(height: 12),
            _ServiceCard(
              id: 'premium',
              title: "Moto-Premium",
              price: "${((controller.currentTrip.value?.priceFCFA ?? 0) * 1.5).round()} F",
              desc: "Top-Rated · Casque Premium incl.",
              icon: FontAwesomeIcons.crown,
            ),
            
            const SizedBox(height: 24),
            _buildPaymentAndPromo(context),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.nextStep,
                child: const Text("Commander NokiRide", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAndPromo(BuildContext context) {
    return Row(
      children: [
        // NokiPay
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent(context).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.wallet, color: AppColors.accent(context), size: 14),
                const SizedBox(width: 10),
                Text("NokiPay", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary(context), fontSize: 13)),
                const Spacer(),
                FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.textSub(context), size: 10),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Promo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: FaIcon(FontAwesomeIcons.tag, color: AppColors.accent(context), size: 14),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPOSANTS ÉCRAN 3 : MATCHING
// ─────────────────────────────────────────────────────────────
class _MatchingOverlay extends StatelessWidget {
  const _MatchingOverlay();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Container(
      color: AppColors.background(context).withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _RadarAnimation(),
            const SizedBox(height: 40),
            Text("Recherche d'un chauffeur...", 
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text("Moto-Eco vers ${controller.dropoff.value?.name}", 
                style: TextStyle(color: AppColors.textSub(context), fontWeight: FontWeight.w500)),
            const SizedBox(height: 60),
            TextButton(
              onPressed: controller.cancelTrip,
              child: const Text("ANNULER LA COURSE", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPOSANTS ÉCRAN 4 : TRACKING
// ─────────────────────────────────────────────────────────────
class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.divider(context), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(
              children: [
                // Driver Avatar
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppColors.textSub(context).withOpacity(0.2), shape: BoxShape.circle),
                  child: Center(child: FaIcon(FontAwesomeIcons.userLarge, color: AppColors.accent(context))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jean-Pierre M.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary(context))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.solidStar, color: AppColors.warning, size: 10),
                          const SizedBox(width: 4),
                          Text("4.9", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textSub(context))),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accent(context).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text("G-204-BC", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.accent(context))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                _ActionButton(icon: FontAwesomeIcons.phone, color: AppColors.accent(context)),
                const SizedBox(width: 10),
                _ActionButton(icon: FontAwesomeIcons.solidMessage, color: AppColors.accent(context)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.shieldHalved, color: AppColors.error, size: 16),
                const SizedBox(width: 10),
                const Text("Sécurité & Bouton SOS", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
                const Spacer(),
                FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.error.withOpacity(0.5), size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDGETS DE SUPPORT
// ─────────────────────────────────────────────────────────────

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Center(child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: AppColors.textPrimary(context))),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.id,
    required this.title,
    required this.price,
    required this.desc,
    required this.icon,
  });

  final String id;
  final String title, price, desc;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();
    return Obx(() {
      final isSelected = controller.selectedServiceId.value == id;
      return GestureDetector(
        onTap: () => controller.selectService(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent(context).withOpacity(0.05) : AppColors.background(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.accent(context) : AppColors.divider(context),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.accent(context).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: FaIcon(icon, color: AppColors.accent(context), size: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary(context))),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(fontSize: 12, color: AppColors.textSub(context), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary(context))),
            ],
          ),
        ),
      );
    });
  }
}

class _RecentPlaceItem extends StatelessWidget {
  const _RecentPlaceItem({required this.icon, required this.title, required this.address});
  final dynamic icon;
  final String title, address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface(context), shape: BoxShape.circle),
            child: Center(child: FaIcon(icon, size: 14, color: AppColors.textSub(context))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary(context))),
                Text(address, style: TextStyle(fontSize: 12, color: AppColors.textSub(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color});
  final dynamic icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
      child: Center(child: FaIcon(icon, color: color, size: 16)),
    );
  }
}

class _RadarAnimation extends StatefulWidget {
  const _RadarAnimation({super.key});

  @override
  State<_RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<_RadarAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent(context).withOpacity(1 - _controller.value), width: _controller.value * 20),
          ),
          child: Center(child: FaIcon(FontAwesomeIcons.motorcycle, color: AppColors.accent(context), size: 30)),
        );
      },
    );
  }
}
