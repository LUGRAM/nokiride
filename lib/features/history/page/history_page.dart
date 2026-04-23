import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/history_controller.dart';
import '../model/history_model.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text("Historique", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: titleC)),
            ),
            // Filtres
            Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(controller.filters.length, (i) {
                  final active = controller.filterIndex.value == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.setFilter(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? primary : (isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? primary : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                        ),
                        child: Text(controller.filters[i], style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: active ? Colors.white : (isDark ? AppColors.textDarkSub : AppColors.textLightSub),
                        )),
                      ),
                    ),
                  );
                }),
              ),
            )),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(() => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _HistoryTile(item: controller.filtered[i], isDark: isDark),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.isDark});
  final HistoryModel item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightSub;

    final iconColor = item.type == HistoryType.trip ? AppColors.serviceMoto : AppColors.serviceEnvoi;
    final statusColor = item.status == HistoryStatus.completed
        ? AppColors.success : item.status == HistoryStatus.cancelled
        ? AppColors.error : AppColors.warning;
    final statusLabel = item.status == HistoryStatus.completed ? "Terminé" : item.status == HistoryStatus.cancelled ? "Annulé" : "En cours";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconColor.withOpacity(.12), borderRadius: BorderRadius.circular(13)),
            child: Icon(item.type == HistoryType.trip ? Icons.sports_motorsports_rounded : Icons.inventory_2_rounded, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleC), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text("${item.subtitle} · ${item.formattedDate}", style: TextStyle(fontSize: 11.5, color: subC)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.formattedPrice, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isDark ? AppColors.primaryBlueLight : AppColors.primaryGreenDark)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(.12), borderRadius: BorderRadius.circular(6)),
                child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
