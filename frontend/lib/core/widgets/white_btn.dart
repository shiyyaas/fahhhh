// Designs
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:flutter/material.dart';


class WhiteBtn extends StatefulWidget {
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


  const WhiteBtn({
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
  State<WhiteBtn> createState() => _WhiteBtnState();

}



class _WhiteBtnState extends State<WhiteBtn> {

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
        padding: widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
        decoration: BoxDecoration(
          color: isPressed
              ? (widget.pressedColor ?? Colors.grey.shade200)
              : (widget.backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          border: Border.all(
            color: widget.borderColor ?? AppColors.border,
          ),
          boxShadow: widget.boxShadow ??
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
                    ? (widget.pressedIconColor ?? Colors.black54)
                    : (widget.iconColor ?? Colors.black),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              widget.text,
              style: (widget.textStyle ?? AppTextStyles.heading).copyWith(
                color: isPressed
                    ? (widget.pressedTextColor ?? Colors.black54)
                    : (widget.textColor ?? Colors.black),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}