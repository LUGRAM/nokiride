import 'package:get/get.dart';
import 'app_routes.dart';

// Import des pages
import '../../features/splash/pages/splash_page.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/otp_page.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/search/pages/search_page.dart';
import '../../features/trip/pages/trip_request_page.dart';
import '../../features/trip/pages/trip_tracking_page.dart';
import '../../features/trip/pages/trip_completed_page.dart';
import '../../features/delivery/pages/delivery_details_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/safety/pages/safety_settings_page.dart';

// Import des bindings
import '../../features/home/binding/home_binding.dart';
import '../../features/onboarding/binding/onboarding_binding.dart';
import '../../features/trip/binding/trip_binding.dart';
import '../../features/delivery/binding/delivery_binding.dart';
import '../../features/search/binding/search_binding.dart';
import '../../features/profile/binding/profile_binding.dart';
import '../../features/safety/binding/safety_binding.dart';
import '../../features/auth/binding/auth_binding.dart';

class AppPages {
  static final pages = [
    // Splash
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      // binding: SplashBinding(),
    ),

    // Onboarding
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
/*
    // Auth
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpPage(),
      binding: AuthBinding(),
    ),
*/
    // ==================== MAIN APP ====================
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
/*
    // Search
    GetPage(
      name: Routes.search,
      page: () => const SearchPage(),
      binding: SearchBinding(),
    ),

    // Trip Module
    GetPage(
      name: Routes.tripRequest,
      page: () => const TripRequestPage(),
      binding: TripBinding(),
    ),
    GetPage(
      name: Routes.tripTracking,
      page: () => const TripTrackingPage(),
      binding: TripBinding(),
    ),
    GetPage(
      name: Routes.tripCompleted,
      page: () => const TripCompletedPage(),
      binding: TripBinding(),
    ),

    // Delivery
    GetPage(
      name: Routes.delivery,
      page: () => const DeliveryDetailsPage(),
      binding: DeliveryBinding(),
    ),

    // Profile
    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),

    // Safety
    GetPage(
      name: Routes.safetySettings,
      page: () => const SafetySettingsPage(),
      binding: SafetyBinding(),
    ),
 */ ];
}