import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
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
      const _PlaceholderTab(label: 'Livraisons',  icon: Icons.local_shipping_outlined),
      const _PlaceholderTab(label: 'Courses',     icon: Icons.compare_arrows_rounded),
      const _PlaceholderTab(label: 'Profil',      icon: Icons.person_rounded),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => IndexedStack(
            index:    controller.tabIndex.value,
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

// ─────────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.bgDark : AppColors.bgLight;

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
              const HomeHeader(
                userName:   'Noki',
                location:   'Libreville, Akanda',
                notifCount: 3,
              ),
              const SizedBox(height: 10),

              // ── Search bar ──────────────────────────────
              HomeSearchBar(
                onSearchTap:   () => Get.toNamed(Routes.trip),
                onScheduleTap: () => Get.toNamed(Routes.trip),
              ),
              const SizedBox(height: 14),

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
                onSeeAll: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleServiceTap(String id) {
    switch (id) {
      case 'moto':
        Get.toNamed(Routes.trip);
        break;
      case 'envoi':
        Get.toNamed(Routes.delivery);
        break;
      case 'market':
        Get.toNamed(Routes.market);
        break;
      case 'plan':
        Get.toNamed(Routes.trip);
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// PLACEHOLDER TABS
// ─────────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label, required this.icon});
  final String   label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.bgDark      : AppColors.bgLight;
    final textC   = isDark ? AppColors.textDarkSub  : AppColors.textLightSub;
    final iconC   = isDark
        ? AppColors.primaryBlueLight
        : AppColors.primaryGreen;

    return Container(
      color: bg,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconC, size: 48),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bientôt disponible',
                style: TextStyle(fontSize: 14, color: textC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}