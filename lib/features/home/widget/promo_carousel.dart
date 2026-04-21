import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// Modèle
// ─────────────────────────────────────────────────────────────
class PromoFrame {
  final String        tag;
  final String        title;
  final String        subtitle;
  final String        cta;
  final Color         accentColor;
  final IconData      icon;
  final String?       imageAsset;
  final String?       imageUrl;
  final VoidCallback? onTap;

  const PromoFrame({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.accentColor,
    required this.icon,
    this.imageAsset,
    this.imageUrl,
    this.onTap,
  });

  bool get hasImage => imageAsset != null || imageUrl != null;
}

// ─────────────────────────────────────────────────────────────
// Frames par défaut
// ─────────────────────────────────────────────────────────────
final defaultPromoFrames = [
  const PromoFrame(
    tag:         'OFFRE',
    title:       '1ère course\nofferte',
    subtitle:    'Code : NOKI2025',
    cta:         'En profiter',
    accentColor: AppColors.primaryBlue,
    icon:        Icons.sports_motorsports_rounded,
    imageAsset:  'assets/images/carousel/promo_moto.png',
    imageUrl:    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
  ),
  const PromoFrame(
    tag:         'NOUVEAU',
    title:       'Market disponible\nà Libreville',
    subtitle:    'Courses livrées en 45 min',
    cta:         'Découvrir',
    accentColor: AppColors.serviceMarket,
    icon:        Icons.shopping_bag_rounded,
    imageAsset:  'assets/images/carousel/promo_market.png',
    imageUrl:    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
  ),
  const PromoFrame(
    tag:         'EXPRESS',
    title:       'Envoi de colis\nsans se déplacer',
    subtitle:    'Tarif fixe dès 500 F CFA',
    cta:         'Envoyer',
    accentColor: AppColors.serviceEnvoi,
    icon:        Icons.inventory_2_rounded,
    imageAsset:  'assets/images/carousel/promo_envoi.png',
    imageUrl:    'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=800&q=80',
  ),
  const PromoFrame(
    tag:         'PARRAINAGE',
    title:       'Invitez un ami\ngagnez 1 000 F',
    subtitle:    'Crédité dès sa 1ère course',
    cta:         'Partager',
    accentColor: AppColors.servicePlan,
    icon:        Icons.card_giftcard_rounded,
    imageAsset:  'assets/images/carousel/promo_parrainage.png',
    imageUrl:    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
  ),
  const PromoFrame(
    tag:         'SÉCURITÉ',
    title:       'Bouton SOS\ntoujours actif',
    subtitle:    'Votre sécurité, notre priorité',
    cta:         'En savoir plus',
    accentColor: AppColors.warning,
    icon:        Icons.shield_rounded,
    imageAsset:  'assets/images/carousel/promo_securite.png',
    imageUrl:    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=800&q=80',
  ),
];

