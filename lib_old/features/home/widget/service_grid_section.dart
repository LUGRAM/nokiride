import 'package:flutter/material.dart';
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

const _services = [
  _ServiceItem(
    id: 'moto', label: 'Moto-Taxi', sublabel: 'Course rapide',
    emoji: '🏍️', icon: Icons.sports_motorsports_rounded,
    color: AppColors.serviceMoto, isFeatured: true,
  ),
  _ServiceItem(
    id: 'envoi', label: 'Envoi colis', sublabel: 'A → B sans vous',
    emoji: '📦', icon: Icons.inventory_2_rounded,
    color: AppColors.serviceEnvoi, isFeatured: true,
  ),
  _ServiceItem(
    id: 'market', label: 'Market', sublabel: 'Courses livrées',
    emoji: '🛒', icon: Icons.shopping_bag_rounded,
    color: AppColors.serviceMarket, isNew: true,
  ),
  _ServiceItem(
    id: 'plan', label: 'Planifier', sublabel: 'Résa. avancée',
    emoji: '📅', icon: Icons.event_available_rounded,
    color: AppColors.servicePlan,
  ),
];

class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({super.key, this.onServiceTap});
  final ValueChanged<String>? onServiceTap;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final featured  = _services.where((s) => s.isFeatured).toList();
    final secondary = _services.where((s) => !s.isFeatured).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nos services',
            style: TextStyle(
              fontSize:   17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // ── Row 1 : Featured — emoji AU-DESSUS externe ───
          // Stack alloue overflow(28) + cardHeight(96) = 124px
          SizedBox(
            height: 124,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: featured.map((item) {
                final isLast = item == featured.last;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 10),
                    child: _FeaturedCard(
                      item:   item,
                      isDark: isDark,
                      onTap:  () => onServiceTap?.call(item.id),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // ── Row 2 : Secondary — emoji À GAUCHE interne ───
          Row(
            children: secondary.map((item) {
              final isLast = item == secondary.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 10),
                  child: _SecondaryCard(
                    item:   item,
                    isDark: isDark,
                    onTap:  () => onServiceTap?.call(item.id),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Row 1 — Grande card : emoji AU-DESSUS (externe, centré)
//
//          [🏍️]          ← emoji externe, centré horizontalement
//   ┌──────────────┐
//   │   Moto-Taxi  │
//   │  Course rap. │
//   └──────────────┘
// ─────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item, required this.isDark, this.onTap});

  final _ServiceItem  item;
  final bool          isDark;
  final VoidCallback? onTap;

  static const double _emojiContainerSize = 52;
  static const double _emojiOverlap       = 20; // part qui chevauche la card
  static const double _cardHeight         = 96;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark
        ? Color.alphaBlend(item.color.withOpacity(.13), AppColors.bgDarkSurface)
        : item.color.withOpacity(.08);
    final border = item.color.withOpacity(isDark ? .22 : .18);
    final labelC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    // Hauteur totale = partie emoji externe + card
    // emoji externe = _emojiContainerSize - _emojiOverlap
    final emojiExternal = _emojiContainerSize - _emojiOverlap;

    return Stack(
      clipBehavior: Clip.none,
      alignment:    Alignment.topCenter,
      children: [

        // ── Card — ancrée en bas du Stack ─────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: _cardHeight,
          child: Material(
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
                // Padding top laisse la place au chevauchement emoji
                padding: EdgeInsets.fromLTRB(
                  12, _emojiOverlap + 4, 12, 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment:  MainAxisAlignment.end,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow:  TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:      13.5,
                        fontWeight:    FontWeight.w800,
                        color:         labelC,
                        letterSpacing: -.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.sublabel,
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:   11,
                        fontWeight: FontWeight.w500,
                        color:      subC,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Emoji — centré horizontalement, au-dessus ──────
        // top: 0 dans le Stack = juste au-dessus de la card
        Positioned(
          top: 0,
          child: Container(
            width:  _emojiContainerSize,
            height: _emojiContainerSize,
            decoration: BoxDecoration(
              color:  isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface,
              shape:  BoxShape.circle,
              border: Border.all(color: border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color:      item.color.withOpacity(.18),
                  blurRadius: 10,
                  offset:     const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Row 2 — Petite card : emoji À GAUCHE (interne)
//
//   ┌──────────────────────────────┐
//   │  [🛒]  Market          NEW  │
//   │        Courses livrées       │
//   └──────────────────────────────┘
// ─────────────────────────────────────────────────────────────
class _SecondaryCard extends StatelessWidget {
  const _SecondaryCard({required this.item, required this.isDark, this.onTap});

  final _ServiceItem  item;
  final bool          isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark
        ? Color.alphaBlend(item.color.withOpacity(.10), AppColors.bgDarkSurface)
        : item.color.withOpacity(.07);
    final border = item.color.withOpacity(isDark ? .18 : .16);
    final iconBg = item.color.withOpacity(.14);
    final labelC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor:  item.color.withOpacity(.10),
        child: Ink(
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(18),
            border:       Border.all(color: border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Emoji dans container carré arrondi
              Container(
                width:  40,
                height: 40,
                decoration: BoxDecoration(
                  color:        iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),

              // Label + sublabel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:       MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w700,
                              color:      labelC,
                              height:     1.1,
                            ),
                          ),
                        ),
                        if (item.isNew) ...[
                          const SizedBox(width: 5),
                          _NewBadge(color: item.color),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.sublabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color:    subC,
                        height:   1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color:         Colors.white,
          fontSize:      7.5,
          fontWeight:    FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }
}