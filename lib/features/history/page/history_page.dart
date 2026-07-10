import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../controller/history_controller.dart';
import '../model/history_model.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    final bg         = AppColors.background(context);
    final titleC     = AppColors.textPrimary(context);
    final subC       = AppColors.textSub(context);
    final primary    = AppColors.accent(context);

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(children: [
          // ── Header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Mes Activités",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.8)),
                const SizedBox(height: 2),
                Text("${controller.trips.length} courses · ${controller.deliveries.length} envois",
                    style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
              ]),
              const Spacer(),
              _HeaderActionBtn(icon: FontAwesomeIcons.sliders),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Tabs pill toggle ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => _PillTabs(
              selected: controller.mainTabIndex.value,
              onTap:    (i) => controller.mainTabIndex.value = i,
              primary:  primary,
            )),
          ),
          const SizedBox(height: 16),

          // ── Contenu ───────────────────────────────────────
          Expanded(
            child: Obx(() => controller.mainTabIndex.value == 0
                ? _EnCoursTab(primary: primary)
                : _HistoriqueTab(primary: primary, controller: controller)),
          ),
        ]),
      ),
    );
  }
}

class _HeaderActionBtn extends StatelessWidget {
  const _HeaderActionBtn({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider(context), width: 1.2),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(child: FaIcon(icon, color: AppColors.accent(context), size: 16)),
    );
  }
}

// ── Tabs pill toggle ────────────────────────────────────────────
class _PillTabs extends StatelessWidget {
  const _PillTabs({
    required this.selected, required this.onTap,
    required this.primary,
  });
  final int      selected;
  final Function(int) onTap;
  final Color    primary;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = AppColors.surface(context);
    final border  = AppColors.divider(context);
    final inactC  = AppColors.textSub(context);
    final labels  = ['ongoing'.tr, 'history'.tr];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.2),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve:    Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:        active ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    color:      active ? Colors.white : inactC,
                    letterSpacing: active ? -0.2 : 0,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Tab "En cours" ——————————————————————————————————————————────
class _EnCoursTab extends StatelessWidget {
  const _EnCoursTab({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final titleC = AppColors.textPrimary(context);
    final subC   = AppColors.textSub(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: 0.15), width: 2),
            ),
            child: Center(child: FaIcon(FontAwesomeIcons.motorcycle, color: primary, size: 40)),
          ),
          const SizedBox(height: 28),
          Text("no_ongoing_activity".tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            "no_ongoing_subtitle".tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: subC, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Get.toNamed(Routes.trip),
              icon: const FaIcon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
              label: Text("book_ride".tr,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Tab "Historique" ────────────────────────────────────────────
class _HistoriqueTab extends StatelessWidget {
  const _HistoriqueTab(
      {required this.primary, required this.controller});
  final Color             primary;
  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    final subC   = AppColors.textSub(context);

    return Column(children: [
      // Sous-onglets
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Obx(() => Row(children: [
          _SubTab(
            label:   "my_rides".tr,
            icon:    FontAwesomeIcons.motorcycle,
            count:   controller.trips.length,
            active:  controller.histTabIndex.value == 0,
            primary: primary,
            onTap:   () => controller.histTabIndex.value = 0,
          ),
          const SizedBox(width: 12),
          _SubTab(
            label:   "deliveries".tr,
            icon:    FontAwesomeIcons.boxOpen,
            count:   controller.deliveries.length,
            active:  controller.histTabIndex.value == 1,
            primary: primary,
            onTap:   () => controller.histTabIndex.value = 1,
          ),
          const SizedBox(width: 12),
          _SubTab(
            label:   "Transactions",
            icon:    FontAwesomeIcons.wallet,
            count:   Get.find<WalletController>().transactions.length,
            active:  controller.histTabIndex.value == 2,
            primary: primary,
            onTap:   () => controller.histTabIndex.value = 2,
          ),
        ])),
      ),

      Expanded(
        child: Obx(() {
          final grouped = controller.histTabIndex.value == 0
              ? controller.groupedTrips
              : controller.histTabIndex.value == 1 
                ? controller.groupedDeliveries
                : controller.groupedTransactions;

          if (grouped.isEmpty) {
            return Center(child: Text("no_entries".tr,
                style: TextStyle(color: AppColors.textSub(context), fontWeight: FontWeight.w600)));
          }

          final dates = grouped.keys.toList();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: dates.length,
            itemBuilder: (_, di) {
              final date  = dates[di];
              final items = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de groupe
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: Row(children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.neonYellow, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(date,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
                              letterSpacing: -0.2)),
                      const Spacer(),
                      Text("${items.length} ${'entry'.tr}${items.length > 1 ? 's' : ''}",
                          style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  ...items.map((h) => _HistoryTile(
                    item:    h,
                    primary: primary,
                    onTap:   () => Get.to(() => HistoryDetailPage(item: h)),
                  )),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        }),
      ),
    ]);
  }
}

// ── Sous-tab pill ───────────────────────────────────────────────
class _SubTab extends StatelessWidget {
  const _SubTab({
    required this.label, required this.icon, required this.count,
    required this.active, required this.primary,
    required this.onTap,
  });
  final String   label;
  final IconData icon;
  final int      count;
  final bool     active;
  final Color    primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg     = active ? primary : AppColors.surface(context);
    final textC  = active ? Colors.white : AppColors.textSub(context);
    final border = active ? primary : AppColors.divider(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 1.2),
          boxShadow: active ? [
            BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4)),
          ] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          FaIcon(icon, size: 14, color: textC),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textC)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color:        (active ? Colors.white : primary).withValues(alpha: active ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text("$count",
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900,
                    color: active ? Colors.white : primary)),
          ),
        ]),
      ),
    );
  }
}

// ── Tile historique ─────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  const _HistoryTile(
      {required this.item, required this.primary, required this.onTap});
  final HistoryModel item;
  final Color        primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg      = AppColors.surface(context);
    final border  = AppColors.divider(context);
    final titleC  = AppColors.textPrimary(context);
    final subC    = AppColors.textSub(context);
    final statusColor = item.status == HistoryStatus.completed ? AppColors.success
        : item.status == HistoryStatus.cancelled ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "completed".tr
        : item.status == HistoryStatus.cancelled ? "cancelled".tr : "ongoing_caps".tr;
    final isTrip = item.type == HistoryType.trip;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color:  primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: FaIcon(
                      isTrip ? FontAwesomeIcons.motorcycle : FontAwesomeIcons.boxOpen,
                      color: primary, size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(item.courierName,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleC, letterSpacing: -0.2),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(item.formattedPrice,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primary, letterSpacing: -0.5)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text("${item.formattedDate} · ${item.id}",
                        style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _RouteRow(
                    departure: item.title.split(" → ")[0],
                    arrival:   item.title.split(" → ").length > 1 ? item.title.split(" → ")[1] : '',
                  ),
                ])),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Affichage trajet compact ────────────────────────────────────
class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.departure, required this.arrival});
  final String departure, arrival;

  @override
  Widget build(BuildContext context) {
    final textC = AppColors.textSub(context);
    return Row(children: [
      Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Flexible(child: Text(departure,
          style: TextStyle(fontSize: 12, color: textC, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FaIcon(FontAwesomeIcons.arrowRight, size: 10, color: textC.withValues(alpha: 0.5)),
      ),
      Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Flexible(child: Text(arrival,
          style: TextStyle(fontSize: 12, color: textC, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
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