// ─────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    this.frames,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.height           = 176,
  });

  final List<PromoFrame>? frames;
  final Duration          autoPlayDuration;
  final double            height;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController   _ctrl;
  late final List<PromoFrame> _frames;
  Timer? _timer;
  int    _current = 0;

  @override
  void initState() {
    super.initState();
    _frames = widget.frames ?? defaultPromoFrames;
    _ctrl   = PageController(viewportFraction: 0.90);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!mounted || _frames.isEmpty) return;
      _ctrl.animateToPage(
        (_current + 1) % _frames.length,
        duration: const Duration(milliseconds: 500),
        curve:    Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller:    _ctrl,
            itemCount:     _frames.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder:   (_, i) => _PromoCard(
              frame:  _frames[i],
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _DotsIndicator(
          count:       _frames.length,
          current:     _current,
          isDark:      isDark,
          activeColor: _frames[_current].accentColor,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.frame, required this.isDark});

  final PromoFrame frame;
  final bool       isDark;

  @override
  Widget build(BuildContext context) {
    final bgBase = isDark
        ? Color.alphaBlend(frame.accentColor.withOpacity(.13), AppColors.bgDarkSurface)
        : frame.accentColor.withOpacity(.09);
    final border = frame.accentColor.withOpacity(.22);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap:        frame.onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor:  frame.accentColor.withOpacity(.08),
          child: Ink(
            decoration: BoxDecoration(
              color:        bgBase,
              borderRadius: BorderRadius.circular(22),
              border:       Border.all(color: border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image droite ou icône fallback
                  if (frame.hasImage)
                    _ImagePanel(frame: frame, bgColor: bgBase)
                  else
                    _IconPanel(frame: frame),

                  // Dégradé protection texte
                  if (frame.hasImage)
                    _GradientOverlay(color: bgBase),

                  // Textes gauche
                  Positioned(
                    left:   18,
                    top:    14,
                    bottom: 14,
                    width:  185,
                    child: _TextContent(frame: frame, isDark: isDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Image — asset prioritaire, URL en fallback
// ─────────────────────────────────────────────────────────────
class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.frame, required this.bgColor});

  final PromoFrame frame;
  final Color      bgColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right:  0,
      top:    0,
      bottom: 0,
      width:  175,
      child: _resolveImage(isDark),
    );
  }

  Widget _resolveImage(bool isDark) {
    // 1. Asset local prioritaire
    if (frame.imageAsset != null) {
      return Image(
        image:     AssetImage(frame.imageAsset!),
        fit:       BoxFit.cover,
        alignment: Alignment.centerRight,
        errorBuilder: (_, __, ___) =>
        frame.imageUrl != null
            ? _networkImage(isDark)
            : _IconPanel(frame: frame),
      );
    }

    // 2. URL réseau
    if (frame.imageUrl != null) return _networkImage(isDark);

    // 3. Fallback icône
    return _IconPanel(frame: frame);
  }

  Widget _networkImage(bool isDark) {
    final base      = isDark ? const Color(0xFF1C2E42) : const Color(0xFFE8EDF2);
    final highlight = isDark ? const Color(0xFF243650) : const Color(0xFFF5F7FA);

    return CachedNetworkImage(
      imageUrl:        frame.imageUrl!,
      fit:             BoxFit.cover,
      alignment:       Alignment.centerRight,
      fadeInDuration:  const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor:      base,
        highlightColor: highlight,
        period:         const Duration(milliseconds: 1200),
        child: Container(color: base),
      ),
      errorWidget: (_, __, ___) => _IconPanel(frame: frame),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Icône fallback
// ─────────────────────────────────────────────────────────────
class _IconPanel extends StatelessWidget {
  const _IconPanel({required this.frame});

  final PromoFrame frame;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width:  80,
        height: 80,
        decoration: BoxDecoration(
          color:  frame.accentColor.withOpacity(.13),
          shape:  BoxShape.circle,
          border: Border.all(color: frame.accentColor.withOpacity(.22), width: 1),
        ),
        child: Icon(frame.icon, color: frame.accentColor, size: 36),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dégradé protection texte
// ─────────────────────────────────────────────────────────────
class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.centerLeft,
            end:    Alignment.centerRight,
            stops:  const [0.0, 0.50, 0.72, 1.0],
            colors: [
              color,
              color,
              color.withOpacity(.55),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Contenu texte
// ─────────────────────────────────────────────────────────────
class _TextContent extends StatelessWidget {
  const _TextContent({required this.frame, required this.isDark});

  final PromoFrame frame;
  final bool       isDark;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:  MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color:        frame.accentColor.withOpacity(.18),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            frame.tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:      9,
              fontWeight:    FontWeight.w800,
              color:         frame.accentColor,
              letterSpacing: .5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          frame.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize:      16,
            fontWeight:    FontWeight.w800,
            color:         titleC,
            height:        1.12,
            letterSpacing: -.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          frame.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize:   11.5,
            fontWeight: FontWeight.w500,
            color:      subC,
            height:     1.15,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                frame.cta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w700,
                  color:      frame.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.arrow_forward_rounded, size: 12, color: frame.accentColor),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dots indicator
// ─────────────────────────────────────────────────────────────
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.isDark,
    required this.activeColor,
  });

  final int   count;
  final int   current;
  final bool  isDark;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final inactiveC = isDark
        ? Colors.white.withOpacity(.18)
        : Colors.black.withOpacity(.12);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve:    Curves.easeInOut,
          margin:   const EdgeInsets.symmetric(horizontal: 3),
          width:    active ? 22 : 6,
          height:   6,
          decoration: BoxDecoration(
            color:        active ? activeColor : inactiveC,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}