import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nokiride/features/history/page/history_page.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../profile/page/profile_page.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../../wallet/page/wallet_page.dart';
import '../controller/home_controller.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/home_header.dart';
import '../widget/search_bar_widget.dart';
import '../widget/service_grid_section.dart';
import '../widget/promo_carousel.dart';
import '../widget/recent_activity_section.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const HistoryPage(),
      const WalletPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => IndexedStack(
            index:    controller.tabIndex.value,
            children: pages,
          )),
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: 96,
            child: AbsorbPointer(
              absorbing: true,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: 12, right: 12, bottom: 10,
            child: const NokiBottomNavBar(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.bgDark : AppColors.bgLight;
    final userName = GetStorage().read<String>('user_name') ?? 'Noki';

    return Container(
      color: bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              // ── Header ──────────────────────────────────
              HomeHeader(
                userName:   userName,
                location:   'Libreville, Akanda',
                notifCount: 3,
                onNotifTap: () => Get.toNamed(Routes.notifications),
              ),
              const SizedBox(height: 10),

              // ── Search bar ──────────────────────────────
              HomeSearchBar(
                onSearchTap:   () => Get.toNamed(Routes.trip),
                onScheduleTap: () => Get.toNamed(Routes.trip),
              ),
              const SizedBox(height: 14),

              // ── NokiPay teaser ──────────────────────────
              //const _WalletTeaser(),
              //const SizedBox(height: 14),

              // ── Carousel promo ──────────────────────────
              PromoCarousel(
                frames: [
                  PromoFrame(
                    tag:         'OFFRE',
                    title:       '1ère course\nofferte',
                    subtitle:    'Code : NOKI2025',
                    cta:         'En profiter',
                    accentColor: AppColors.primaryBlue,
                    icon:        Icons.sports_motorsports_rounded,
                    imageUrl:    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
                    onTap:       () => Get.toNamed(Routes.trip),
                  ),
                  PromoFrame(
                    tag:         'NOUVEAU',
                    title:       'Market disponible\nà Libreville',
                    subtitle:    'Courses livrées en 45 min',
                    cta:         'Découvrir',
                    accentColor: AppColors.serviceMarket,
                    icon:        Icons.shopping_bag_rounded,
                    imageUrl:    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
                    onTap:       () => Get.toNamed(Routes.market),
                  ),
                  PromoFrame(
                    tag:         'EXPRESS',
                    title:       'Envoi de colis\nsans se déplacer',
                    subtitle:    'Tarif fixe dès 500 F CFA',
                    cta:         'Envoyer',
                    accentColor: AppColors.serviceEnvoi,
                    icon:        Icons.inventory_2_rounded,
                    imageUrl:    'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=800&q=80',
                    onTap:       () => Get.toNamed(Routes.delivery),
                  ),
                  PromoFrame(
                    tag:         'PARRAINAGE',
                    title:       'Invitez un ami\ngagnez 1 000 F',
                    subtitle:    'Crédité dès sa 1ère course',
                    cta:         'Partager',
                    accentColor: AppColors.servicePlan,
                    icon:        Icons.card_giftcard_rounded,
                    imageUrl:    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
                  ),
                  PromoFrame(
                    tag:         'SÉCURITÉ',
                    title:       'Bouton SOS\ntoujours actif',
                    subtitle:    'Votre sécurité, notre priorité',
                    cta:         'En savoir plus',
                    accentColor: AppColors.warning,
                    icon:        Icons.shield_rounded,
                    imageUrl:    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=800&q=80',
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Services grid ───────────────────────────
              ServiceGridSection(
                onServiceTap: _handleServiceTap,
              ),
              const SizedBox(height: 20),

              // ── Activité récente ────────────────────────
              RecentActivitySection(
                onSeeAll: () => Get.find<HomeController>().changeTabIndex(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleServiceTap(String id) {
    switch (id) {
      case 'moto':   Get.toNamed(Routes.trip);     break;
      case 'envoi':  Get.toNamed(Routes.delivery); break;
      case 'market': Get.toNamed(Routes.market);   break;
      case 'plan':   Get.toNamed(Routes.trip);     break;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// WALLET TEASER
// ─────────────────────────────────────────────────────────────
class _WalletTeaser extends StatelessWidget {
  const _WalletTeaser();

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final wallet  = Get.find<WalletController>();
    final primary = isDark ? AppColors.primaryBlue  : AppColors.primaryGreen;
    final cardBg  = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark    : AppColors.borderLight;
    final titleC  = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC    = isDark ? AppColors.textDarkSub   : AppColors.textLightSub;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.find<HomeController>().changeTabIndex(2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color:        cardBg,
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: border),
          ),
          child: Row(children: [
            // Icône wallet
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:        primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.account_balance_wallet_rounded, color: primary, size: 22),
            ),
            const SizedBox(width: 12),

            // Infos balance
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("NokiPay",
                style: TextStyle(fontSize: 11.5, color: subC, fontWeight: FontWeight.w600, letterSpacing: .3)),
              const SizedBox(height: 3),
              Obx(() => Text(
                wallet.balanceVisible.value ? wallet.formattedBalance : "•••••• F CFA",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleC),
              )),
            ]),
            const Spacer(),

            // Bouton recharger
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color:        primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: primary.withValues(alpha: .22)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, color: primary, size: 15),
                const SizedBox(width: 4),
                Text("Recharger",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
