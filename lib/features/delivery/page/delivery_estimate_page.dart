import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/delivery_controller.dart';
import '../model/delivery_model.dart';

class DeliveryEstimatePage extends GetView<DeliveryController> {
  const DeliveryEstimatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.bgDark : AppColors.bgLight;
    final d      = controller.currentDelivery.value;

    if (d == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _PriceCard(d: d, isDark: isDark),
                    const SizedBox(height: 14),
                    _RouteCard(d: d, isDark: isDark),
                    const SizedBox(height: 14),
                    _RecipientCard(d: d, isDark: isDark),
                    const SizedBox(height: 14),
                    _ParcelCard(d: d, isDark: isDark),
                    const SizedBox(height: 14),
                    _TarifInfo(isDark: isDark),
                  ],
                ),
              ),
            ),
            _BottomActions(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
          ),
          const SizedBox(width: 16),
          Text(
            'Estimation de livraison',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.d, required this.isDark});
  final DeliveryModel d;
  final bool          isDark;

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue    : AppColors.primaryGreen;
    final subC    = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(d.parcelSize.emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            d.parcelSize.label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subC),
          ),
          const SizedBox(height: 8),
          Text(
            d.formattedPrice,
            style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w800,
              color: primary, letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Chip(icon: Icons.route_rounded,  label: d.formattedDistance, isDark: isDark),
              const SizedBox(width: 10),
              _Chip(icon: Icons.timer_outlined, label: d.formattedDuration, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.isDark});
  final IconData icon;
  final String   label;
  final bool     isDark;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final color = isDark ? AppColors.textDarkSub    : AppColors.textLightSub;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.d, required this.isDark});
  final DeliveryModel d;
  final bool          isDark;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _RouteRow(
            icon: Icons.radio_button_checked_rounded,
            iconColor: AppColors.primaryBlue,
            label: d.pickup.name, sub: d.pickup.address,
            titleC: titleC, subC: subC,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(width: 1.5, height: 16,
              color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          _RouteRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.success,
            label: d.dropoff.name, sub: d.dropoff.address,
            titleC: titleC, subC: subC,
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon, required this.iconColor,
    required this.label, required this.sub,
    required this.titleC, required this.subC,
  });
  final IconData icon;
  final Color    iconColor;
  final String   label, sub;
  final Color    titleC, subC;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleC)),
              Text(sub,   style: TextStyle(fontSize: 11.5, color: subC),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({required this.d, required this.isDark});
  final DeliveryModel d;
  final bool          isDark;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        AppColors.serviceEnvoi.withOpacity(.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.person_rounded,
              color: AppColors.serviceEnvoi, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.recipient.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleC),
                ),
                const SizedBox(height: 2),
                Text(d.recipient.phone,
                  style: TextStyle(fontSize: 12.5, color: subC)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcelCard extends StatelessWidget {
  const _ParcelCard({required this.d, required this.isDark});
  final DeliveryModel d;
  final bool          isDark;

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC   = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(d.parcelSize.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(d.parcelSize.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleC)),
            ],
          ),
          if (d.parcelNote != null) ...[
            const SizedBox(height: 10),
            Text(
              d.parcelNote!,
              style: TextStyle(fontSize: 12.5, color: subC, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarifInfo extends StatelessWidget {
  const _TarifInfo({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.infoFill     : AppColors.accentBlueFill;
    final color = isDark ? AppColors.primaryBlueLight : AppColors.accentBlueLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prix : 600 F CFA de base + 200 F CFA/km + supplément colis. Minimum 1 000 F CFA.',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends GetView<DeliveryController> {
  const _BottomActions({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark     : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue    : AppColors.primaryGreen;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      decoration: BoxDecoration(
        color: bg, border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity, height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: controller.confirmDelivery,
              child: const Text(
                'Confirmer l\'envoi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.textDarkSub : AppColors.textLightSub,
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: Get.back,
              child: const Text('Modifier', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
