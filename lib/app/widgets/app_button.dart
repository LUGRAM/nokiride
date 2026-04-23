import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String            label;
  final VoidCallback?     onTap;
  final bool              loading;
  final AppButtonVariant  variant;
  final IconData?         icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bgColor = switch (variant) {
      AppButtonVariant.primary  => scheme.primary,
      AppButtonVariant.outline  => Colors.transparent,
      AppButtonVariant.ghost    => Colors.transparent,
    };

    final fgColor = switch (variant) {
      AppButtonVariant.primary  => scheme.onPrimary,
      AppButtonVariant.outline  => scheme.primary,
      AppButtonVariant.ghost    => scheme.primary,
    };

    final side = variant == AppButtonVariant.outline
        ? BorderSide(color: scheme.primary, width: 1.5)
        : BorderSide.none;

    return SizedBox(
      height: 52,
      width:  double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: scheme.primary.withValues(alpha: .45),
          elevation:    0,
          shadowColor:  Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: side,
          ),
        ),
        onPressed: loading ? null : onTap,
        child: loading
            ? SizedBox(
                width:  18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisSize:     MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize:   15,
                      color:      fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum AppButtonVariant { primary, outline, ghost }
