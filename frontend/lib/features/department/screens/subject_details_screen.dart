import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

/// Subject settings details screen: delete, save, and detail display
class SubjectSettingsDetailsScreen extends StatelessWidget {
  final String name;
  final String teacher;
  final String rollNumber;

  const SubjectSettingsDetailsScreen({
    super.key,
    required this.name,
    required this.teacher,
    required this.rollNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            AppBackHeader(
              title: name,
              subtitle: '$teacher · $rollNumber',
              onBack: () => context.pop(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject Details',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Name: $name',
                    style: AppTextStyles.small.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Teacher: $teacher',
                    style: AppTextStyles.small.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Roll Number: $rollNumber',
                    style: AppTextStyles.small.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Attendance: 92%',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
