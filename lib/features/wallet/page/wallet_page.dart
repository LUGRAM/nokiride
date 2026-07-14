import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/payment_method_selector.dart';
import '../../../core/storage/app_storage.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_model.dart';

class WalletPage extends GetView<WalletController> {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDriver = AppStorage.lastActiveRole == 'driver';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bg = isDark ? (isDriver ? AppColors.slate950 : AppColors.bgDark) : AppColors.bgLight;
    final surface = isDark ? (isDriver ? AppColors.slate900 : AppColors.bgDarkSurface) : AppColors.bgLightSurface;
    final border = isDark ? (isDriver ? AppColors.slateDivider : AppColors.borderDark) : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Portefeuille", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 22, color: titleC)),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.fileInvoice, color: titleC, size: 18),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _BalanceCard(isDark: isDark, isDriver: isDriver, ctrl: controller),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _QuickActionsRow(isDark: isDark, isDriver: isDriver, surface: surface, border: border, ctrl: controller),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _MonthlyStats(isDark: isDark, surface: surface, border: border),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Text("Transactions récentes",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: titleC)),
              const Spacer(),
              GestureDetector(
                onTap: controller.goToHistory,
                child: Text("Voir tout",
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              itemCount: controller.transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _TxTile(item: controller.transactions[i], isDark: isDark, surface: surface, border: border),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.isDark, required this.isDriver, required this.ctrl});
  final bool isDark;
  final bool isDriver;
  final WalletController ctrl;

  @override
  Widget build(BuildContext context) {
    final accent = isDriver ? AppColors.slate700 : AppColors.success;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDriver 
            ? [AppColors.slate900, AppColors.slate800]
            : [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isDriver ? Colors.black : AppColors.success).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _NokiPayBadge(isDriver: isDriver),
            const Spacer(),
            GestureDetector(
              onTap: ctrl.toggleVisibility,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Center(
                        child: FaIcon(
                      ctrl.balanceVisible.value
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      color: Colors.white,
                      size: 16,
                    ))),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          Text("SOLDE DISPONIBLE",
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Obx(() => Text(
                ctrl.balanceVisible.value ? ctrl.formattedBalance : "•••••• F CFA",
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0),
              )),
          const SizedBox(height: 32),
          Row(children: [
            Text("ID: 7821 **** ****",
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
            const Spacer(),
            const FaIcon(FontAwesomeIcons.nfcSymbol, color: Colors.white38, size: 20),
          ]),
        ],
      ),
    );
  }
}

class _NokiPayBadge extends StatelessWidget {
  final bool isDriver;
  const _NokiPayBadge({required this.isDriver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 12),
        const SizedBox(width: 8),
        Text(isDriver ? "COMPTE PRO" : "NOKIPAY",
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0)),
      ]),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.isDark, required this.isDriver, required this.surface, required this.border, required this.ctrl});
  final bool isDark, isDriver;
  final Color surface, border;
  final WalletController ctrl;

  @override
  Widget build(BuildContext context) {
    final List<(dynamic, String)> actions = [
      (FontAwesomeIcons.plus, "Recharge"),
      if (isDriver) (FontAwesomeIcons.moneyBillTransfer, "Retrait"),
      (FontAwesomeIcons.paperPlane, "Envoi"),
      (FontAwesomeIcons.qrcode, "Scan"),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        final (icon, label) = a;
        return GestureDetector(
          onTap: () {}, // Action logic simplified for UI refactor
          child: Column(children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Center(
                  child: FaIcon(icon, color: isDriver ? Colors.white : AppColors.success, size: 22)),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                )),
          ]),
        );
      }).toList(),
    );
  }
}

class _MonthlyStats extends StatelessWidget {
  const _MonthlyStats({required this.isDark, required this.surface, required this.border});
  final bool isDark;
  final Color surface, border;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _MiniStatCard(
        surface: surface,
        border: border,
        icon: FontAwesomeIcons.arrowDown,
        color: AppColors.success,
        label: "Entrant",
        value: "+45k F",
      )),
      const SizedBox(width: 12),
      Expanded(
          child: _MiniStatCard(
        surface: surface,
        border: border,
        icon: FontAwesomeIcons.arrowUp,
        color: AppColors.error,
        label: "Sortant",
        value: "-12k F",
      )),
    ]);
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.surface,
    required this.border,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final Color surface, border, color;
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FaIcon(icon, color: color, size: 14),
        const SizedBox(height: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.item, required this.isDark, required this.surface, required this.border});
  final TransactionModel item;
  final bool isDark;
  final Color surface, border;

  @override
  Widget build(BuildContext context) {
    final isCredit = item.type == TransactionType.credit;
    final color = isCredit ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(child: FaIcon(isCredit ? FontAwesomeIcons.plus : FontAwesomeIcons.minus, color: color, size: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(item.formattedDate, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(width: 12),
        Text(item.formattedAmount,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
      ]),
    );
  }
}
