import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_model.dart';

class WalletPage extends GetView<WalletController> {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text("Wallet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: titleC)),
            ),
            const SizedBox(height: 16),
            // Balance card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0E2240), const Color(0xFF0A1628)]
                        : [primary, primary.withOpacity(.75)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withOpacity(.8), size: 20),
                      const SizedBox(width: 8),
                      Text("Solde disponible", style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: controller.toggleVisibility,
                        child: Obx(() => Icon(controller.balanceVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withOpacity(.7), size: 20)),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Obx(() => Text(
                      controller.balanceVisible.value ? controller.formattedBalance : "••••••",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -.5),
                    )),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => _showRechargeSheet(context, isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(12)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text("Recharger", style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text("Transactions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleC)),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _TransactionTile(item: controller.transactions[i], isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRechargeSheet(BuildContext context, bool isDark) {
    final amounts = [1000, 2000, 5000, 10000, 20000];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
        final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
        final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
        final border = isDark ? AppColors.borderDark : AppColors.borderLight;
        return Container(
          decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text("Choisir un montant", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: titleC)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: amounts.map((a) => GestureDetector(
                  onTap: () { controller.recharge(a); Get.back(); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(color: primary.withOpacity(.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withOpacity(.25))),
                    child: Text("${a ~/ 1000 >= 1 ? "${a ~/ 1000}k" : a} F CFA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primary)),
                  ),
                )).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.isDark});
  final TransactionModel item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightSub;
    final isCredit = item.type == TransactionType.credit;
    final amountColor = isCredit ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: amountColor.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
          child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: amountColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleC), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(item.formattedDate, style: TextStyle(fontSize: 11, color: subC)),
        ])),
        Text(item.formattedAmount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: amountColor)),
      ]),
    );
  }
}
