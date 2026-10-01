//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

import 'package:flutter/material.dart';

/// Condonation-register percentage pill (green for >=75%, purple for <75%).
///
/// Distinct from [AttendancePercentageBadge] in `attendance_percentage_badge.dart`
/// because the Condonation Register Figma (node 1487-5238) uses a purple
/// "needs-attention" state instead of the app's standard danger-red.
class CondonationPercentageBadge extends StatelessWidget {
  final int percent;
  const CondonationPercentageBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final bool isGood = percent >= 75;

    return Container(
      width: 85,
      height: 28,
      decoration: BoxDecoration(
        color: isGood
            ? AppColors.condonationGood.withValues(alpha: 0.6)
            : AppColors.condonationBad.withValues(alpha: 0.5),
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
            color: isGood
                ? AppColors.condonationGoodLight
                : AppColors.condonationBadText,
          ),
        ),
      ),
    );
  }
}
