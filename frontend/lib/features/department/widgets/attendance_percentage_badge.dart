//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

import 'package:flutter/material.dart';

/// Green / red attendance percentage pill (95% or 65% style).
class AttendancePercentageBadge extends StatelessWidget {
  final int percent;
  const AttendancePercentageBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final bool isGood = percent >= 75;

    return Container(
      width: 85,
      height: 28,
      decoration: BoxDecoration(
        color: isGood
            ? const Color(0x996BDB72)
            : const Color(0x80D26688),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '$percent%',
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isGood ? const Color(0xFF9EEDBB) : const Color(0xFFFFCDCE),
          ),
        ),
      ),
    );
  }
}
