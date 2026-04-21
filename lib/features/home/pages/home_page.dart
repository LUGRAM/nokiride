import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/home_controller.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/home_header.dart';
import '../widget/promo_carousel.dart';
import '../widget/search_bar_widget.dart';
import '../widget/service_grid_section.dart';
import '../widget/recent_activity_section.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const _PlaceholderTab(label: 'Courses'),
      const _PlaceholderTab(label: 'Livraisons'),
      const _PlaceholderTab(label: 'Profil'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: pages,
          )),
          const Positioned(
            left: 14, right: 14, bottom: 12,
            child: NokiBottomNavBar(),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.bgDark : AppColors.bgLight,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const HomeHeader(
                userName:   'Noki',
                location:   'Libreville, Akanda',
                notifCount: 3,
              ),
              const SizedBox(height: 10),
              HomeSearchBar(
                onSearchTap:   () => Get.toNamed('/trip'),
                onScheduleTap: () => Get.toNamed('/trip/schedule'),
              ),
              const SizedBox(height: 14),
              PromoCarousel(                        // ← ici
                //onFrameTap: (frameIndex) { ... },   // optionnel
              ),
              const SizedBox(height: 4),
              ServiceGridSection(
                onServiceTap: (id) {
                  switch (id) {
                    case 'moto':   Get.toNamed('/trip');          break;
                    case 'envoi':  Get.toNamed('/delivery');      break;
                    case 'market': Get.toNamed('/market');        break;
                    case 'plan':   Get.toNamed('/trip/schedule'); break;
                  }
                },
              ),
              const SizedBox(height: 20),
              const RecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.bgDark : AppColors.bgLight,
      child: SafeArea(
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
        ),
      ),
    );
  }
}