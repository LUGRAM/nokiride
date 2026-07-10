import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/payment_method_selector.dart';
import '../controller/market_controller.dart';

class CartPage extends GetView<MarketController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final titleC =
        isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(children: [
                GestureDetector(
                    onTap: Get.back,
                    child: Icon(Icons.arrow_back_rounded, color: titleC)),
                const SizedBox(width: 14),
                Text("Mon panier",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: titleC)),
              ]),
            ),
            Expanded(
              child: Obx(() => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = controller.cart[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border)),
                        child: Row(children: [
                          Text(item.product.emoji,
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(item.product.name,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: titleC)),
                                Text("${item.product.price} F CFA",
                                    style:
                                        TextStyle(fontSize: 12, color: subC)),
                              ])),
                          Row(children: [
                            GestureDetector(
                                onTap: () =>
                                    controller.removeFromCart(item.product),
                                child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: primary.withValues(alpha: .12),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.remove,
                                        color: primary, size: 16))),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.quantity}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: titleC))),
                            GestureDetector(
                                onTap: () => controller.addToCart(item.product),
                                child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: primary,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 16))),
                          ]),
                        ]),
                      );
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        controller.deliveryAddress.value = value,
                    style: TextStyle(fontSize: 14, color: titleC),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Adresse de livraison',
                      hintStyle: TextStyle(color: subC),
                      icon: Icon(Icons.location_on_outlined,
                          color: primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final method = paymentMethodByValue(
                      controller.selectedPaymentMethod.value);
                  return GestureDetector(
                    onTap: () async {
                      final value = await showPaymentMethodSelector(
                        context: context,
                        selectedMethod: controller.selectedPaymentMethod.value,
                      );
                      if (value != null) controller.selectPaymentMethod(value);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(children: [
                        Icon(method.icon, color: primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            method.label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: titleC),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: subC, size: 20),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Obx(() => Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Articles",
                                style: TextStyle(fontSize: 13, color: subC)),
                            Text(controller.formattedSubtotal,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: titleC)),
                          ]),
                      const SizedBox(height: 6),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Livraison",
                                style: TextStyle(fontSize: 13, color: subC)),
                            Text(controller.formattedDeliveryFee,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: titleC)),
                          ]),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: titleC)),
                            Text(controller.formattedTotal,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: primary)),
                          ]),
                    ])),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(() => FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        onPressed: controller.isOrdering.value
                            ? null
                            : controller.createOrder,
                        child: controller.isOrdering.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Commander",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      )),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
