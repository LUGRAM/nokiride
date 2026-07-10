import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../trip/widget/mini_map_widget.dart';
import '../controller/delivery_controller.dart';
import '../model/delivery_model.dart';

class DeliveryTrackingPage extends GetView<DeliveryController> {
  const DeliveryTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() => MiniMapWidget(
                  pickup: controller.pickup.value,
                  dropoff: controller.dropoff.value,
                  driverLocation: controller.courierLocation.value,
                  showDriver: true,
                )),
          ),
          Positioned(
            top: 60,
            right: 16,
            child: SafeArea(child: _SosBtn()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CourierSheet(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _SosBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.dialog(AlertDialog(
        title: const Text('Urgence SOS'),
        content:
            const Text('Votre position et celle du colis seront partagées.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: Get.back,
            child: const Text('Confirmer SOS'),
          ),
        ],
      )),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.error.withOpacity(.40),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: const Center(
          child: Text('SOS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _CourierSheet extends GetView<DeliveryController> {
  const _CourierSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC =
        isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final accent = AppColors.serviceEnvoi;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 20,
              offset: const Offset(0, -6))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
                color: border, borderRadius: BorderRadius.circular(2)),
          ),

          // Statut
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle)),
              Text('Coursier en route avec votre colis',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent)),
            ],
          ),
          const SizedBox(height: 14),

          // Coursier
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(.25)),
                ),
                child: Icon(Icons.person_rounded, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Marc-Aurèle N.',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: titleC)),
                    Text('Honda XR125 • LBV-3315-B',
                        style: TextStyle(fontSize: 12.5, color: subC)),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                  Text('4.9',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: titleC)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: border),
          const SizedBox(height: 16),

          // Infos colis
          Obx(() {
            final d = controller.currentDelivery.value;
            if (d == null) return const SizedBox.shrink();
            return Row(
              children: [
                Text(d.parcelSize.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.pickup.name} → ${d.dropoff.name}',
                        style: TextStyle(
                            fontSize: 13,
                            color: subC,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Destinataire : ${d.recipient.name} · ${d.recipient.phone}',
                        style: TextStyle(fontSize: 12, color: subC),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  d.formattedPrice,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: accent),
                ),
              ],
            );
          }),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.completeDelivery,
              child: const Text('Livraison confirmée',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
