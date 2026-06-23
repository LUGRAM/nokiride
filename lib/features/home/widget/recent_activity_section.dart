import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  static final _activities = [
    _ActivityData(
      title:       'Akanda → Charbonnages',
      serviceType: 'moto_taxi'.tr,
      datetime:    "${'today'.tr} · 16:42",
      price:       '1 500 F',
      icon:        FontAwesomeIcons.motorcycle,
      statusIcon:  FontAwesomeIcons.solidCircleCheck,
      statusColor: AppColors.success,
    ),
    _ActivityData(
      title:       'Batterie IV → Louis',
      serviceType: 'delivery'.tr,
      datetime:    '${'yesterday'.tr} · 09:15',
      price:       '850 F',
      icon:        FontAwesomeIcons.boxOpen,
      statusIcon:  FontAwesomeIcons.solidClock,
      statusColor: AppColors.warning,
    ),
    const _ActivityData(
      title:       'Nzeng-Ayong → Glass',
      serviceType: 'Moto-Taxi', // This one will be Moto-Taxi as it's static const and .tr can't be used
      datetime:    '12 avr. · 14:30',
      price:       '2 000 F',
      icon:        FontAwesomeIcons.motorcycle,
      statusIcon:  FontAwesomeIcons.solidCircleXmark,
      statusColor: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subC = AppColors.textSub(context);
    final accent = AppColors.accent(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
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
          ..._activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActivityTile(data: a, isDark: isDark),
              )),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.data, required this.isDark});
  final _ActivityData data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.surface(context);
    final border = AppColors.divider(context);
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);

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
                    color: data.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: FaIcon(data.icon, color: data.statusColor, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
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
                        data.datetime,
                        style: TextStyle(fontSize: 11, color: subC, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.price,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: titleC,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FaIcon(data.statusIcon, color: data.statusColor, size: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityData {
  final String   title;
  final String   serviceType;
  final String   datetime;
  final String   price;
  final IconData icon;
  final IconData statusIcon;
  final Color    statusColor;

  const _ActivityData({
    required this.title,
    required this.serviceType,
    required this.datetime,
    required this.price,
    required this.icon,
    required this.statusIcon,
    required this.statusColor,
  });
}
