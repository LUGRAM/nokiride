import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleService extends GetxService {
  static LocaleService get to => Get.find();
  static const _key = 'locale';
  final _box = GetStorage();

  final _locale = const Locale('fr', 'FR').obs;
  Locale get locale => _locale.value;
  bool get isFrench => _locale.value.languageCode == 'fr';

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String>(_key);
    if (saved == 'en') {
      _locale.value = const Locale('en', 'US');
    }
  }

  void setFrench() {
    _locale.value = const Locale('fr', 'FR');
    _box.write(_key, 'fr');
    Get.updateLocale(_locale.value);
  }

  void setEnglish() {
    _locale.value = const Locale('en', 'US');
    _box.write(_key, 'en');
    Get.updateLocale(_locale.value);
  }

  void toggleLocale() => isFrench ? setEnglish() : setFrench();
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fr_FR': {
      'app_name':       'NokiRide',
      'tagline':        'Mobilité urbaine simplifiée',
      'hello':          'Bonjour',
      'location':       'Libreville, Akanda',
      'search_hint':    'Chercher une destination...',
      'plan':           'Planifier',
      'our_services':   'Nos services',
      'recent':         'Activité récente',
      'see_all':        'Voir tout',
      'moto_taxi':      'Moto-Taxi',
      'moto_sub':       'Course rapide',
      'delivery':       'Envoi colis',
      'delivery_sub':   'A → B sans vous',
      'market':         'Market',
      'market_sub':     'Courses livrées',
      'schedule':       'Planifier',
      'schedule_sub':   'Résa. avancée',
      'estimate':       'Estimer le prix',
      'confirm':        'Confirmer',
      'cancel':         'Annuler',
      'next':           'Suivant',
      'skip':           'Passer',
      'start':          'Commencer avec NokiRide',
      'have_account':   "J'ai déjà un compte",
      'phone_number':   'Numéro de téléphone',
      'enter_otp':      'Code de vérification',
      'resend':         'Renvoyer le code',
      'your_name':      'Votre nom',
      'continue_btn':   'Continuer',
      'wallet':         'Wallet',
      'balance':        'Solde',
      'history':        'Historique',
      'profile':        'Profil',
      'home':           'Accueil',
      'logout':         'Se déconnecter',
      'settings':       'Paramètres',
      'language':       'Langue',
      'theme':          'Thème',
      'notifications':  'Notifications',
      'rating_title':   'Notez votre coursier',
      'rating_hint':    'Laissez un commentaire...',
      'submit_rating':  'Envoyer la note',
      'security_code':  'Code de sécurité',
      'security_hint':  'Partagez ce code avec le destinataire',
    },
    'en_US': {
      'app_name':       'NokiRide',
      'tagline':        'Urban mobility simplified',
      'hello':          'Hello',
      'location':       'Libreville, Akanda',
      'search_hint':    'Search for a destination...',
      'plan':           'Schedule',
      'our_services':   'Our services',
      'recent':         'Recent activity',
      'see_all':        'See all',
      'moto_taxi':      'Moto-Taxi',
      'moto_sub':       'Quick ride',
      'delivery':       'Send parcel',
      'delivery_sub':   'A → B without you',
      'market':         'Market',
      'market_sub':     'Delivered groceries',
      'schedule':       'Schedule',
      'schedule_sub':   'Advanced booking',
      'estimate':       'Estimate price',
      'confirm':        'Confirm',
      'cancel':         'Cancel',
      'next':           'Next',
      'skip':           'Skip',
      'start':          'Get started with NokiRide',
      'have_account':   'I already have an account',
      'phone_number':   'Phone number',
      'enter_otp':      'Verification code',
      'resend':         'Resend code',
      'your_name':      'Your name',
      'continue_btn':   'Continue',
      'wallet':         'Wallet',
      'balance':        'Balance',
      'history':        'History',
      'profile':        'Profile',
      'home':           'Home',
      'logout':         'Log out',
      'settings':       'Settings',
      'language':       'Language',
      'theme':          'Theme',
      'notifications':  'Notifications',
      'rating_title':   'Rate your courier',
      'rating_hint':    'Leave a comment...',
      'submit_rating':  'Submit rating',
      'security_code':  'Security code',
      'security_hint':  'Share this code with the recipient',
    },
  };
}
