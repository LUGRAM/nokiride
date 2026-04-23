abstract class Routes {
  static const splash           = '/splash';
  static const onboarding       = '/onboarding';
  static const login            = '/login';
  static const home             = '/home';

  // ── Trip (Moto-Taxi) ─────────────────────────────────────
  static const trip             = '/trip';
  static const tripEstimate     = '/trip/estimate';
  static const tripSearching    = '/trip/searching';
  static const tripTracking     = '/trip/tracking';

  // ── Delivery (Envoi colis) ────────────────────────────────
  static const delivery         = '/delivery';
  static const deliveryEstimate = '/delivery/estimate';
  static const deliverySearching= '/delivery/searching';
  static const deliveryTracking = '/delivery/tracking';

  // ── Market (à venir) ─────────────────────────────────────
  static const market           = '/market';
}