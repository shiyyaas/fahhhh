//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/home/widgets/status_badge.dart';
import 'package:fahhhh/features/home/widgets/time_badge.dart';

import 'package:flutter/material.dart';

class TimetableCard extends StatefulWidget {
  final String subjectName;
  final String secondaryText;
  final AttendanceStatus status;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? profileImage;
  final bool isStudent;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const TimetableCard({
    super.key,
    required this.subjectName,
    required this.secondaryText,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.profileImage,
    required this.isStudent,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  @override
  State<TimetableCard> createState() => _TimetableCardState();
}

class _TimetableCardState extends State<TimetableCard> {
  bool _expanded = false;

  bool get _canExpand =>
      widget.isStudent && widget.status == AttendanceStatus.absent;

  void _handleTap() {
    if (_canExpand) {
      setState(() {
        _expanded = !_expanded;
      });
      return;
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 11,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Text metadata (Subject Name & Teacher or Class Batch)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.subjectName,
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.white,
                          fontSize: 16.6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.secondaryText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Right side: Time Badge and Status Badge
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TimeBadge(
                    startTime: widget.startTime,
                    endTime: widget.endTime,
                    isToday: widget.isToday,
                  ),
                  if (!widget.isFuture) ...[
                    const SizedBox(height: 5),
                    StatusBadge(
                      status: widget.status,
                    ),
                  ],
                ],
              ),

              // Far Right: Student Profile Photo (Only for student and when profileImage is provided)
              if (widget.isStudent && widget.profileImage != null) ...[
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(widget.profileImage!),
                ),
              ],
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            _ReportButton(),
          ],
        ],
      ),
    );

    if (_canExpand || widget.onTap != null) {
      return GestureDetector(
        onTap: _handleTap,
        child: card,
      );
    }

    return card;
  }
}

class _ReportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFFF2626).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          'Report',
          style: AppTextStyles.sfPRO.copyWith(
            color: const Color(0xFFE9E9E9),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
