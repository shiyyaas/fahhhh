// Designs
import 'package:fahhhh/theme_data/app_colors.dart';
import 'package:fahhhh/theme_data/app_text_styles.dart';

import 'package:flutter/material.dart';

class WhiteBtn extends StatefulWidget {

  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final TextStyle? textStyle;

  const WhiteBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.textStyle,
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
        setState(() {
          isPressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });

        widget.onPressed();
      },

      onTapCancel: () {
        setState(() {
          isPressed = false;
        });

      },

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: isPressed
              ? Colors.grey.shade200
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),

          boxShadow: [
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
              widget.icon != null
                  ? MainAxisAlignment.spaceAround
                  : MainAxisAlignment.center,
          children: [

            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: isPressed
                    ? Colors.black54
                    : Colors.black,
              ),
              const SizedBox(width: 10),
            ],

            Text(
              widget.text,
              style: (widget.textStyle ?? AppTextStyles.heading).copyWith(
                color: isPressed
                    ? Colors.black54
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}