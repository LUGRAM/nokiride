import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';

class _ServiceItem {
  final String   id;
  final String   labelKey;
  final String   sublabelKey;
  final String   emoji;
  final IconData icon;
  final Color    color;
  final bool     isNew;
  final bool     isFeatured;

  const _ServiceItem({
    required this.id,
    required this.labelKey,
    required this.sublabelKey,
    required this.emoji,
    required this.icon,
    required this.color,
    this.isNew      = false,
    this.isFeatured = false,
  });
}

final _services = [
  const _ServiceItem(
    id: 'moto', labelKey: 'moto_taxi', sublabelKey: 'moto_sub',
    emoji: '🏍️', icon: FontAwesomeIcons.motorcycle,
    color: AppColors.serviceMoto, isFeatured: true,
  ),
  const _ServiceItem(
    id: 'envoi', labelKey: 'delivery', sublabelKey: 'delivery_sub',
    emoji: '📦', icon: FontAwesomeIcons.boxOpen,
    color: AppColors.serviceEnvoi, isFeatured: true,
  ),
  const _ServiceItem(
    id: 'market', labelKey: 'market', sublabelKey: 'market_sub',
    emoji: '🛒', icon: FontAwesomeIcons.basketShopping,
    color: AppColors.serviceMarket, isNew: true,
  ),
  const _ServiceItem(
    id: 'plan', labelKey: 'schedule', sublabelKey: 'schedule_sub',
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'our_services'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.textSub(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.85,
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
    final bg = AppColors.surface(context);
    final border = AppColors.divider(context);
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);
    final accent = AppColors.accent(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    item.icon,
                    color: accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.labelKey.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: titleC,
                        ),
                      ),
                      Text(
                        item.sublabelKey.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: subC,
                        ),
                      ),
                    ],
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
