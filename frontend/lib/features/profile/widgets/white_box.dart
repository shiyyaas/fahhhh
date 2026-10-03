import 'package:flutter/material.dart';

// Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';


class WhiteBox extends StatelessWidget {

  final IconData icon;
  final String title;

  final bool showArrow;

  final bool showSwitch;
  final bool switchValue;

  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitchChanged;

  const WhiteBox({

    super.key,

    required this.icon,
    required this.title,

    this.showArrow = false,

    this.showSwitch = false,
    this.switchValue = false,

    this.onTap,
    this.onSwitchChanged,

  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.uploadSurface,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.headingText,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            if (showSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: AppColors.primary,
                inactiveThumbColor: AppColors.smallText,
                inactiveTrackColor: AppColors.outline.withValues(alpha: 0.4),
              ),
          ],

        ),

      ),

    );

  }

}