import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../history/page/history_page.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/page/client_profile_page.dart';
import '../../../wallet/page/wallet_page.dart';
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
    final profileController = Get.find<ProfileController>();
    final Widget dashboardBody = Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120, top: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Obx(() => RecentActivitySection(
                    activities: profileController.stats.value.recentActivities,
                    onSeeAll: () => controller.changeTabIndex(1),
                  )),
            ],
          ),
        ),
        HomeHeader(
          onAvatarTap: () => controller.tabIndex.value = 3,
        ),
      ],
    );

    final List<Widget> mainPages = [
      dashboardBody,
      const HistoryPage(),
      const WalletPage(),
      const ClientProfilePage(),
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
