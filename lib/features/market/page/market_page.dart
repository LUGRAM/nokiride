import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/market_controller.dart';

class MarketPage extends GetView<MarketController> {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final inputBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(children: [
                GestureDetector(onTap: Get.back, child: Icon(Icons.arrow_back_rounded, color: titleC)),
                const SizedBox(width: 14),
                Text("Market", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: titleC)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                child: Row(children: [
                  Icon(Icons.search_rounded, color: subC, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => controller.searchQuery.value = v,
                      style: TextStyle(fontSize: 14, color: titleC),
                      decoration: InputDecoration(border: InputBorder.none, hintText: "Chercher un marchand...", hintStyle: TextStyle(color: subC), isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredMerchants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final m = controller.filteredMerchants[i];
                  final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
                  return GestureDetector(
                    onTap: () async { await controller.selectMerchant(m.id); Get.toNamed(Routes.marketMerchant); },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                      child: Row(children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(color: primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text(m.emoji, style: const TextStyle(fontSize: 26))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.name, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: titleC)),
                          const SizedBox(height: 3),
                          Text("${m.category} · ${m.location}", style: TextStyle(fontSize: 12, color: subC)),
                          const SizedBox(height: 6),
                          Row(children: [
                            Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                            const SizedBox(width: 3),
                            Text("${m.rating} (${m.reviewCount})", style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            Icon(Icons.timer_outlined, size: 13, color: subC),
                            const SizedBox(width: 3),
                            Text("${m.deliveryMinutes} min", style: TextStyle(fontSize: 12, color: subC)),
                          ]),
                        ])),
                        Column(children: [
                          Text("${m.deliveryFee} F", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
                          Text("livraison", style: TextStyle(fontSize: 10, color: subC)),
                        ]),
                      ]),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
