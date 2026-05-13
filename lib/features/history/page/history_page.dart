import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/history_controller.dart';
import '../model/history_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? AppColors.bgDark : AppColors.bgLight;
    final titleC     = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC       = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final primary    = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(children: [
          // ── Header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Activités",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: titleC)),
                const SizedBox(height: 2),
                Text("${controller.trips.length} courses · ${controller.deliveries.length} livraisons",
                    style: TextStyle(fontSize: 12.5, color: subC, fontWeight: FontWeight.w500)),
              ]),
              const Spacer(),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.filter_list_rounded, color: primary, size: 20),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Tabs pill toggle ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => _PillTabs(
              selected: controller.mainTabIndex.value,
              onTap:    (i) => controller.mainTabIndex.value = i,
              isDark:   isDark,
              primary:  primary,
            )),
          ),
          const SizedBox(height: 14),

          // ── Contenu ───────────────────────────────────────
          Expanded(
            child: Obx(() => controller.mainTabIndex.value == 0
                ? _EnCoursTab(isDark: isDark, primary: primary)
                : _HistoriqueTab(isDark: isDark, primary: primary, controller: controller)),
          ),
        ]),
      ),
    );
  }
}

// ── Tabs pill toggle ────────────────────────────────────────────
class _PillTabs extends StatelessWidget {
  const _PillTabs({
    required this.selected, required this.onTap,
    required this.isDark, required this.primary,
  });
  final int      selected;
  final Function(int) onTap;
  final bool     isDark;
  final Color    primary;

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark    : AppColors.borderLight;
    final inactC  = isDark ? AppColors.textDarkSub   : AppColors.textLightSub;
    final labels  = ['En cours', 'Historique'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve:    Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:        active ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active ? [
                    BoxShadow(
                      color:      primary.withValues(alpha: .25),
                      blurRadius: 8, offset: const Offset(0, 3),
                    ),
                  ] : null,
                ),
                child: Text(labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   13.5,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color:      active ? Colors.white : inactC,
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
  const _EnCoursTab({required this.isDark, required this.primary});
  final bool  isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Icône gradient
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: .20),
                  primary.withValues(alpha: .06),
                ],
              ),
              shape:  BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: .18), width: 1.5),
            ),
            child: Icon(Icons.directions_bike_rounded, color: primary, size: 40),
          ),
          const SizedBox(height: 22),
          Text("Aucune activité en cours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleC),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            "Vos courses et livraisons en cours s'afficheront ici en temps réel.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: subC, height: 1.55),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color:        primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:      primary.withValues(alpha: .30),
                  blurRadius: 14, offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text("Commander une course",
                  style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Tab "Historique" ────────────────────────────────────────────
class _HistoriqueTab extends StatelessWidget {
  const _HistoriqueTab(
      {required this.isDark, required this.primary, required this.controller});
  final bool              isDark;
  final Color             primary;
  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    final subC   = isDark ? AppColors.textDarkSub  : AppColors.textLightSub;
    final border = isDark ? AppColors.borderDark   : AppColors.borderLight;

    return Column(children: [
      // Sous-onglets
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Obx(() => Row(children: [
          _SubTab(
            label:   "Mes Courses",
            icon:    Icons.sports_motorsports_rounded,
            count:   controller.trips.length,
            active:  controller.histTabIndex.value == 0,
            isDark:  isDark, primary: primary,
            onTap:   () => controller.histTabIndex.value = 0,
          ),
          const SizedBox(width: 10),
          _SubTab(
            label:   "Livraisons",
            icon:    Icons.inventory_2_rounded,
            count:   controller.deliveries.length,
            active:  controller.histTabIndex.value == 1,
            isDark:  isDark, primary: primary,
            onTap:   () => controller.histTabIndex.value = 1,
          ),
        ])),
      ),

      Expanded(
        child: Obx(() {
          final grouped = controller.histTabIndex.value == 0
              ? controller.groupedTrips
              : controller.groupedDeliveries;

          if (grouped.isEmpty) {
            return Center(child: Text("Aucune entrée",
                style: TextStyle(color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted)));
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
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(date,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)),
                      const Spacer(),
                      Text("${items.length} entrée${items.length > 1 ? 's' : ''}",
                          style: TextStyle(fontSize: 11.5, color: subC)),
                    ]),
                  ),
                  ...items.map((h) => _HistoryTile(
                    item:    h,
                    isDark:  isDark,
                    primary: primary,
                    onTap:   () => Get.to(() => _HistoryDetailPage(item: h)),
                  )),
                  Divider(height: 1, color: border, indent: 16, endIndent: 16),
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
    required this.active, required this.isDark, required this.primary,
    required this.onTap,
  });
  final String   label;
  final IconData icon;
  final int      count;
  final bool     active, isDark;
  final Color    primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg     = active ? primary : (isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface);
    final textC  = active ? Colors.white : (isDark ? AppColors.textDarkSub : AppColors.textLightSub);
    final border = active ? primary : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: active ? [
            BoxShadow(color: primary.withValues(alpha: .22), blurRadius: 8, offset: const Offset(0, 3)),
          ] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: textC),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textC)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color:        (active ? Colors.white : primary).withValues(alpha: active ? .22 : .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("$count",
                style: TextStyle(
                    fontSize: 10.5, fontWeight: FontWeight.w800,
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
      {required this.item, required this.isDark, required this.primary, required this.onTap});
  final HistoryModel item;
  final bool         isDark;
  final Color        primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? AppColors.bgDark : Colors.white;
    final titleC  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC    = isDark ? AppColors.textDarkMuted   : AppColors.textLightSub;
    final statusColor = item.status == HistoryStatus.completed ? AppColors.success
        : item.status == HistoryStatus.cancelled ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "Terminé"
        : item.status == HistoryStatus.cancelled ? "Annulé" : "En cours";
    final isTrip = item.type == HistoryType.trip;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          // Avatar service
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color:  primary.withValues(alpha: .10),
              shape:  BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: .18)),
            ),
            child: Icon(
              isTrip ? Icons.sports_motorsports_rounded : Icons.inventory_2_rounded,
              color: primary, size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(item.courierName,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleC),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              // Prix
              Text(item.formattedPrice,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primary)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text("${item.formattedDate} · ${item.id}",
                  style: TextStyle(fontSize: 11, color: subC)),
              const Spacer(),
              // Statut pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:        statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ]),
            const SizedBox(height: 7),
            // Trajet
            _RouteRow(
              departure: item.title.split(" → ")[0],
              arrival:   item.title.split(" → ").length > 1 ? item.title.split(" → ")[1] : '',
              isDark:    isDark,
            ),
          ])),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
        ]),
      ),
    );
  }
}

