import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  static const _activities = [
    _ActivityData(
      title:       'Akanda → Charbonnages',
      serviceType: 'Moto-Taxi',
      datetime:    "Aujourd'hui · 16:42",
      price:       '1 500 F',
      icon:        Icons.sports_motorsports_rounded,
      statusIcon:  Icons.check_circle_rounded,
      statusColor: AppColors.success,
    ),
    _ActivityData(
      title:       'Batterie IV → Louis',
      serviceType: 'Envoi colis',
      datetime:    'Hier · 09:15',
      price:       '850 F',
      icon:        Icons.inventory_2_rounded,
      statusIcon:  Icons.schedule_rounded,
      statusColor: AppColors.warning,
    ),
    _ActivityData(
      title:       'Nzeng-Ayong → Glass',
      serviceType: 'Moto-Taxi',
      datetime:    '12 avr. · 14:30',
      price:       '2 000 F',
      icon:        Icons.sports_motorsports_rounded,
      statusIcon:  Icons.cancel_rounded,
      statusColor: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final titleC  = isDark ? AppColors.textDarkPrimary  : AppColors.textLightPrimary;
    final primary = isDark ? AppColors.primaryBlueLight  : AppColors.primaryGreenDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(children: [
          Text("Activité récente",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: titleC)),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: Text("Voir tout",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
          ),
        ]),
        const SizedBox(height: 12),
        ..._activities.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _ActivityTile(data: a, isDark: isDark),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.data, required this.isDark});
  final _ActivityData data;
  final bool          isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg  = isDark ? AppColors.bgDarkSurface  : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark      : AppColors.borderLight;
    final titleC  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC    = isDark ? AppColors.textDarkMuted   : AppColors.textLightSub;

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap:        () {},
        borderRadius: BorderRadius.circular(18),
        splashColor:  data.statusColor.withValues(alpha: .07),
        child: Ink(
          decoration: BoxDecoration(
            color:        cardBg,
            borderRadius: BorderRadius.circular(18),
            border:       Border.all(color: border),
          ),
          padding: const EdgeInsets.all(13),
          child: Row(children: [
            // Icône service
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:        data.statusColor.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(data.icon, color: data.statusColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Infos trajet
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.title,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleC),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color:        data.statusColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(data.serviceType,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: data.statusColor)),
                ),
                const SizedBox(width: 6),
                Text(data.datetime,
                  style: TextStyle(fontSize: 11, color: subC)),
              ]),
            ])),
            const SizedBox(width: 10),

            // Prix + statut
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(data.price,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: titleC)),
              const SizedBox(height: 4),
              Icon(data.statusIcon, color: data.statusColor, size: 16),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
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
