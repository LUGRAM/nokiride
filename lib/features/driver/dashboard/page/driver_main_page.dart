import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/driver_dashboard_controller.dart';
import '../widget/driver_bottom_nav.dart';
import 'driver_dashboard_page.dart';
import '../../earnings/page/driver_earnings_page.dart';
import '../../../wallet/page/wallet_page.dart';
import '../../profile/page/driver_profile_page.dart';

class DriverMainPage extends GetView<DriverDashboardController> {
  const DriverMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // On utilise une Stack pour que la BottomNav flotte par dessus le contenu
      body: Stack(
        children: [
          // Le contenu principal occupe tout l'écran
          Positioned.fill(
            child: Obx(() => IndexedStack(
                  index: controller.tabIndex.value,
                  children: const [
                    DriverDashboardPage(),
                    DriverEarningsPage(),
                    WalletPage(),
                    DriverProfilePage(),
                  ],
                )),
          ),
          
          // La barre de navigation est positionnée en bas
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DriverBottomNav(),
          ),
        ],
      ),
    );
  }
}
