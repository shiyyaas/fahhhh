import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';

enum DetailActionButtonVariant { primary, danger, secondary }

/// Standard full-height pill action button used on entity detail screens
/// (e.g., Save, Edit, Delete).
///
/// Follows design.md guidelines:
/// - 44px height for reliable mobile touch target
/// - Pill geometry (AppRadius.pill = 30)
/// - Bold typography and semantic color tokens
/// - Tactile pressed-state feedback
class DetailActionButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final DetailActionButtonVariant variant;

  const DetailActionButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.variant = DetailActionButtonVariant.primary,
  });

  const DetailActionButton.primary({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  }) : variant = DetailActionButtonVariant.primary;

  const DetailActionButton.danger({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  }) : variant = DetailActionButtonVariant.danger;

  const DetailActionButton.secondary({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  }) : variant = DetailActionButtonVariant.secondary;

  @override
  State<DetailActionButton> createState() => _DetailActionButtonState();
}

class _DetailActionButtonState extends State<DetailActionButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case DetailActionButtonVariant.primary:
        return _isPressed
            ? AppColors.primary.withValues(alpha: 0.85)
            : AppColors.primary;
      case DetailActionButtonVariant.danger:
        return _isPressed ? const Color(0xFFD32F2F) : const Color(0xFFEB2E2E);
      case DetailActionButtonVariant.secondary:
        return _isPressed ? const Color(0xFFF1F5F9) : Colors.white;
    }
  }

  Color get _borderColor {
    switch (widget.variant) {
      case DetailActionButtonVariant.primary:
        return AppColors.primary;
      case DetailActionButtonVariant.danger:
        return const Color(0xFFEB2E2E);
      case DetailActionButtonVariant.secondary:
        return AppColors.outline;
    }
  }

  Color get _contentColor {
    switch (widget.variant) {
      case DetailActionButtonVariant.primary:
      case DetailActionButtonVariant.danger:
        return Colors.white;
      case DetailActionButtonVariant.secondary:
        return AppColors.headingText;
    }
  }

  List<BoxShadow> get _boxShadow {
    switch (widget.variant) {
      case DetailActionButtonVariant.primary:
        return [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ];
      case DetailActionButtonVariant.danger:
        return [
          BoxShadow(
            color: const Color(0xFFEB2E2E).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ];
      case DetailActionButtonVariant.secondary:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: _borderColor,
              width: 1.2,
            ),
            boxShadow: _boxShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: _contentColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
