import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_radius.dart';
import '../theme_data/app_text_styles.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? pressedColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? pressedIconColor;
  final Color? textColor;
  final Color? pressedTextColor;
  final double? borderRadius;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final MainAxisAlignment? mainAxisAlignment;
  final AppButtonVariant variant;

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.textStyle,
    this.height,
    this.width,
    this.backgroundColor,
    this.pressedColor,
    this.borderColor,
    this.iconColor,
    this.pressedIconColor,
    this.textColor,
    this.pressedTextColor,
    this.borderRadius,
    this.iconSize,
    this.padding,
    this.boxShadow,
    this.mainAxisAlignment,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.textStyle,
    this.height,
    this.width,
    this.backgroundColor,
    this.pressedColor,
    this.borderColor,
    this.iconColor,
    this.pressedIconColor,
    this.textColor,
    this.pressedTextColor,
    this.borderRadius,
    this.iconSize,
    this.padding,
    this.boxShadow,
    this.mainAxisAlignment,
  }) : variant = AppButtonVariant.secondary;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isPressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.backgroundColor ?? Colors.white;
      case AppButtonVariant.primary:
        return widget.backgroundColor ?? AppColors.primary;
    }
  }

  Color get _pressedColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.pressedColor ?? Colors.grey.shade200;
      case AppButtonVariant.primary:
        return widget.pressedColor ?? AppColors.primary.withValues(alpha: 0.85);
    }
  }

  Color get _borderColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.borderColor ?? AppColors.border;
      case AppButtonVariant.primary:
        return widget.borderColor ?? AppColors.primary;
    }
  }

  Color get _iconColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.iconColor ?? Colors.black;
      case AppButtonVariant.primary:
        return widget.iconColor ?? Colors.white;
    }
  }

  Color get _pressedIconColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.pressedIconColor ?? Colors.black54;
      case AppButtonVariant.primary:
        return widget.pressedIconColor ?? Colors.white70;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.textColor ?? Colors.black;
      case AppButtonVariant.primary:
        return widget.textColor ?? Colors.white;
    }
  }

  Color get _pressedTextColor {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return widget.pressedTextColor ?? Colors.black54;
      case AppButtonVariant.primary:
        return widget.pressedTextColor ?? Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: widget.height,
        width: widget.width,
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isPressed ? _pressedColor : _backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadius.medium),
          border: Border.all(color: _borderColor),
          boxShadow:
              widget.boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              widget.mainAxisAlignment ??
              (widget.icon != null
                  ? MainAxisAlignment.spaceAround
                  : MainAxisAlignment.center),
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: widget.iconSize,
                color: isPressed ? _pressedIconColor : _iconColor,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              widget.text,
              style: (widget.textStyle ?? AppTextStyles.heading).copyWith(
                color: isPressed ? _pressedTextColor : _textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
