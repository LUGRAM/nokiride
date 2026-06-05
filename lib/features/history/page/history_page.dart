import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
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
    final primary    = AppColors.emeraldPrimary;

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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.8)),
                const SizedBox(height: 4),
                Text("${controller.trips.length} courses · ${controller.deliveries.length} livraisons",
                    style: TextStyle(fontSize: 13, color: subC, fontWeight: FontWeight.w600)),
              ]),
              const Spacer(),
              _HeaderActionBtn(icon: FontAwesomeIcons.sliders, isDark: isDark),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Tabs pill toggle ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => _PillTabs(
              selected: controller.mainTabIndex.value,
              onTap:    (i) => controller.mainTabIndex.value = i,
              isDark:   isDark,
              primary:  primary,
            )),
          ),
          const SizedBox(height: 16),

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

class _HeaderActionBtn extends StatelessWidget {
  const _HeaderActionBtn({required this.icon, required this.isDark});
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(child: FaIcon(icon, color: AppColors.emeraldPrimary, size: 16)),
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
    final bg      = isDark ? AppColors.bgDarkSurface : Colors.white;
    final border  = isDark ? AppColors.borderDark    : AppColors.borderLight;
    final inactC  = isDark ? AppColors.textDarkSub   : AppColors.textLightSub;
    final labels  = ['En cours', 'Historique'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.5),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:        active ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
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
  const _EnCoursTab({required this.isDark, required this.primary});
  final bool  isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.15), width: 2),
            ),
            child: Center(child: FaIcon(FontAwesomeIcons.motorcycle, color: primary, size: 40)),
          ),
          const SizedBox(height: 28),
          Text("Aucune activité en cours",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: titleC, letterSpacing: -0.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            "Vos courses et livraisons en cours s'afficheront ici en temps réel.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: subC, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => Get.toNamed(Routes.trip),
              icon: const FaIcon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
              label: const Text("Commander une course",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Obx(() => Row(children: [
          _SubTab(
            label:   "Mes Courses",
            icon:    FontAwesomeIcons.motorcycle,
            count:   controller.trips.length,
            active:  controller.histTabIndex.value == 0,
            isDark:  isDark, primary: primary,
            onTap:   () => controller.histTabIndex.value = 0,
          ),
          const SizedBox(width: 12),
          _SubTab(
            label:   "Livraisons",
            icon:    FontAwesomeIcons.boxOpen,
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
                style: TextStyle(color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted, fontWeight: FontWeight.w600)));
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
                        decoration: BoxDecoration(color: AppColors.neonYellow, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(date,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              letterSpacing: -0.2)),
                      const Spacer(),
                      Text("${items.length} entrée${items.length > 1 ? 's' : ''}",
                          style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  ...items.map((h) => _HistoryTile(
                    item:    h,
                    isDark:  isDark,
                    primary: primary,
                    onTap:   () => Get.to(() => _HistoryDetailPage(item: h)),
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
    final bg     = active ? primary : (isDark ? AppColors.bgDarkSurface : Colors.white);
    final textC  = active ? Colors.white : (isDark ? AppColors.textDarkSub : AppColors.textLightSub);
    final border = active ? primary : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
          boxShadow: active ? [
            BoxShadow(color: primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
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
              color:        (active ? Colors.white : primary).withOpacity(active ? 0.2 : 0.1),
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
      {required this.item, required this.isDark, required this.primary, required this.onTap});
  final HistoryModel item;
  final bool         isDark;
  final Color        primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? AppColors.bgDarkSurface : Colors.white;
    final border  = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC    = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;
    final statusColor = item.status == HistoryStatus.completed ? AppColors.success
        : item.status == HistoryStatus.cancelled ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "TERMINÉ"
        : item.status == HistoryStatus.cancelled ? "ANNULÉ" : "EN COURS";
    final isTrip = item.type == HistoryType.trip;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.5),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color:  primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: FaIcon(
                      isTrip ? FontAwesomeIcons.motorcycle : FontAwesomeIcons.boxOpen,
                      color: primary, size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        color: statusColor.withOpacity(0.1),
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
                    isDark:    isDark,
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
  const _RouteRow({required this.departure, required this.arrival, required this.isDark});
  final String departure, arrival;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    final textC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    return Row(children: [
      Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Flexible(child: Text(departure,
          style: TextStyle(fontSize: 12, color: textC, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FaIcon(FontAwesomeIcons.arrowRight, size: 10, color: textC.withOpacity(0.5)),
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

// ── Page de détail ──────────────────────────────────────────────
class _HistoryDetailPage extends StatelessWidget {
  const _HistoryDetailPage({required this.item});
  final HistoryModel item;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg    = isDark ? AppColors.bgDarkSurface : Colors.white;
    final border    = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC    = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC      = isDark ? AppColors.textDarkSub  : AppColors.textLightSub;
    final primary   = AppColors.emeraldPrimary;

    final statusColor = item.status == HistoryStatus.completed ? AppColors.success
        : item.status == HistoryStatus.cancelled ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "TERMINÉ"
        : item.status == HistoryStatus.cancelled ? "ANNULÉ" : "EN COURS";
    final typeLabel   = item.type == HistoryType.trip ? "Course" : "Livraison";

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
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color:        cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border:       Border.all(color: border, width: 1.5),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:        statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
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
                _DetailCard(cardBg: cardBg, border: border, isDark: isDark, child: Row(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color:  primary.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(child: FaIcon(FontAwesomeIcons.userLarge, color: primary, size: 24)),
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
                        color:        AppColors.neonYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        FaIcon(FontAwesomeIcons.solidStar, color: isDark ? AppColors.neonYellow : AppColors.warning, size: 10),
                        const SizedBox(width: 6),
                        Text("${item.courierRating}",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? AppColors.neonYellow : AppColors.darkGreenBase)),
                      ]),
                    ),
                  ])),
                ])),
                const SizedBox(height: 16),

                // ── Trajet ────────────────────────────────
                _DetailCard(cardBg: cardBg, border: border, isDark: isDark, child: Column(children: [
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
                      color: isDark ? AppColors.bgDarkElevated : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("PRIX TOTAL", style: TextStyle(fontSize: 11, color: subC, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
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
                      color:        AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(color: AppColors.error.withOpacity(0.2), width: 1.5),
                    ),
                    child: Row(children: [
                      FaIcon(FontAwesomeIcons.circleXmark, color: AppColors.error, size: 18),
                      const SizedBox(width: 12),
                      const Text("ANNULÉE PAR L'UTILISATEUR",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.error, letterSpacing: 0.5)),
                    ]),
                  ),
                const SizedBox(height: 24),

                // ── Support ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: titleC,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side:            BorderSide(color: border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {},
                    icon:  const FaIcon(FontAwesomeIcons.headset, size: 16),
                    label: const Text("Aide & Support",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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
  const _DetailCard({required this.cardBg, required this.border, required this.isDark, required this.child});
  final Color  cardBg, border;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: BorderRadius.circular(28),
        border:       Border.all(color: border, width: 1.5),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 6)),
        ],
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
      const SizedBox(width: 14),
      Expanded(child: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleC),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}
