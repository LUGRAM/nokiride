import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../wallet/controller/wallet_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.userName   = 'Utilisateur',
    this.location   = 'Libreville, Gabon',
    this.notifCount = 0,
    this.onNotifTap,
    this.onAvatarTap,
    this.onWalletTap,
  });

  final String        userName;
  final String        location;
  final int           notifCount;
  final VoidCallback? onNotifTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onWalletTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleC = AppColors.textPrimary(context);
    final walletController = Get.find<WalletController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
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
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        fontSize: 20,
                        color: titleC,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _WalletChip(
                controller: walletController,
                isDark: isDark,
                onTap: onWalletTap,
              ),
              const SizedBox(width: 8),
              _NotifButton(
                count: notifCount,
                isDark: isDark,
                onTap: onNotifTap,
              ),
            ],
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
    final bg     = isDark ? const Color(0xFF182229) : const Color(0xFFE8F5E9);
    final border = AppColors.divider(context);
    final fg     = isDark ? AppColors.accentDark : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  44,
        height: 44,
        decoration: BoxDecoration(
          color:  bg,
          shape:  BoxShape.circle,
          border: Border.all(color: border, width: 0.5),
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
// Wallet Chip
// ─────────────────────────────────────────────────────────────
class _WalletChip extends StatelessWidget {
  const _WalletChip({
    required this.controller,
    required this.isDark,
    this.onTap,
  });

  final WalletController controller;
  final bool             isDark;
  final VoidCallback?    onTap;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? const Color(0xFF182229) : AppColors.success.withValues(alpha: 0.1);
    final border = isDark ? AppColors.borderDark : AppColors.success.withValues(alpha: 0.2);
    final fg     = isDark ? AppColors.accentDark : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.wallet, size: 12, color: fg),
            const SizedBox(width: 8),
            Obx(() => Text(
              controller.balanceVisible.value 
                  ? "${controller.balance.value} F"
                  : "•••• F",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            )),
          ],
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
    final bg     = isDark ? const Color(0xFF182229) : Colors.white;
    final border = AppColors.divider(context);
    final fg     = AppColors.textSub(context);

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
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(color: border, width: 0.5),
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
