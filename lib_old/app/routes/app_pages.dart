import 'package:get/get.dart';
//import 'package:nokiride/features/trip/pages/trip_estimate_page.dart';
import '../../features/delivery/pages/delivery_booking_page.dart';
import '../../features/delivery/pages/delivery_estimate_page.dart';
import '../../features/delivery/pages/delivery_searching_page.dart';
import '../../features/delivery/pages/delivery_tracking_page.dart';
import '../../features/trip/pages/trip_booking_page.dart';
import '../../features/trip/pages/trip_estimate_page.dart';
import '../../features/trip/pages/trip_searching_page.dart';
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
  static final routes = [
    GetPage(
      name:    Routes.splash,
      page:    () => const SplashPage(),
    ),
    GetPage(
      name:    Routes.onboarding,
      page:    () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name:    Routes.home,
      page:    () => const HomePage(),
      binding: HomeBinding(),
    ),

    // ── Trip ──────────────────────────────────────────────
    GetPage(name: Routes.trip,          page: () => const TripBookingPage(),   binding: TripBinding()),
    GetPage(name: Routes.tripEstimate,  page: () => const TripEstimatePage(),  binding: TripBinding()),
    GetPage(name: Routes.tripSearching, page: () => const TripSearchingPage(), binding: TripBinding()),
    GetPage(name: Routes.tripTracking,  page: () => const TripTrackingPage(),  binding: TripBinding()),

    // ── Delivery ──────────────────────────────────────────
    GetPage(name: Routes.delivery,          page: () => const DeliveryBookingPage(),   binding: DeliveryBinding()),
    GetPage(name: Routes.deliveryEstimate,  page: () => const DeliveryEstimatePage(),  binding: DeliveryBinding()),
    GetPage(name: Routes.deliverySearching, page: () => const DeliverySearchingPage(), binding: DeliveryBinding()),
    GetPage(name: Routes.deliveryTracking,  page: () => const DeliveryTrackingPage(),  binding: DeliveryBinding()),
  ];
}