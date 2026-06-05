import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/app_colors.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  static final _activities = [
    const _ActivityData(
      title:       'Akanda → Charbonnages',
      serviceType: 'Moto-Taxi',
      datetime:    "Aujourd'hui · 16:42",
      price:       '1 500 F',
      icon:        FontAwesomeIcons.motorcycle,
      statusIcon:  FontAwesomeIcons.solidCircleCheck,
      statusColor: AppColors.success,
    ),
    const _ActivityData(
      title:       'Batterie IV → Louis',
      serviceType: 'Envoi colis',
      datetime:    'Hier · 09:15',
      price:       '850 F',
      icon:        FontAwesomeIcons.boxOpen,
      statusIcon:  FontAwesomeIcons.solidClock,
      statusColor: AppColors.warning,
    ),
    const _ActivityData(
      title:       'Nzeng-Ayong → Glass',
      serviceType: 'Moto-Taxi',
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
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final primary = isDark ? AppColors.neonYellow : AppColors.emeraldPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Activité récente",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleC,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Voir tout",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: data.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: FaIcon(data.icon, color: data.statusColor, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: titleC,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.datetime,
                        style: TextStyle(fontSize: 12, color: subC, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.price,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: titleC,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FaIcon(data.statusIcon, color: data.statusColor, size: 14),
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
