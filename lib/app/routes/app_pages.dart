import 'package:get/get.dart';
import 'package:nokiride/features/wallet/bindings/wallet_binding.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/page/login_page.dart';
import '../../features/auth/page/otp_page.dart';
import '../../features/auth/page/register_page.dart';
import '../../features/auth/page/forgot_password_page.dart';
import '../../features/client/delivery/bindings/delivery_binding.dart';
import '../../features/client/delivery/page/delivery_booking_page.dart';
import '../../features/client/delivery/page/delivery_estimate_page.dart';
import '../../features/client/delivery/page/delivery_searching_page.dart';
import '../../features/client/delivery/page/delivery_tracking_page.dart';
import '../../features/client/home/bindings/home_binding.dart';
import '../../features/client/home/page/home_page.dart';
import '../../features/market/bindings/market_binding.dart';
import '../../features/market/page/cart_page.dart';
import '../../features/market/page/market_page.dart';
import '../../features/market/page/merchant_page.dart';
import '../../features/notifications/page/notifications_page.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/client/profile/bindings/profile_binding.dart';
import '../../features/client/profile/page/client_profile_page.dart';
import '../../features/client/profile/page/support_legal_pages.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/client/trip/bindings/trip_binding.dart';
import '../../features/client/trip/page/trip_estimate_page.dart';
import '../../features/client/trip/page/trip_page.dart';
import '../../features/client/trip/page/trip_rating_page.dart';
import '../../features/client/trip/page/trip_searching_page.dart';
import '../../features/client/trip/page/trip_tracking_page.dart';
import '../../features/driver/dashboard/bindings/driver_dashboard_binding.dart';
import '../../features/driver/dashboard/page/driver_main_page.dart';
import '../../features/driver/earnings/page/driver_earnings_page.dart';
import '../../features/driver/vehicle/page/vehicle_registration_page.dart';
import '../../features/driver/trip_mgt/bindings/active_trip_binding.dart';
import '../../features/driver/trip_mgt/presentation/pages/active_trip_page.dart';
import '../../features/wallet/page/wallet_page.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: HomeBinding()),
    GetPage(
        name: Routes.clientHome,
        page: () => const HomePage(),
        binding: HomeBinding()),
    GetPage(
        name: Routes.driverDashboard,
        page: () => const DriverMainPage(),
        binding: DriverDashboardBinding()),
    GetPage(
        name: Routes.driverActiveTrip,
        page: () => const ActiveTripPage(),
        binding: ActiveTripBinding()),
    GetPage(
      name: Routes.driverVehicleRegistration,
      page: () => const VehicleRegistrationPage(),
      binding: DriverDashboardBinding(),
    ),
    GetPage(
      name: Routes.driverEarnings,
      page: () => const DriverEarningsPage(),
    ),
    GetPage(
        name: Routes.trip,
        page: () => const TripPage(),
        binding: TripBinding()),
    GetPage(
        name: Routes.tripEstimate,
        page: () => const TripEstimatePage(),
        binding: TripBinding()),
    GetPage(
        name: Routes.tripSearching,
        page: () => const TripSearchingPage(),
        binding: TripBinding()),
    GetPage(
        name: Routes.tripTracking,
        page: () => const TripTrackingPage(),
        binding: TripBinding()),
    GetPage(
        name: Routes.tripRating,
        page: () => const TripRatingPage(),
        binding: TripBinding()),
    GetPage(
        name: Routes.delivery,
        page: () => const DeliveryBookingPage(),
        binding: DeliveryBinding()),
    GetPage(
        name: Routes.deliveryEstimate,
        page: () => const DeliveryEstimatePage(),
        binding: DeliveryBinding()),
    GetPage(
        name: Routes.deliverySearching,
        page: () => const DeliverySearchingPage(),
        binding: DeliveryBinding()),
    GetPage(
        name: Routes.deliveryTracking,
        page: () => const DeliveryTrackingPage(),
        binding: DeliveryBinding()),
    GetPage(
        name: Routes.market,
        page: () => const MarketPage(),
        binding: MarketBinding()),
    GetPage(
        name: Routes.marketMerchant,
        page: () => const MerchantPage(),
        binding: MarketBinding()),
    GetPage(
        name: Routes.marketCart,
        page: () => const CartPage(),
        binding: MarketBinding()),
    GetPage(name: Routes.notifications, page: () => const NotificationsPage()),
    GetPage(
        name: Routes.wallet,
        page: () => const WalletPage(),
        binding: WalletBinding()),
    GetPage(
        name: Routes.profile,
        page: () => const ClientProfilePage(),
        binding: ProfileBinding()),
    GetPage(name: Routes.helpCenter, page: () => const HelpCenterPage()),
    GetPage(
        name: Routes.contactSupport, page: () => const ContactSupportPage()),
    GetPage(name: Routes.legalCenter, page: () => const LegalCenterPage())
  ];
}
