//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

import 'package:flutter/material.dart';

/// Teacher home subject card: floating period pill, status pill,
/// subject/class names, segmented period bar (Period 1..5) and an
/// overall Present/Absent/Late/Total bar.
class TeacherSubjectCard extends StatelessWidget {
  final String subjectName;
  final String className;
  final String periodText;
  final String statusText;
  final int periodFilled;
  final double attendanceFill;
  final VoidCallback? onTap;

  const TeacherSubjectCard({
    super.key,
    required this.subjectName,
    required this.className,
    required this.periodText,
    required this.statusText,
    this.periodFilled = 3,
    this.attendanceFill = 0.27,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = SizedBox(
      height: 152,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          Positioned(
            top: 22,
            left: 0,
            right: 0,
            height: 109,
            child: Container(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 6,
                bottom: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name + status pill
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            subjectName,
                            style: AppTextStyles.heading.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(statusText: statusText),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    className,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Segmented period bar
                  _SegmentedBar(filledCount: periodFilled),
                  const SizedBox(height: 2),
                  const _LabelsRow(
                    labels: ['Period 1', 'Period 2', 'Period 3', 'Period 4', 'Period 5'],
                  ),
                  const SizedBox(height: 3),
                  // Overall progress bar
                  _ProgressBar(fill: attendanceFill),
                  const SizedBox(height: 2),
                  const _LabelsRow(
                    labels: ['Present', 'Absent', 'Late', 'Total'],
                  ),
                ],
              ),
            ),
          ),
          // Floating period pill
          Positioned(
            top: 0,
            left: 18,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    periodText,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }
}

class _StatusPill extends StatelessWidget {
  final String statusText;
  const _StatusPill({required this.statusText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            style: AppTextStyles.sfPRO.copyWith(
              color: const Color(0xFF364153),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.insights_outlined,
            color: Color(0xFF364153),
            size: 12,
          ),
        ],
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  final int filledCount;
  const _SegmentedBar({required this.filledCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 4 ? 0 : 3),
              decoration: BoxDecoration(
                color: index < filledCount
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double fill;
  const _ProgressBar({required this.fill});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 12,
        width: double.infinity,
        child: Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.3)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fill.clamp(0.0, 1.0),
              child: Container(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelsRow extends StatelessWidget {
  final List<String> labels;
  const _LabelsRow({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Text(
              label,
              style: AppTextStyles.sfPRO.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
          .toList(),
    );
  }
}
