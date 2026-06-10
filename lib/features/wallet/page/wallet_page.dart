import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(children: [
                Text("my_wallet".tr,
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.w900, 
                      color: titleC,
                      letterSpacing: -0.8,
                    )),
                const Spacer(),
                _CircleBtn(
                  icon: FontAwesomeIcons.fileInvoice,
                  isDark: isDark,
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _BalanceCard(isDark: isDark, ctrl: controller),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _QuickActionsRow(isDark: isDark, ctrl: controller),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MonthlyStats(isDark: isDark),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text("recent_transactions".tr,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleC)),
                const Spacer(),
                Text("see_all".tr,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.emeraldPrimary)),
              ]),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                itemCount: controller.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _TxTile(item: controller.transactions[i], isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.isDark, required this.onTap});
  final dynamic icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(child: FaIcon(icon, color: AppColors.emeraldPrimary, size: 18)),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.isDark, required this.ctrl});
  final bool isDark;
  final WalletController ctrl;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.emeraldPrimary,
        isDark ? AppColors.darkGreenBase : AppColors.darkGreenSurface,
      ],
      stops: const [0.0, 1.0],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldPrimary.withValues(alpha: isDark ? 0.4 : 0.2),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _NokiPayBadge(),
            const Spacer(),
            GestureDetector(
              onTap: ctrl.toggleVisibility,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Center(child: FaIcon(
                  ctrl.balanceVisible.value
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  color: Colors.white.withValues(alpha: 0.9), size: 16,
                ))),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Text("available_balance".tr,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: Text(
              key: ValueKey(ctrl.balanceVisible.value),
              ctrl.balanceVisible.value ? ctrl.formattedBalance : "•••••• F CFA",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0),
            ),
          )),
          const SizedBox(height: 28),
          Row(children: [
            _CardDots(),
            const SizedBox(width: 6),
            Text("7821",
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
            const Spacer(),
            Container(
              width: 44, height: 28,
              decoration: BoxDecoration(
                color: AppColors.neonYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: FaIcon(FontAwesomeIcons.rss,
                  color: AppColors.neonYellow, size: 16)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _NokiPayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        FaIcon(FontAwesomeIcons.wallet,
            color: Colors.white.withValues(alpha: 0.9), size: 12),
        const SizedBox(width: 8),
        Text("NokiPay",
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: .6)),
      ]),
    );
  }
}

class _CardDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (group) => Row(
        children: [
          ...List.generate(4, (_) => Container(
            width: 5, height: 5,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
          )),
          const SizedBox(width: 6),
        ],
      )),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.isDark, required this.ctrl});
  final bool isDark;
  final WalletController ctrl;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final cardBg = isDark ? AppColors.bgDarkSurface : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final List<(dynamic, String)> actions = [
      (FontAwesomeIcons.plus, "recharge".tr),
      (FontAwesomeIcons.paperPlane, "send".tr),
      (FontAwesomeIcons.clockRotateLeft, "history".tr),
      (FontAwesomeIcons.qrcode, "scan".tr),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        final (icon, label) = a;
        final isRecharge = label == "recharge".tr;

        return GestureDetector(
          onTap: isRecharge ? () => _showRechargeSheet(context) : () {},
          child: Column(children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border, width: 1.5),
                boxShadow: isDark ? [] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(child: FaIcon(icon, color: AppColors.emeraldPrimary, size: 24)),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: titleC,
                  letterSpacing: -0.2,
                )),
          ]),
        );
      }).toList(),
    );
  }

  void _showRechargeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RechargeSheet(isDark: isDark, ctrl: ctrl),
    );
  }
}

class _RechargeSheet extends StatelessWidget {
  const _RechargeSheet({required this.isDark, required this.ctrl});
  final bool isDark;
  final WalletController ctrl;

  static const _amounts = [1000, 2000, 5000, 10000, 20000];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final primary = AppColors.emeraldPrimary;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
          color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 5,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(10)),
          )),
          const SizedBox(height: 24),
          Text("recharge_wallet".tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text("choose_recharge_amount".tr,
              style: TextStyle(fontSize: 14, color: subC, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: _amounts.map((a) {
              final label = "${a >= 1000 ? "${a ~/ 1000}k" : a} F CFA";
              return GestureDetector(
                onTap: () { ctrl.recharge(a); Get.back(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Text(label,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkElevated : AppColors.bgLight.withValues(alpha: 0.5), 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: FaIcon(FontAwesomeIcons.pen, color: primary, size: 16),
              ),
              const SizedBox(width: 14),
              Text("custom_amount".tr,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: titleC)),
              const Spacer(),
              FaIcon(FontAwesomeIcons.chevronRight, color: subC, size: 16),
            ]),
          ),
        ],
      ),
    );
  }
}

class _MonthlyStats extends StatelessWidget {
  const _MonthlyStats({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Row(children: [
      Expanded(child: _MiniStatCard(
        isDark: isDark, cardBg: cardBg, border: border, titleC: titleC, subC: subC,
        icon: FontAwesomeIcons.arrowDown, color: AppColors.success,
        label: "received_this_month".tr, value: "+15 000 F",
      )),
      const SizedBox(width: 12),
      Expanded(child: _MiniStatCard(
        isDark: isDark, cardBg: cardBg, border: border, titleC: titleC, subC: subC,
        icon: FontAwesomeIcons.arrowUp, color: AppColors.error,
        label: "spent_this_month".tr, value: "-4 700 F",
      )),
    ]);
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.isDark, required this.cardBg, required this.border,
    required this.titleC, required this.subC,
    required this.icon, required this.color, required this.label, required this.value,
  });
  final bool isDark;
  final Color cardBg, border, titleC, subC, color;
  final dynamic icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Center(child: FaIcon(icon, color: color, size: 16)),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 11, color: subC, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.item, required this.isDark});
  final TransactionModel item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
    final isCredit = item.type == TransactionType.credit;
    final color = isCredit ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 1.5),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: FaIcon(
            isCredit ? FontAwesomeIcons.circlePlus : FontAwesomeIcons.circleMinus,
            color: color, size: 20,
          )),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: titleC, letterSpacing: -0.2),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(item.formattedDate, style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(item.formattedAmount,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(isCredit ? "credit".tr : "debit".tr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
          ),
        ]),
      ]),
    );
  }
}
