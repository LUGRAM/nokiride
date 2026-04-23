import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/services/theme_service.dart';
import '../../../app/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.userName   = 'Noki',
    this.location   = 'Libreville, Akanda',
    this.notifCount = 0,
    this.onNotifTap,
    this.onAvatarTap,
  });

  final String        userName;
  final String        location;
  final int           notifCount;
  final VoidCallback? onNotifTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _Avatar(
            initials: _initials(userName),
            isDark:   isDark,
            onTap:    onAvatarTap,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LocationRow(location: location, isDark: isDark),
                const SizedBox(height: 3),
                Text(
                  'Bonjour, $userName !',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight:    FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Toggle thème ───────────────────────────────
          _ThemeToggleButton(isDark: isDark),
          const SizedBox(width: 8),
          // ── Notifications ──────────────────────────────
          _NotifButton(
            count:  notifCount,
            isDark: isDark,
            onTap:  onNotifTap,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────
// Theme Toggle
// ─────────────────────────────────────────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkElevated : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark      : AppColors.borderLight;

    // Couleur et icône selon thème courant
    final icon  = isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;
    final color = isDark ? AppColors.warning         : AppColors.primaryBlue;

    return Obx(() {
      // Dépendance réactive sur ThemeService pour re-render si thème change
      final _ = ThemeService.to.mode;

      return GestureDetector(
        onTap: ThemeService.to.toggleTheme,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve:    Curves.easeInOut,
          width:  44,
          height: 44,
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(color: border, width: 1),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.isDark,
    this.onTap,
  });

  final String        initials;
  final bool          isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkElevated   : AppColors.primaryGreenFill;
    final border = isDark ? AppColors.borderDark        : AppColors.borderLight;
    final fg     = isDark ? AppColors.primaryBlueLight  : AppColors.primaryGreenDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  44,
        height: 44,
        decoration: BoxDecoration(
          color:  bg,
          shape:  BoxShape.circle,
          border: Border.all(color: border, width: 1.5),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color:         fg,
              fontSize:      14,
              fontWeight:    FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Location Row
// ─────────────────────────────────────────────────────────────
class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location, required this.isDark});

  final String location;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.textDarkMuted    : AppColors.textLightMuted;
    final pin   = isDark ? AppColors.primaryBlueLight : AppColors.primaryGreen;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_rounded, size: 12, color: pin),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            location,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w500,
              color:      color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Notification Button
// ─────────────────────────────────────────────────────────────
class _NotifButton extends StatelessWidget {
  const _NotifButton({
    required this.isDark,
    required this.count,
    this.onTap,
  });

  final bool          isDark;
  final int           count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkElevated : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark      : AppColors.borderLight;
    final fg     = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color:        bg,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: border, width: 1),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size:  22,
              color: fg,
            ),
          ),
          if (count > 0)
            Positioned(
              top:   6,
              right: 6,
              child: _NotifBadge(count: count, isDark: isDark),
            ),
        ],
      ),
    );
  }
}

class _NotifBadge extends StatelessWidget {
  const _NotifBadge({required this.count, required this.isDark});

  final int  count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding:     const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:        AppColors.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.bgDark : AppColors.bgLight,
          width: 1.5,
        ),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   9,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
