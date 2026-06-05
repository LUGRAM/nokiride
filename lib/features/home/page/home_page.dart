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
              const SizedBox(height: 10),

              // ── Carousel promo (PLACÉ PLUS BAS) ─────────
              PromoCarousel(
                frames: [
                  PromoFrame(
                    tag:         'OFFRE',
                    title:       '1ère course\nofferte',
                    subtitle:    'Code : NOKI2025',
                    cta:         'En profiter',
                    accentColor: AppColors.emeraldPrimary,
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
                ],
              ),
              const SizedBox(height: 24),

              // ── Services grid (REHAUSSÉ) ────────────────
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
