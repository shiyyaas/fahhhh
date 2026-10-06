import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';

enum CompactActionButtonVariant { primary, secondary, danger }

/// Redesigned action pill button used on directory/settings screens (Add, Upload, Delete).
/// Follows design.md guidelines with bold pill styling, 38px height, and clear outline contrast.
class CompactActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final CompactActionButtonVariant variant;

  const CompactActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.variant = CompactActionButtonVariant.secondary,
  });

  const CompactActionButton.primary({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : variant = CompactActionButtonVariant.primary;

  const CompactActionButton.secondary({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : variant = CompactActionButtonVariant.secondary;

  const CompactActionButton.danger({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : variant = CompactActionButtonVariant.danger;

  @override
  State<CompactActionButton> createState() => _CompactActionButtonState();
}

class _CompactActionButtonState extends State<CompactActionButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case CompactActionButtonVariant.primary:
        return _isPressed
            ? AppColors.primary.withValues(alpha: 0.85)
            : AppColors.primary;
      case CompactActionButtonVariant.secondary:
        return _isPressed ? const Color(0xFFF1F5F9) : Colors.white;
      case CompactActionButtonVariant.danger:
        return _isPressed ? const Color(0xFFD32F2F) : const Color(0xFFEB2E2E);
    }
  }

  Color get _borderColor {
    switch (widget.variant) {
      case CompactActionButtonVariant.primary:
        return AppColors.primary;
      case CompactActionButtonVariant.secondary:
        return AppColors.outline;
      case CompactActionButtonVariant.danger:
        return const Color(0xFFEB2E2E);
    }
  }

  Color get _contentColor {
    switch (widget.variant) {
      case CompactActionButtonVariant.primary:
      case CompactActionButtonVariant.danger:
        return Colors.white;
      case CompactActionButtonVariant.secondary:
        return AppColors.headingText;
    }
  }

  List<BoxShadow> get _boxShadow {
    switch (widget.variant) {
      case CompactActionButtonVariant.primary:
        return [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      case CompactActionButtonVariant.secondary:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case CompactActionButtonVariant.danger:
        return [
          BoxShadow(
            color: const Color(0xFFEB2E2E).withValues(alpha: 0.25),
            blurRadius: 6,
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
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 38,
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
            children: [
              Icon(widget.icon, size: 17, color: _contentColor),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
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
