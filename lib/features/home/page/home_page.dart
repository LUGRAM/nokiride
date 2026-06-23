import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../history/page/history_page.dart';
import '../../profile/page/profile_page.dart';
import '../../wallet/page/wallet_page.dart';
import '../controller/home_controller.dart';

// Tes widgets locaux à la feature home
import '../widget/bottom_nav_bar.dart';
import '../widget/home_header.dart';
import '../widget/recent_activity_section.dart';
import '../widget/service_grid_section.dart';
import '../widget/promo_carousel.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget dashboardBody = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              onAvatarTap: () => controller.tabIndex.value = 3,
              onWalletTap: () => controller.tabIndex.value = 2,
            ),
            const SizedBox(height: 20),
            const PromoCarousel(),
            const SizedBox(height: 24),
            ServiceGridSection(
              onServiceTap: (id) {
                if (id == 'moto') Get.toNamed('/trip');
                if (id == 'envoi') Get.toNamed('/delivery');
              },
            ),
            const SizedBox(height: 24),
            RecentActivitySection(
              onSeeAll: () => controller.changeTabIndex(1),
            ),
          ],
        ),
      ),
    );

    final List<Widget> mainPages = [
      dashboardBody,
      const HistoryPage(),
      const WalletPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          // Gère le switch d'écran de manière réactive
          Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: mainPages,
          )),

          // Ton BottomNavBar personnalisé flottant ou ancré
          const Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: NokiBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
