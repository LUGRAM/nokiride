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
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(children: [
                Text("Mon Wallet",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: titleC)),
                const Spacer(),
                _CircleBtn(
                  icon: Icons.receipt_long_rounded,
                  primary: primary, isDark: isDark,
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 18),

            // ── Balance Card ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _BalanceCard(isDark: isDark, primary: primary, ctrl: controller),
            ),
            const SizedBox(height: 16),

            // ── Quick Actions ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _QuickActionsRow(isDark: isDark, ctrl: controller),
            ),
            const SizedBox(height: 20),

            // ── Monthly Stats ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MonthlyStats(isDark: isDark),
            ),
            const SizedBox(height: 20),

            // ── Transactions header ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text("Transactions récentes",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleC)),
                const Spacer(),
                Text("Voir tout",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
              ]),
            ),
            const SizedBox(height: 10),

            // ── Transactions List ───────────────────────────
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

// ── Bouton icône rond ───────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.primary, required this.isDark, required this.onTap});
  final IconData icon;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primary, size: 20),
      ),
    );
  }
}

// ── Carte balance premium ───────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.isDark, required this.primary, required this.ctrl});
  final bool isDark;
  final Color primary;
  final WalletController ctrl;

  @override
  Widget build(BuildContext context) {
    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0E2E8A), Color(0xFF07101E)],
            stops: [0.0, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF00C44F), Color(0xFF008A36)],
            stops: [0.0, 1.0],
          );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .30),
            blurRadius: 30, offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row : badge + eye toggle
          Row(children: [
            _NokiPayBadge(),
            const Spacer(),
            GestureDetector(
              onTap: ctrl.toggleVisibility,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(() => Icon(
                  ctrl.balanceVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: .85), size: 18,
                )),
              ),
            ),
          ]),

          const SizedBox(height: 18),

          // Label + Balance
          Text("Solde disponible",
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .65),
                  fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: .5)),
          const SizedBox(height: 6),
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: Text(
              key: ValueKey(ctrl.balanceVisible.value),
              ctrl.balanceVisible.value ? ctrl.formattedBalance : "•••••• F CFA",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -.8),
            ),
          )),

          const SizedBox(height: 22),

          // Card number row
          Row(children: [
            _CardDots(),
            const SizedBox(width: 4),
            Text("7821",
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 2.5)),
            const Spacer(),
            Container(
              width: 42, height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.contactless_rounded,
                  color: Colors.white.withValues(alpha: .8), size: 17),
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
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(Icons.account_balance_wallet_rounded,
            color: Colors.white.withValues(alpha: .9), size: 12),
        const SizedBox(width: 5),
        Text("NokiPay",
            style: TextStyle(
                color: Colors.white.withValues(alpha: .9),
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
              color: Colors.white.withValues(alpha: .45),
              shape: BoxShape.circle,
            ),
          )),
          const SizedBox(width: 6),
        ],
      )),
    );
  }
}

// ── Ligne d'actions rapides ─────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.isDark, required this.ctrl});
  final bool isDark;
  final WalletController ctrl;

  static const _actions = [
    (Icons.add_rounded,      "Recharger",  AppColors.primaryGreen),
    (Icons.send_rounded,     "Envoyer",    AppColors.primaryBlue),
    (Icons.swap_horiz_rounded,"Historique",AppColors.warning),
    (Icons.qr_code_rounded,  "Scanner",   AppColors.servicePlan),
  ];

  @override
  Widget build(BuildContext context) {
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _actions.map((a) {
        final (icon, label, color) = a;
        final isRecharge = label == "Recharger";

        return GestureDetector(
          onTap: isRecharge ? () => _showRechargeSheet(context) : () {},
          child: Column(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: .22)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 7),
            Text(label,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: subC)),
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

// ── Bottom sheet recharge ───────────────────────────────────────
class _RechargeSheet extends StatelessWidget {
  const _RechargeSheet({required this.isDark, required this.ctrl});
  final bool isDark;
  final WalletController ctrl;

  static const _amounts = [1000, 2000, 5000, 10000, 20000];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final elevated = isDark ? AppColors.bgDarkElevated : const Color(0xFFF4F4F4);
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
          color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          Text("Recharger le wallet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleC)),
          const SizedBox(height: 4),
          Text("Choisissez un montant à ajouter",
              style: TextStyle(fontSize: 13, color: subC)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _amounts.map((a) {
              final label = "${a >= 1000 ? "${a ~/ 1000}k" : a} F CFA";
              return GestureDetector(
                onTap: () { ctrl.recharge(a); Get.back(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withValues(alpha: .28)),
                  ),
                  child: Text(label,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: elevated, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              Icon(Icons.edit_rounded, color: primary, size: 18),
              const SizedBox(width: 10),
              Text("Montant personnalisé",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subC)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: subC, size: 20),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Statistiques du mois ────────────────────────────────────────
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
        icon: Icons.arrow_downward_rounded, color: AppColors.success,
        label: "Reçu ce mois", value: "+15 000 F",
      )),
      const SizedBox(width: 12),
      Expanded(child: _MiniStatCard(
        isDark: isDark, cardBg: cardBg, border: border, titleC: titleC, subC: subC,
        icon: Icons.arrow_upward_rounded, color: AppColors.error,
        label: "Dépensé ce mois", value: "-4 700 F",
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
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 11, color: subC, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}

// ── Tile transaction ────────────────────────────────────────────
class _TxTile extends StatelessWidget {
  const _TxTile({required this.item, required this.isDark});
  final TransactionModel item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightSub;
    final isCredit = item.type == TransactionType.credit;
    final color = isCredit ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color, size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleC),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(item.formattedDate, style: TextStyle(fontSize: 11, color: subC)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(item.formattedAmount,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(6)),
            child: Text(isCredit ? "Crédit" : "Débit",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        ]),
      ]),
    );
  }
}
