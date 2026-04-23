import 'package:flutter/material.dart';
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
    final dotC    = isDark ? AppColors.primaryBlueLight : AppColors.primaryGreen;
    final schedBg = isDark ? AppColors.bgDarkElevated   : AppColors.primaryGreenFill;
    final schedFg = isDark ? AppColors.primaryBlueLight : AppColors.primaryGreenDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: GestureDetector(
        onTap: onSearchTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              _PulsingDot(color: dotC),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chercher une destination...',
                  style: TextStyle(
                    color:      hintC,
                    fontSize:   14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onScheduleTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:        schedBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size:  13,
                        color: schedFg,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Planifier',
                        style: TextStyle(
                          color:      schedFg,
                          fontSize:   12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
