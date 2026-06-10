import 'package:flutter/material.dart';

// Design
import 'package:fahhhh/core/theme_data/app_colors.dart';


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
      borderRadius: BorderRadius.circular(16),
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            if (showSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
              ),
          ],

        ),

      ),

    );

  }

}