import 'package:flutter/material.dart';

import 'app_button.dart';

class WhiteBtn extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AppButton.secondary(
      text: text,
      onPressed: onPressed,
      icon: icon,
      textStyle: textStyle,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      pressedColor: pressedColor,
      borderColor: borderColor,
      iconColor: iconColor,
      pressedIconColor: pressedIconColor,
      textColor: textColor,
      pressedTextColor: pressedTextColor,
      borderRadius: borderRadius,
      iconSize: iconSize,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      boxShadow: boxShadow,
      mainAxisAlignment: mainAxisAlignment,
    );
  }
}
