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
    _frames = widget.frames ?? [];
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

    if (_frames.isEmpty) return const SizedBox.shrink();

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
    // Dark  : accent teinté sur fond sombre
    // Light : blanc avec légère teinte accent — PLUS lisible
    final bgBase = isDark
        ? Color.alphaBlend(frame.accentColor.withOpacity(.13), AppColors.bgDarkSurface)
        : Colors.white;
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
                    _ImagePanel(frame: frame, isDark: isDark)
                  else
                    _IconPanel(frame: frame),

                  // Dégradé — opacité adaptée au thème
                  if (frame.hasImage)
                    _GradientOverlay(color: bgBase, isDark: isDark),

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
// Image
// ─────────────────────────────────────────────────────────────
class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.frame, required this.isDark});

  final PromoFrame frame;
  final bool       isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right:  0,
      top:    0,
      bottom: 0,
      width:  175,
      child: _resolveImage(),
    );
  }

  Widget _resolveImage() {
    if (frame.imageAsset != null) {
      return Image(
        image:     AssetImage(frame.imageAsset!),
        fit:       BoxFit.cover,
        alignment: Alignment.centerRight,
        errorBuilder: (_, __, ___) =>
        frame.imageUrl != null ? _networkImage() : _IconPanel(frame: frame),
      );
    }
    if (frame.imageUrl != null) return _networkImage();
    return _IconPanel(frame: frame);
  }

  Widget _networkImage() {
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
// Dégradé — opacité forte en light pour protéger le texte
// ─────────────────────────────────────────────────────────────
class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({required this.color, required this.isDark});

  final Color color;
  final bool  isDark;

  @override
  Widget build(BuildContext context) {
    // Light : dégradé blanc très opaque → transparent
    // Dark  : dégradé couleur accent → transparent
    final opaqueColor  = isDark ? color            : Colors.white;
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
  const _TextContent({required this.frame, required this.isDark});

  final PromoFrame frame;
  final bool       isDark;

  @override
  Widget build(BuildContext context) {
    // Light : textes sombres sur fond blanc
    final titleC = isDark ? AppColors.textDarkPrimary  : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub      : AppColors.textLightSub;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:  MainAxisAlignment.start,
      children: [
        // Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color:        frame.accentColor.withOpacity(.18),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            frame.tag,
            style: TextStyle(
              fontSize:      9,
              fontWeight:    FontWeight.w800,
              color:         frame.accentColor,
              letterSpacing: .5,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Titre
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

        // Sous-titre
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

        // CTA
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
// Dots
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