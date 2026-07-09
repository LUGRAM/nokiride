import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/market_controller.dart';

class MerchantPage extends GetView<MarketController> {
  const MerchantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: Obx(() {
              final merchant = controller.selectedMerchant;
              if (merchant == null) return const SizedBox.shrink();

              return Column(
                children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(children: [
                    GestureDetector(onTap: Get.back, child: Icon(Icons.arrow_back_rounded, color: titleC)),
                    const SizedBox(width: 14),
                    Text(merchant.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleC)),
                  ]),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .9),
                    itemCount: controller.selectedProducts.length,
                    itemBuilder: (_, i) {
                      final p = controller.selectedProducts[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Center(child: Text(p.emoji, style: const TextStyle(fontSize: 40))),
                          const SizedBox(height: 8),
                          Text(p.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleC)),
                          const SizedBox(height: 3),
                          Text(p.description, style: TextStyle(fontSize: 11, color: subC), maxLines: 2),
                          const Spacer(),
                          Row(children: [
                            Text("${p.price} F", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: primary)),
                            const Spacer(),
                            Obx(() {
                              final qty = controller.quantityOf(p);
                              return qty == 0
                                  ? GestureDetector(
                                      onTap: () => controller.addToCart(p),
                                      child: Container(width: 28, height: 28, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white, size: 18)),
                                    )
                                  : Row(mainAxisSize: MainAxisSize.min, children: [
                                      GestureDetector(onTap: () => controller.removeFromCart(p), child: Container(width: 26, height: 26, decoration: BoxDecoration(color: primary.withOpacity(.15), borderRadius: BorderRadius.circular(7)), child: Icon(Icons.remove, color: primary, size: 16))),
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('$qty', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: titleC))),
                                      GestureDetector(onTap: () => controller.addToCart(p), child: Container(width: 26, height: 26, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(7)), child: const Icon(Icons.add, color: Colors.white, size: 16))),
                                    ]);
                            }),
                          ]),
                        ]),
                      );
                    },
                  ),
                ),
              ],
            );
            }),
          ),
          // Bouton panier
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: Obx(() => controller.cartCount > 0 ? GestureDetector(
              onTap: () => Get.toNamed(Routes.marketCart),
              child: Container(
                height: 56,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: primary.withOpacity(.35), blurRadius: 16, offset: const Offset(0, 6))]),
                child: Row(children: [
                  const SizedBox(width: 20),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.25), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${controller.cartCount}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))),
                  ),
                  const Spacer(),
                  const Text("Voir le panier", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(controller.formattedTotal, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 20),
                ]),
              ),
            ) : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
