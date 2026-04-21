import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    this.onSeeAll,
  });

  final VoidCallback? onSeeAll;

  static const _activities = [
    _ActivityItemData(
      title:     'Akanda → Charbonnages',
      subtitle:  'Moto-Taxi • Aujourd\'hui, 16:42',
      icon:      Icons.check_circle_rounded,
      iconColor: AppColors.success,
    ),
    _ActivityItemData(
      title:     'Batterie IV → Louis',
      subtitle:  'Envoi colis • Hier, 09:15',
      icon:      Icons.schedule_rounded,
      iconColor: AppColors.warning,
    ),
    _ActivityItemData(
      title:     'Nzeng-Ayong → Glass',
      subtitle:  'Moto-Taxi • 12 avr.',
      icon:      Icons.close_rounded,
      iconColor: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final titleC  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final seeAllC = isDark ? AppColors.primaryBlueLight : AppColors.primaryGreenDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Activité récente',
                style: TextStyle(
                  fontSize:   17,
                  fontWeight: FontWeight.w700,
                  color:      titleC,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      seeAllC,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._activities.map(
                (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(data: a, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.data, required this.isDark});

  final _ActivityItemData data;
  final bool              isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg  = isDark ? AppColors.bgDarkSurface   : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark       : AppColors.borderLight;
    final titleC  = isDark ? AppColors.textDarkPrimary  : AppColors.textLightPrimary;
    final subC    = isDark ? AppColors.textDarkMuted     : AppColors.textLightSub;
    final chevron = isDark
        ? AppColors.textDarkMuted
        : AppColors.textLightMuted;

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap:        () {},
        borderRadius: BorderRadius.circular(18),
        splashColor:  data.iconColor.withOpacity(.08),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color:        cardBg,
            borderRadius: BorderRadius.circular(18),
            border:       Border.all(color: border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width:  44,
                height: 44,
                decoration: BoxDecoration(
                  color:        data.iconColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w700,
                        color:      titleC,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        fontSize:   12,
                        fontWeight: FontWeight.w500,
                        color:      subC,
                        height:     1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: chevron, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _ActivityItemData {
  final String   title;
  final String   subtitle;
  final IconData icon;
  final Color    iconColor;

  const _ActivityItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}