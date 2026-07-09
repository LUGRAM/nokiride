import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../app/theme/app_colors.dart';

class GabonPhoneField extends StatelessWidget {
  const GabonPhoneField({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimary(context);
    final secondaryColor = AppColors.textSub(context);
    final borderColor = AppColors.divider(context);

    return IntlPhoneField(
      initialCountryCode: 'GA',
      countries: countries.where((country) => country.code == 'GA').toList(),
      disableLengthCheck: true,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      validator: (phone) {
        final number = phone?.number ?? '';
        return RegExp(r'^\d{8}$').hasMatch(number) ? null : 'phone_format'.tr;
      },
      style: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      dropdownTextStyle: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      dropdownIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: secondaryColor,
        size: 18,
      ),
      cursorColor: AppColors.accent(context),
      decoration: InputDecoration(
        hintText: '77xxxxxx',
        hintStyle: GoogleFonts.inter(
          color: secondaryColor.withValues(alpha: 0.55),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        counterText: '',
        errorStyle: const TextStyle(fontSize: 11, height: 0.8),
        filled: true,
        fillColor: AppColors.surface(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.accent(context),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      onChanged: (phone) => onChanged(phone.completeNumber),
    );
  }
}
