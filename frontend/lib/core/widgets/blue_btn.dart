import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_text_styles.dart';

class BlueBtn extends StatefulWidget {
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

  const BlueBtn({
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
  });

  @override
  State<BlueBtn> createState() => _BlueBtnState();
}

class _BlueBtnState extends State<BlueBtn> {
  bool isPressed = false;

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
          color: isPressed
              ? (widget.pressedColor ??
                    AppColors.primary.withValues(alpha: 0.85))
              : (widget.backgroundColor ?? AppColors.primary),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          border: Border.all(color: widget.borderColor ?? AppColors.primary),
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
          mainAxisAlignment: widget.mainAxisAlignment ??
                (widget.icon != null
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center),
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: widget.iconSize,
                color: isPressed
                    ? (widget.pressedIconColor ?? Colors.white70)
                    : (widget.iconColor ?? Colors.white),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              widget.text,
              style: (widget.textStyle ?? AppTextStyles.heading).copyWith(
                color: isPressed
                    ? (widget.pressedTextColor ?? Colors.white70)
                    : (widget.textColor ?? Colors.white),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
