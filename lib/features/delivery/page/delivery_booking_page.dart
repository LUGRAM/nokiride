import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../trip/widget/address_search_sheet.dart';
import '../../trip/widget/mini_map_widget.dart';
import '../controller/delivery_controller.dart';
import '../model/delivery_model.dart';

class DeliveryBookingPage extends GetView<DeliveryController> {
  const DeliveryBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Stack(
        children: [
          // ── Carte ─────────────────────────────────────────
          Positioned.fill(
            child: Obx(() => MiniMapWidget(
              pickup:  controller.pickup.value,
              dropoff: controller.dropoff.value,
            )),
          ),

          // ── AppBar ────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _BackBtn(isDark: isDark),
                    const SizedBox(width: 12),
                    Text(
                      'Envoi de colis',
                      style: TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sheet de saisie ───────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _DeliverySheet(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sheet principale — scrollable
// ─────────────────────────────────────────────────────────────
class _DeliverySheet extends GetView<DeliveryController> {
  const _DeliverySheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg  = isDark ? AppColors.bgDarkSurface  : AppColors.bgLightSurface;
    final border  = isDark ? AppColors.borderDark      : AppColors.borderLight;
    final primary = isDark ? AppColors.primaryBlue     : AppColors.primaryGreen;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .72,
      ),
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border:       Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: .12),
            blurRadius: 24,
            offset:     const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 38, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            decoration: BoxDecoration(
              color:        border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Adresses ──────────────────────────────
                  _SectionTitle(label: 'Adresses', isDark: isDark),
                  const SizedBox(height: 10),

                  Obx(() => _AddressField(
                    isDark:   isDark,
                    hint:     "Point d'enlèvement",
                    value:    controller.pickup.value?.name,
                    dotColor: primary,
                    onTap:    () => _openSearch(context, isPickup: true),
                    onClear:  controller.clearPickup,
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 19),
                    child: Container(
                      width: 1.5, height: 14,
                      color: border,
                    ),
                  ),
                  Obx(() => _AddressField(
                    isDark:   isDark,
                    hint:     'Destination',
                    value:    controller.dropoff.value?.name,
                    dotColor: AppColors.success,
                    onTap:    () => _openSearch(context, isPickup: false),
                    onClear:  controller.clearDropoff,
                  )),

                  const SizedBox(height: 20),

                  // ── Destinataire ──────────────────────────
                  _SectionTitle(label: 'Destinataire', isDark: isDark),
                  const SizedBox(height: 10),
                  _InputField(
                    isDark:      isDark,
                    hint:        'Nom du destinataire',
                    icon:        Icons.person_outline_rounded,
                    onChanged:   (v) => controller.recipientName.value = v,
                    inputType:   TextInputType.name,
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    isDark:      isDark,
                    hint:        'Téléphone  ex: 077 123 456',
                    icon:        Icons.phone_outlined,
                    onChanged:   (v) => controller.recipientPhone.value = v,
                    inputType:   TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Type de colis ─────────────────────────
                  _SectionTitle(label: 'Type de colis', isDark: isDark),
                  const SizedBox(height: 10),
                  Obx(() => _ParcelSelector(
                    isDark:   isDark,
                    selected: controller.parcelSize.value,
                    onSelect: controller.setParcelSize,
                  )),

                  const SizedBox(height: 20),

                  // ── Note (optionnel) ──────────────────────
                  _SectionTitle(
                    label:    'Note pour le coursier',
                    isDark:   isDark,
                    optional: true,
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    isDark:    isDark,
                    hint:      'Fragile, appeler à l\'arrivée...',
                    icon:      Icons.note_outlined,
                    onChanged: (v) => controller.parcelNote.value = v,
                    maxLines:  2,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bouton estimer ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
            child: Obx(() => AnimatedOpacity(
              opacity:  controller.canEstimate ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width:  double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: controller.canEstimate
                      ? controller.estimateDelivery
                      : null,
                  child: const Text(
                    'Estimer le prix',
                    style: TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                      color:      Colors.white,
                    ),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, {required bool isPickup}) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => AddressSearchSheet(
        isDark:   isDark,
        isPickup: isPickup,
        onSelect: isPickup
            ? controller.selectPickup
            : controller.selectDropoff,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sélecteur type de colis
// ─────────────────────────────────────────────────────────────
class _ParcelSelector extends StatelessWidget {
  const _ParcelSelector({
    required this.isDark,
    required this.selected,
    required this.onSelect,
  });

  final bool                   isDark;
  final ParcelSize             selected;
  final ValueChanged<ParcelSize> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ParcelSize.values.map((size) {
        final isActive = size == selected;
        final color    = isActive
            ? (isDark ? AppColors.primaryBlue : AppColors.primaryGreen)
            : (isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput);
        final textC    = isActive
            ? Colors.white
            : (isDark ? AppColors.textDarkSub : AppColors.textLightSub);
        final border   = isActive
            ? BorderSide.none
            : BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              );

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: size == ParcelSize.values.last ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => onSelect(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:        color,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.fromBorderSide(border),
                ),
                child: Column(
                  children: [
                    Text(size.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      size.label.split(' ').first, // "Petit" / "Moyen" / "Grand"
                      style: TextStyle(
                        fontSize:   11,
                        fontWeight: FontWeight.w700,
                        color:      textC,
                      ),
                    ),
                    Text(
                      size.label.contains('<')
                          ? '< 2 kg'
                          : size.label.contains('>')
                              ? '> 10 kg'
                              : '2–10 kg',
                      style: TextStyle(
                        fontSize: 9.5,
                        color:    isActive
                            ? Colors.white70
                            : (isDark
                                ? AppColors.textDarkMuted
                                : AppColors.textLightMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets réutilisables
// ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.isDark,
    this.optional = false,
  });
  final String label;
  final bool   isDark;
  final bool   optional;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC  = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w700,
            color:      color,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            '(optionnel)',
            style: TextStyle(fontSize: 11, color: subC),
          ),
        ],
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.isDark,
    required this.hint,
    required this.dotColor,
    required this.onTap,
    this.value,
    this.onClear,
  });
  final bool         isDark;
  final String       hint;
  final String?      value;
  final Color        dotColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final textC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final hintC = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;
    final filled = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:  52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: filled ? dotColor : dotColor.withValues(alpha: .4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filled ? value! : hint,
                style: TextStyle(
                  fontSize:   14,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                  color:      filled ? textC : hintC,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filled && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 18, color: hintC),
              ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.isDark,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.inputType,
    this.inputFormatters,
    this.maxLines = 1,
  });
  final bool          isDark;
  final String        hint;
  final IconData      icon;
  final ValueChanged<String> onChanged;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final int           maxLines;

  @override
  Widget build(BuildContext context) {
    final bg    = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final textC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final hintC = isDark ? AppColors.textDarkMuted   : AppColors.textLightMuted;
    final iconC = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconC),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged:        onChanged,
              keyboardType:     inputType,
              inputFormatters:  inputFormatters,
              maxLines:         maxLines,
              style: TextStyle(
                fontSize: 14,
                color:    textC,
              ),
              decoration: InputDecoration(
                border:         InputBorder.none,
                hintText:       hint,
                hintStyle:      TextStyle(
                  color:    hintC,
                  fontSize: 14,
                ),
                isDense:        true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .10), blurRadius: 8),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          size:  20,
        ),
      ),
    );
  }
}
