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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: _CircleBackButton(isDark: isDark, onTap: controller.prevStep),
          ),

          // 3. UI Dynamique (Bottom Sheets)
          Obx(() {
            switch (controller.currentStep.value) {
              case TripStep.destination:
                return _DestinationSheet(isDark: isDark);
              case TripStep.selecting:
                return _ServiceSelectionSheet(isDark: isDark);
              case TripStep.matching:
                return _MatchingOverlay(isDark: isDark);
              case TripStep.tracking:
                return _TrackingSheet(isDark: isDark);
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
  const _DestinationSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface,
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
              icon: FontAwesomeIcons.circleDot,
              color: AppColors.emeraldPrimary,
              hint: "Position actuelle",
              value: controller.pickup.value?.name ?? "Chargement...",
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildSearchInput(
              icon: FontAwesomeIcons.locationDot,
              color: AppColors.neonYellow,
              hint: "Où allez-vous ?",
              isDark: isDark,
              autofocus: true,
              onChanged: controller.searchPlace,
            ),
            const SizedBox(height: 20),
            
            // Résultats de recherche
            Obx(() {
              if (controller.searchResults.isEmpty) {
                return _buildRecentPlaces(isDark);
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final place = controller.searchResults[index];
                    return ListTile(
                      leading: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 14, color: AppColors.greyMuted),
                      title: Text(place.name, style: TextStyle(color: isDark ? Colors.white : AppColors.darkGreenBase, fontWeight: FontWeight.w700)),
                      subtitle: Text(place.address, style: const TextStyle(fontSize: 12, color: AppColors.greyMuted)),
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

  Widget _buildSearchInput({
    required dynamic icon,
    required Color color,
    required String hint,
    required bool isDark,
    String? value,
    bool autofocus = false,
    Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark.withOpacity(0.5) : AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
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
                color: isDark ? Colors.white : AppColors.darkGreenBase,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.greyMuted, fontWeight: FontWeight.w500),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPlaces(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RÉCENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.greyMuted, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        _RecentPlaceItem(icon: FontAwesomeIcons.house, title: "Maison", address: "Akanda, Cité de la Caisse", isDark: isDark),
        _RecentPlaceItem(icon: FontAwesomeIcons.briefcase, title: "Travail", address: "Centre-ville, Immeuble inter-bancaire", isDark: isDark),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPOSANTS ÉCRAN 2 : SÉLECTION SERVICE
// ─────────────────────────────────────────────────────────────
class _ServiceSelectionSheet extends StatelessWidget {
  const _ServiceSelectionSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? AppColors.borderDark : AppColors.borderLight, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            
            _ServiceCard(
              id: 'eco',
              title: "Moto-Eco",
              price: "${controller.currentTrip.value?.priceFCFA ?? 0} F",
              desc: "Chauffeur certifié · ${controller.currentTrip.value?.estimatedMinutes ?? 0} min",
              icon: FontAwesomeIcons.motorcycle,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ServiceCard(
              id: 'premium',
              title: "Moto-Premium",
              price: "${((controller.currentTrip.value?.priceFCFA ?? 0) * 1.5).round()} F",
              desc: "Top-Rated · Casque Premium incl.",
              icon: FontAwesomeIcons.crown,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            _buildPaymentAndPromo(isDark),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.nextStep,
                child: const Text("Commander NokiRide", style: TextStyle(color: AppColors.darkGreenBase, fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAndPromo(bool isDark) {
    return Row(
      children: [
        // NokiPay
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkElevated : AppColors.bgLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.emeraldPrimary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.wallet, color: AppColors.emeraldPrimary, size: 14),
                const SizedBox(width: 10),
                Text("NokiPay", style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.darkGreenBase, fontSize: 13)),
                const Spacer(),
                const FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.greyMuted, size: 10),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Promo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDarkElevated : AppColors.bgLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const FaIcon(FontAwesomeIcons.tag, color: AppColors.neonYellow, size: 14),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPOSANTS ÉCRAN 3 : MATCHING
// ─────────────────────────────────────────────────────────────
class _MatchingOverlay extends StatelessWidget {
  const _MatchingOverlay({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Container(
      color: (isDark ? AppColors.bgDark : Colors.white).withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RadarAnimation(),
            const SizedBox(height: 40),
            Text("Recherche d'un chauffeur...", 
                style: TextStyle(color: isDark ? Colors.white : AppColors.darkGreenBase, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text("Moto-Eco vers ${controller.dropoff.value?.name}", 
                style: const TextStyle(color: AppColors.greyMuted, fontWeight: FontWeight.w500)),
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
  const _TrackingSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? AppColors.borderDark : AppColors.borderLight, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(
              children: [
                // Driver Avatar
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppColors.greyMuted.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Center(child: FaIcon(FontAwesomeIcons.userLarge, color: AppColors.emeraldPrimary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jean-Pierre M.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : AppColors.darkGreenBase)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.solidStar, color: AppColors.neonYellow, size: 10),
                          const SizedBox(width: 4),
                          const Text("4.9", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.greyMuted)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.emeraldPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text("G-204-BC", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.emeraldPrimary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                _ActionButton(icon: FontAwesomeIcons.phone, color: AppColors.emeraldPrimary, isDark: isDark),
                const SizedBox(width: 10),
                _ActionButton(icon: FontAwesomeIcons.solidMessage, color: AppColors.emeraldPrimary, isDark: isDark),
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
  const _CircleBackButton({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Center(child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: isDark ? Colors.white : AppColors.darkGreenBase)),
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
    required this.isDark,
  });

  final String id;
  final String title, price, desc;
  final dynamic icon;
  final bool isDark;

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
            color: isSelected ? AppColors.emeraldPrimary.withOpacity(0.05) : (isDark ? AppColors.bgDark : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.neonYellow : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.emeraldPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: FaIcon(icon, color: AppColors.emeraldPrimary, size: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.darkGreenBase)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.greyMuted, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : AppColors.darkGreenBase)),
            ],
          ),
        ),
      );
    });
  }
}

class _RecentPlaceItem extends StatelessWidget {
  const _RecentPlaceItem({required this.icon, required this.title, required this.address, required this.isDark});
  final dynamic icon;
  final String title, address;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: isDark ? AppColors.bgDarkElevated : AppColors.bgLight, shape: BoxShape.circle),
            child: Center(child: FaIcon(icon, size: 14, color: AppColors.greyMuted)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : AppColors.darkGreenBase)),
                Text(address, style: const TextStyle(fontSize: 12, color: AppColors.greyMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.isDark});
  final dynamic icon;
  final Color color;
  final bool isDark;

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
            border: Border.all(color: AppColors.emeraldPrimary.withOpacity(1 - _controller.value), width: _controller.value * 20),
          ),
          child: const Center(child: FaIcon(FontAwesomeIcons.motorcycle, color: AppColors.emeraldPrimary, size: 30)),
        );
      },
    );
  }
}
