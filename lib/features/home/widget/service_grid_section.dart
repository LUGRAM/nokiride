import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/app_colors.dart';

class _ServiceItem {
  final String   id;
  final String   label;
  final String   sublabel;
  final String   emoji;
  final IconData icon;
  final Color    color;
  final bool     isNew;
  final bool     isFeatured;

  const _ServiceItem({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.emoji,
    required this.icon,
    required this.color,
    this.isNew      = false,
    this.isFeatured = false,
  });
}

final _services = [
  const _ServiceItem(
    id: 'moto', label: 'Moto-Taxi', sublabel: 'Course rapide',
    emoji: '🏍️', icon: FontAwesomeIcons.motorcycle,
    color: AppColors.serviceMoto, isFeatured: true,
  ),
  const _ServiceItem(
    id: 'envoi', label: 'Envoi colis', sublabel: 'A → B sans vous',
    emoji: '📦', icon: FontAwesomeIcons.boxOpen,
    color: AppColors.serviceEnvoi, isFeatured: true,
  ),
  const _ServiceItem(
    id: 'market', label: 'Market', sublabel: 'Courses livrées',
    emoji: '🛒', icon: FontAwesomeIcons.basketShopping,
    color: AppColors.serviceMarket, isNew: true,
  ),
  const _ServiceItem(
    id: 'plan', label: 'Planifier', sublabel: 'Résa. avancée',
    emoji: '📅', icon: FontAwesomeIcons.calendarCheck,
    color: AppColors.servicePlan,
  ),
];

class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({super.key, this.onServiceTap});
  final ValueChanged<String>? onServiceTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nos services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.42,
            ),
            itemBuilder: (context, index) {
              final item = _services[index];
              return _ServiceCard(
                item: item,
                isDark: isDark,
                onTap: () => onServiceTap?.call(item.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.item,
    required this.isDark,
    this.onTap,
  });

  final _ServiceItem item;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: border,
          width: 1.5,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.emeraldPrimary.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldPrimary.withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: FaIcon(
                          item.icon,
                          color: AppColors.emeraldPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    if (item.isNew) _NewBadge(color: AppColors.neonYellow),
                  ],
                ),
                const Spacer(),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleC,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.sublabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subC,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: AppColors.darkGreenBase,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
