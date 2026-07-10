import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.userName = 'Utilisateur',
    this.notifCount = 0,
    this.onNotifTap,
    this.onAvatarTap,
  });

  final String userName;
  final int notifCount;
  final VoidCallback? onNotifTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Effet Glassmorphism
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.6);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Avatar(
                initials: _initials(userName),
                isDark: isDark,
                onTap: onAvatarTap,
              ),
              Text(
                "NokiRide",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  color: AppColors.textPrimary(context),
                ),
              ),
              _NotifButton(
                count: notifCount,
                isDark: isDark,
                onTap: onNotifTap,
              ),
            ],
          ),
        ),
      ),
    );
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.isDark,
    this.onTap,
  });

  final String initials;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? const Color(0xFF182229)
        : AppColors.success.withValues(alpha: 0.1);
    final border = AppColors.divider(context);
    final fg = isDark ? AppColors.accentDark : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 0.5),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  const _NotifButton({
    required this.isDark,
    required this.count,
    this.onTap,
  });

  final bool isDark;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg =
        isDark ? const Color(0xFF182229) : Colors.white.withValues(alpha: 0.5);
    final border = AppColors.divider(context);
    final fg = AppColors.textSub(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.bell,
                size: 18,
                color: fg,
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: 6,
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

  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.bgDark : AppColors.bgLight,
          width: 1.5,
        ),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
