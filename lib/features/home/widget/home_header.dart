import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _Avatar(
            initials: _initials(userName),
            isDark: isDark,
            onTap: onAvatarTap,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LocationRow(location: location, isDark: isDark),
                const SizedBox(height: 2),
                Text(
                  _greetingMessage(userName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _NotifButton(
            count: notifCount,
            isDark: isDark,
            onTap: onNotifTap,
          ),
        ],
      ),
    );
  }

  String _greetingMessage(String name) {
    // 1. Nettoyage de l'ID technique (#...)
    final rawName = name.split('#')[0].trim();
    
    // 2. Détermination du salut selon l'heure
    final hour = DateTime.now().hour;
    final salute = (hour >= 18 || hour < 5) ? 'good_evening'.tr : 'hello'.tr;

    // 3. Liste des noms "non-professionnels" ou placeholders à ignorer
    final placeholders = ['parent', 'noki', 'utilisateur', 'admin', 'test', 'guest', 'client'];
    
    if (rawName.isEmpty || placeholders.contains(rawName.toLowerCase())) {
      return '$salute ! 👋';
    }

    // 4. Formatage propre (Majuscule pour le prénom)
    final cleanName = rawName[0].toUpperCase() + rawName.substring(1).toLowerCase();
    
    return '$salute, $cleanName 👋';
  }

  String _initials(String name) {
    final cleanName = name.split('#')[0].trim();
    final parts = cleanName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return cleanName.substring(0, cleanName.length >= 2 ? 2 : 1).toUpperCase();
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
    final fg     = isDark ? AppColors.neonYellow        : AppColors.emeraldPrimary;

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
    final pin   = AppColors.emeraldPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(FontAwesomeIcons.locationDot, size: 10, color: pin),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            location,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
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
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.bell,
                size:  18,
                color: fg,
              ),
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
