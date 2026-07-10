import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../profile/model/profile_stats_model.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    this.onSeeAll,
    this.activities = const [],
  });

  final VoidCallback? onSeeAll;
  final List<ActivitySummary> activities;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subC = AppColors.textSub(context);
    final accent = AppColors.accent(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "recent".tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: subC,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "see_all".tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            _EmptyActivities(isDark: isDark)
          else
            ...activities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ActivityTile(activity: activity, isDark: isDark),
                )),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.isDark});
  final ActivitySummary activity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.surface(context);
    final border = AppColors.divider(context);
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);

    final statusColor = _statusColor(activity.status);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: FaIcon(_typeIcon(activity.type),
                        color: statusColor, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: titleC,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.formattedDate,
                        style: TextStyle(
                            fontSize: 11,
                            color: subC,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      activity.formattedAmount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: titleC,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FaIcon(_statusIcon(activity.status),
                        color: statusColor, size: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    if (type == 'delivery') return FontAwesomeIcons.boxOpen;
    if (type == 'market_order') return FontAwesomeIcons.bagShopping;
    return FontAwesomeIcons.motorcycle;
  }

  IconData _statusIcon(String status) {
    if (['completed', 'delivered'].contains(status)) {
      return FontAwesomeIcons.solidCircleCheck;
    }
    if (status == 'cancelled') return FontAwesomeIcons.solidCircleXmark;
    return FontAwesomeIcons.solidClock;
  }

  Color _statusColor(String status) {
    if (['completed', 'delivered'].contains(status)) return AppColors.success;
    if (status == 'cancelled') return AppColors.error;
    return AppColors.warning;
  }
}

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.surface(context);
    final border = AppColors.divider(context);
    final subC = AppColors.textSub(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        'Aucune activité récente',
        style: TextStyle(
          color: subC,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
