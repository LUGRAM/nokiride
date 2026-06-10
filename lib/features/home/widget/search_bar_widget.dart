import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onSearchTap,
    this.onScheduleTap,
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onScheduleTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg      = isDark ? AppColors.bgDarkSurface   : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark       : AppColors.borderLight;
    final hintC   = isDark ? AppColors.textDarkMuted    : AppColors.textLightMuted;
    final dotC    = AppColors.emeraldPrimary;
    final schedFg = AppColors.emeraldPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: GestureDetector(
        onTap: onSearchTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1.5),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.magnifyingGlass, color: dotC, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'where_to'.tr,
                  style: TextStyle(
                    color: hintC,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                height: 32,
                width: 1.5,
                color: border,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              GestureDetector(
                onTap: onScheduleTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.solidClock,
                      size: 16,
                      color: schedFg,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'now'.tr,
                      style: TextStyle(
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FaIcon(FontAwesomeIcons.chevronDown, size: 12, color: hintC),
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

// ─── Dot animé — indique la position GPS ───────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scale   = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width:  10,
            height: 10,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
