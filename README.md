# NokiRide 🏍️

**Mobilité urbaine simplifiée** — Application Flutter de transport et livraison à Libreville, Gabon.

## Structure

```
lib/
├── app/
│   ├── routes/          Routes + Pages GetX
│   ├── services/        ThemeService + LocaleService
│   ├── theme/           AppColors + AppTheme
│   └── widgets/         AppButton + GradientBackground
├── core/
│   ├── network/         AppClient (prêt pour Laravel)
│   └── storage/         AppStorage
└── features/
    ├── splash/           Écran de démarrage
    ├── onboarding/       3 slides d'introduction
    ├── auth/             Login (tél+OTP) → Register
    ├── home/             Dashboard principal
    ├── trip/             Moto-Taxi complet
    ├── delivery/         Envoi colis complet
    ├── market/           Catalogue marchands
    ├── history/          Historique courses/livraisons
    ├── wallet/           Portefeuille + recharge
    ├── profile/          Profil + settings
    └── notifications/    Centre de notifications
backend/
└── Laravel + Filament     API mobile + administration
```

## Démarrage

```bash
flutter pub get
flutter run
```

## Backend Laravel + Filament

```bash
cd backend
composer install
php artisan migrate --seed
php artisan serve
```

Admin Filament: `http://127.0.0.1:8000/admin`

Compte de démonstration:
- Email: `admin@nokiride.local`
- Mot de passe: `password`

## Auth (prototype)
- Code OTP de test : **1234**
- Numéro : n'importe quel numéro gabonais (+241)

## Thèmes
- **Green-Dark** (défaut) / **Light-Green** — toggle dans la navbar home

## Langues
- 🇫🇷 Français / 🇬🇧 Anglais — switcher dans Profil > Paramètres
