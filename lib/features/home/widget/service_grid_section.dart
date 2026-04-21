import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

// ─── Modèle d'un service ───────────────────────────────────
class _ServiceItem {
  final String     id;
  final String     label;
  final String     sublabel;
  final IconData   icon;
  final Color      color;
  final bool       isNew;

  const _ServiceItem({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    this.isNew = false,
  });
}

const _services = [
  _ServiceItem(
    id:       'moto',
    label:    'Moto-Taxi',
    sublabel: 'Course rapide',
    icon:     Icons.sports_motorsports_rounded,
    color:    AppColors.serviceMoto,
  ),
  _ServiceItem(
    id:       'envoi',
    label:    'Envoi colis',
    sublabel: 'A → B sans vous',
    icon:     Icons.inventory_2_rounded,
    color:    AppColors.serviceEnvoi,
  ),
  _ServiceItem(
    id:       'market',
    label:    'Market',
    sublabel: 'Courses livrées',
    icon:     Icons.shopping_bag_rounded,
    color:    AppColors.serviceMarket,
    isNew:    true,
  ),
  _ServiceItem(
    id:       'plan',
    label:    'Planifier',
    sublabel: 'Réservation avancée',
    icon:     Icons.event_available_rounded,
    color:    AppColors.servicePlan,
  ),
];

// ─── Widget principal ──────────────────────────────────────
class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({
    super.key,
    this.onServiceTap,
  });

  /// Callback avec l'id du service tapé : 'moto' | 'envoi' | 'market' | 'plan'
  final ValueChanged<String>? onServiceTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            itemCount:  _services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              mainAxisSpacing:  10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, i) => _ServiceCard(
              item:  _services[i],
              onTap: () => onServiceTap?.call(_services[i].id),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Label de section ─────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      'NOS SERVICES',
      style: TextStyle(
        fontSize:      11,
        fontWeight:    FontWeight.w700,
        letterSpacing: .07,
        color: isDark
            ? AppColors.textDarkMuted
            : AppColors.textLightMuted,
      ),
    );
  }
}

// ─── Card individuelle ────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, this.onTap});

  final _ServiceItem  item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg     = isDark
        ? Color.alphaBlend(item.color.withOpacity(.10), AppColors.bgDarkSurface)
        : item.color.withOpacity(.07);
    final border = isDark
        ? item.color.withOpacity(.18)
        : item.color.withOpacity(.20);
    final iconBg = item.color.withOpacity(.14);
    final labelC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor:  item.color.withOpacity(.10),
        child: Ink(
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: border, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width:  42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:        iconBg,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size:  20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w800,
                      color:      labelC,
                      letterSpacing: -.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.sublabel,
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w500,
                      color:      subC,
                    ),
                  ),
                ],
              ),
              if (item.isNew)
                Positioned(
                  top:   0,
                  right: 0,
                  child: _NewBadge(color: item.color),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Badge "NEW" ──────────────────────────────────────────
class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color:      Colors.white,
          fontSize:   9,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}