// ── Affichage trajet compact ────────────────────────────────────
class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.departure, required this.arrival, required this.isDark});
  final String departure, arrival;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    final textC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    return Row(children: [
      Container(width: 7, height: 7,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Flexible(child: Text(departure,
          style: TextStyle(fontSize: 11.5, color: textC, fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(Icons.arrow_forward_rounded, size: 11, color: textC),
      ),
      Container(width: 7, height: 7,
          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Flexible(child: Text(arrival,
          style: TextStyle(fontSize: 11.5, color: textC, fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}

// ── Page de détail ──────────────────────────────────────────────
class _HistoryDetailPage extends StatelessWidget {
  const _HistoryDetailPage({required this.item});
  final HistoryModel item;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.bgDark : Colors.white;
    final cardBg    = isDark ? AppColors.bgDarkSurface : const Color(0xFFF8F9FA);
    final border    = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC    = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC      = isDark ? AppColors.textDarkSub  : AppColors.textLightSub;
    final primary   = isDark ? AppColors.primaryBlue  : AppColors.primaryGreen;

    final statusColor = item.status == HistoryStatus.completed ? AppColors.success
        : item.status == HistoryStatus.cancelled ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "Terminé"
        : item.status == HistoryStatus.cancelled ? "Annulé" : "En cours";
    final typeLabel   = item.type == HistoryType.trip ? "Course" : "Livraison";

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          // ── AppBar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color:        isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: border),
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: titleC, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("$typeLabel · ${item.id}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleC)),
                Text(item.groupDate,
                    style: TextStyle(fontSize: 12, color: subC)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:        statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const SizedBox(height: 4),

                // ── Coursier ──────────────────────────────
                _DetailCard(cardBg: cardBg, border: border, child: Row(children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color:  primary.withValues(alpha: .12), shape: BoxShape.circle,
                      border: Border.all(color: primary.withValues(alpha: .22)),
                    ),
                    child: Icon(Icons.person_rounded, color: primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.courierName,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleC)),
                    const SizedBox(height: 3),
                    Text(item.courierVehicle,
                        style: TextStyle(fontSize: 12.5, color: subC)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.warning.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text("${item.courierRating}",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.warning)),
                      ]),
                    ),
                  ])),
                ])),
                const SizedBox(height: 12),

                // ── Trajet ────────────────────────────────
                _DetailCard(cardBg: cardBg, border: border, child: Column(children: [
                  _DetailRouteRow(dot: AppColors.success, label: item.title.split(" → ")[0], titleC: titleC),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(width: 2, height: 18, color: border),
                  ),
                  _DetailRouteRow(
                    dot: AppColors.error,
                    label: item.title.split(" → ").length > 1 ? item.title.split(" → ")[1] : '',
                    titleC: titleC,
                  ),
                  Divider(height: 20, color: border),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Prix total", style: TextStyle(fontSize: 13, color: subC)),
                    Text(item.formattedPrice,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: primary)),
                  ]),
                ])),
                const SizedBox(height: 12),

                // ── Annulation ────────────────────────────
                if (item.status == HistoryStatus.cancelled)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        AppColors.errorFill,
                      borderRadius: BorderRadius.circular(16),
                      border:       Border.all(color: AppColors.error.withValues(alpha: .22)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
                      SizedBox(width: 10),
                      Text("Annulée · par l'utilisateur",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ]),
                  ),
                const SizedBox(height: 20),

                // ── Support ───────────────────────────────
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: titleC,
                      side:            BorderSide(color: border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {},
                    icon:  const Icon(Icons.headset_mic_outlined, size: 18),
                    label: const Text("Un problème ? Contacter le support",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
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
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: border),
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
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Expanded(child: Text(label,
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: titleC),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}
