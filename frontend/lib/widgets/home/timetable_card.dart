//Design
import 'package:fahhhh/theme_data/app_colors.dart';
import 'package:fahhhh/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/widgets/home/status_badge.dart';
import 'package:fahhhh/widgets/home/time_badge.dart';

import 'package:flutter/material.dart';

class TimetableCard extends StatelessWidget {
  final String subjectName;
  final String secondaryText;
  final AttendanceStatus status;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? profileImage;

  const TimetableCard({
    super.key,
    required this.subjectName,
    required this.secondaryText,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),

      child: 
      Row(        //MAIN ROW
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          if (profileImage != null) ...[  //FIRST ITEM
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(profileImage!),
            ),
            const SizedBox(width: 5),
          ],

        Expanded(
          child: Column(             //SECOND ITEM
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                      children: [
                          FittedBox(
                              fit: BoxFit.scaleDown, // 2. Shrinks font size if it hits the boundary
                              alignment: Alignment.centerLeft,
                              child: Text(
                                subjectName,
                                style: AppTextStyles.heading.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          Text(
                            secondaryText,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
            

            const SizedBox(width: 10),

            Column(          //THIRD ITEM
                children: [
                    TimeBadge(
                      startTime: startTime,
                      endTime: endTime,
                    ),

                    const SizedBox(height: 8),

                    StatusBadge(
                      status: status,
                    ),
                  ],
                ),
            ],
          ),
      );
  }
}
