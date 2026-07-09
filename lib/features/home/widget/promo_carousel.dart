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
    _frames = widget.frames ?? _defaultFrames;
    _ctrl   = PageController(viewportFraction: 1.0);
    _startAutoPlay();
  }

  static final List<PromoFrame> _defaultFrames = [
    const PromoFrame(
      tag: 'OFFRE SPÉCIALE',
      title: 'Votre 1ère course à -50%',
      subtitle: 'Profitez de notre offre de bienvenue dès maintenant !',
      cta: 'En profiter',
      accentColor: AppColors.accentDark,
      icon: Icons.local_offer_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=800',
    ),
    const PromoFrame(
      tag: 'NOUVEAUTÉ',
      title: 'Livraison express disponible',
      subtitle: 'Envoyez vos colis en un clin d\'œil avec NokiRide.',
      cta: 'Essayer',
      accentColor: AppColors.serviceEnvoi,
      icon: Icons.delivery_dining_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=800',
    ),
    const PromoFrame(
      tag: 'NOUVEAUTÉ',
      title: 'Faites vos courses en ligne',
      subtitle: 'Le marché Noki est désormais disponible à Libreville.',
      cta: 'Découvrir',
      accentColor: AppColors.serviceMarket,
      icon: Icons.shopping_basket_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=800',
    ),
    const PromoFrame(
      tag: 'FIDÉLITÉ',
      title: 'Gagnez des réductions',
      subtitle: 'Parrainez vos proches et gagnez des courses gratuites.',
      cta: 'Parrainer',
      accentColor: AppColors.accentDark,
      icon: Icons.card_giftcard_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=800',
    ),
  ];

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
    if (_frames.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
              ),
            ),
          ),
          const SizedBox(height: 10),
          _DotsIndicator(
            count:       _frames.length,
            current:     _current,
            activeColor: _frames[_current].accentColor,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.frame});

  final PromoFrame frame;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgBase = isDark
        ? Color.alphaBlend(frame.accentColor.withOpacity(.13), AppColors.surface(context))
        : AppColors.surface(context);
    final border = frame.accentColor.withOpacity(.22);

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap:        frame.onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor:  frame.accentColor.withOpacity(.08),
        child: Ink(
          decoration: BoxDecoration(
            color:        bgBase,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: border, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (frame.hasImage)
                  _ImagePanel(frame: frame)
                else
                  _IconPanel(frame: frame),

                if (frame.hasImage)
                  _GradientOverlay(color: bgBase),

                Positioned(
                  left:   18,
                  top:    14,
                  bottom: 14,
                  width:  185,
                  child: _TextContent(frame: frame),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Image
// ─────────────────────────────────────────────────────────────
class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.frame});

  final PromoFrame frame;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right:  0,
      top:    0,
      bottom: 0,
      width:  175,
      child: _resolveImage(context),
    );
  }

  Widget _resolveImage(BuildContext context) {
    if (frame.imageAsset != null) {
      return Image(
        image:     AssetImage(frame.imageAsset!),
        fit:       BoxFit.cover,
        alignment: Alignment.centerRight,
        errorBuilder: (_, __, ___) =>
            frame.imageUrl != null ? _networkImage(context) : _IconPanel(frame: frame),
      );
    }
    if (frame.imageUrl != null) return _networkImage(context);
    return _IconPanel(frame: frame);
  }

  Widget _networkImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base      = isDark
        ? Color.alphaBlend(frame.accentColor.withOpacity(.13), AppColors.surface(context))
        : AppColors.surface(context);
    final highlight = isDark
        ? Color.alphaBlend(Colors.white.withOpacity(.12), base)
        : const Color(0xFFF5F7FA);

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
// Dégradé — opacité forte en light pour protéger le texte
// ─────────────────────────────────────────────────────────────
class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opaqueColor  = isDark ? color : AppColors.surface(context);
    final stops        = isDark
        ? const [0.0, 0.50, 0.72, 1.0]
        : const [0.0, 0.45, 0.68, 1.0];
    final colors = isDark
        ? [opaqueColor, opaqueColor, opaqueColor.withOpacity(.55), Colors.transparent]
        : [opaqueColor, opaqueColor, opaqueColor.withOpacity(.80), Colors.transparent];

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.centerLeft,
            end:    Alignment.centerRight,
            stops:  stops,
            colors: colors,
          ),
        ),
      ),
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
// Texte
// ─────────────────────────────────────────────────────────────
class _TextContent extends StatelessWidget {
  const _TextContent({required this.frame});

  final PromoFrame frame;

  @override
  Widget build(BuildContext context) {
    final titleC = AppColors.textPrimary(context);
    final subC   = AppColors.textSub(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:  MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: frame.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            frame.tag,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: frame.accentColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          frame.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleC,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          frame.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: subC,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: frame.accentColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: frame.accentColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            frame.cta,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dots
// ─────────────────────────────────────────────────────────────
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  final int   count;
  final int   current;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
