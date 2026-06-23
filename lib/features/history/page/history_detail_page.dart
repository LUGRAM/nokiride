import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../model/history_model.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.item});
  final HistoryModel item;

  @override
  Widget build(BuildContext context) {
    final bg        = AppColors.background(context);
    final cardBg    = AppColors.surface(context);
    final border    = AppColors.divider(context);
    final titleC    = AppColors.textPrimary(context);
    final subC      = AppColors.textSub(context);
    final primary   = AppColors.accent(context);

    final statusColor = item.status == HistoryStatus.completed ? AppColors.success
        : item.status == HistoryStatus.cancelled ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "completed".tr
        : item.status == HistoryStatus.cancelled ? "cancelled".tr : "ongoing_caps".tr;
    final typeLabel   = item.type == HistoryType.trip ? "moto_taxi".tr : "delivery".tr;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          // ── AppBar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
                GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color:        cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: border, width: 1.2),
                  ),
                  child: Center(child: FaIcon(FontAwesomeIcons.arrowLeft, color: titleC, size: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("$typeLabel · ${item.id}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text(item.groupDate,
                    style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:        statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const SizedBox(height: 8),

                // ── Coursier ──────────────────────────────
                _DetailCard(cardBg: cardBg, border: border, child: Row(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color:  primary.withValues(alpha: 0.1), 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(child: FaIcon(FontAwesomeIcons.user, color: primary, size: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.courierName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.2)),
                    const SizedBox(height: 4),
                    Text(item.courierVehicle,
                        style: TextStyle(fontSize: 13, color: subC, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.neonYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        FaIcon(FontAwesomeIcons.solidStar, color: Theme.of(context).brightness == Brightness.dark ? AppColors.neonYellow : AppColors.warning, size: 10),
                        const SizedBox(width: 6),
                        Text("${item.courierRating}",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? AppColors.neonYellow : AppColors.darkGreenBase)),
                      ]),
                    ),
                  ])),
                ])),
                const SizedBox(height: 16),

                // ── Trajet ────────────────────────────────
                _DetailCard(cardBg: cardBg, border: border, child: Column(children: [
                  _DetailRouteRow(dot: AppColors.success, label: item.title.split(" → ")[0], titleC: titleC),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.5),
                    child: Container(width: 1.5, height: 24, color: border),
                  ),
                  _DetailRouteRow(
                    dot: AppColors.error,
                    label: item.title.split(" → ").length > 1 ? item.title.split(" → ")[1] : '',
                    titleC: titleC,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.bgDarkElevated : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("total_price".tr, style: TextStyle(fontSize: 11, color: subC, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      Text(item.formattedPrice,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primary, letterSpacing: -0.5)),
                    ]),
                  ),
                ])),
                const SizedBox(height: 16),

                // ── Annulation ────────────────────────────
                if (item.status == HistoryStatus.cancelled)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:        AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Row(children: [
                      const FaIcon(FontAwesomeIcons.circleXmark, color: AppColors.error, size: 18),
                      const SizedBox(width: 12),
                      Text("cancelled_by_user".tr,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.error, letterSpacing: 0.5)),
                    ]),
                  ),
                const SizedBox(height: 24),

                // ── Support ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: titleC,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side:            BorderSide(color: border, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    icon:  const FaIcon(FontAwesomeIcons.headset, size: 16),
                    label: Text("help".tr,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.cardBg, required this.border, required this.child});
  final Color  cardBg, border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: border, width: 1.0),
      ),
      child: child,
    );
  }
}

class _DetailRouteRow extends StatelessWidget {
  const _DetailRouteRow({required this.dot, required this.label, required this.titleC});
  final Color  dot, titleC;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      const SizedBox(width: 12),
      Expanded(child: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleC),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}
