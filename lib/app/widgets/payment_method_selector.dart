import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

const paymentMethodOptions = [
  PaymentMethodOption(
    value: 'noki_pay',
    label: 'NokiPay',
    icon: FontAwesomeIcons.wallet,
  ),
  PaymentMethodOption(
    value: 'airtel_money',
    label: 'Airtel Money',
    icon: FontAwesomeIcons.mobileScreen,
  ),
  PaymentMethodOption(
    value: 'moov_money',
    label: 'Moov Money',
    icon: FontAwesomeIcons.simCard,
  ),
  PaymentMethodOption(
    value: 'card',
    label: 'Carte',
    icon: FontAwesomeIcons.creditCard,
  ),
  PaymentMethodOption(
    value: 'cash',
    label: 'Espèces',
    icon: FontAwesomeIcons.moneyBillWave,
  ),
];

PaymentMethodOption paymentMethodByValue(String value) =>
    paymentMethodOptions.firstWhere(
      (option) => option.value == value,
      orElse: () => paymentMethodOptions.first,
    );

Future<String?> showPaymentMethodSelector({
  required BuildContext context,
  required String selectedMethod,
  List<String>? allowedMethods,
}) {
  final methods = allowedMethods == null
      ? paymentMethodOptions
      : paymentMethodOptions
          .where((option) => allowedMethods.contains(option.value))
          .toList();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleC = AppColors.textPrimary(context);
  final subC = AppColors.textSub(context);
  final surface = AppColors.surface(context);
  final border = AppColors.divider(context);
  final accent = AppColors.accent(context);

  return Get.bottomSheet<String>(
    Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Méthode de paiement',
            style: TextStyle(
              color: titleC,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mode mock activé pour les tests.',
            style: TextStyle(color: subC, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...methods.map((method) {
            final selected = method.value == selectedMethod;
            return ListTile(
              onTap: () => Get.back(result: method.value),
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: selected ? .16 : .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(method.icon, size: 16, color: accent),
                ),
              ),
              title: Text(
                method.label,
                style: TextStyle(
                  color: titleC,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              trailing: selected
                  ? Icon(Icons.check_circle_rounded, color: accent, size: 20)
                  : Icon(Icons.chevron_right_rounded, color: subC, size: 20),
            );
          }),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: isDark ? .55 : .25),
  );
}
