abstract class Routes {

  // Splash & Onboarding
  static const String splash       = '/splash';
  static const String onboarding   = '/onboarding';

  // Auth
  static const String login        = '/login';
  static const String register     = '/register';
  static const String otp          = '/otp';

  // Main - Navigation principale (Bottom Nav Bar)
  static const String home         = '/home';      // Page principale avec BottomNav

  // Pages accessibles depuis la Home ou ailleurs
  static const String search       = '/search';
  static const String trip         = '/trip';           // Demande + suivi de course
  static const String delivery     = '/delivery';       // Détails d'une livraison
  static const String profile      = '/profile';

  // Sous-pages du Trip (recommandé)
  static const String tripRequest  = '/trip/request';
  static const String tripTracking = '/trip/tracking';
  static const String tripCompleted = '/trip/completed';

  // Safety (accessible depuis Trip)
  static const String safetySettings = '/safety/settings';
}