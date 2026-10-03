import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';

// Models
import 'package:fahhhh/features/profile/models/student_profile.dart';

// Widgets
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

// Models
// import 'package:fahhhh/features/profile/widgets/info_card.dart';

/// Student profile view (Figma node 1651:11914).
///
/// Mirrors the teacher profile design: a circular avatar with name/class/roll
/// underneath, two stacked white info cards, and an "Attendance history"
/// action pill that navigates to the student attendance history.
///
/// Pushed from a student card (hides bottom navigation).
class StudentProfileScreen extends StatelessWidget {
  final StudentProfile profile;

  const StudentProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final String className = profile.className;
    final String rollNumber = profile.rollNumber;

    return Scaffold(
      body: AppScreenScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppBackHeader(
                title: 'Profile',
                subtitle: className,
                onBack: () {
                  if (context.mounted) context.pop();
                },
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),

              // Avatar + name block.
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 99,
                      height: 99,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/student.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      className,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rollNumber,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Stacked cards: action button on top, then the two info cards
              // overlapping the bottom of the avatar circle (same stack as the
              // teacher profile, with "Attendance history" in place of the
              // "Time Table schedule" action).
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) context.push('/attendance-history');
                      },
                      child: Container(
                        height: 39,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.border, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Attendance history',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: Icons.mail_outline_rounded,
                          value: profile.email,
                        ),
                        _InfoItem(
                          icon: Icons.phone_outlined,
                          value: profile.phone,
                        ),
                        _InfoItem(
                          icon: Icons.business_outlined,
                          value: 'Department of Computer Science',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: Icons.groups_outlined,
                          value: className,
                        ),
                        _InfoItem(
                          icon: Icons.book_outlined,
                          value: 'Python, Software Engineering',
                        ),
                        _InfoItem(
                          icon: Icons.calendar_today_outlined,
                          value: 'Semester ${profile.semester ?? 2}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single info row inside [_InfoCard]: circular icon + value text.
class _InfoItem {
  final IconData icon;
  final String value;

  const _InfoItem({required this.icon, required this.value});
}

/// Reusable white info card with a thin divider between rows.
///
/// Matches the Figma "Container" nodes: white surface, black border, drop
/// shadow, card radius — same as the teacher profile screen.
class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 341,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.uploadSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 14,
                          color: AppColors.headingText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],
          );
        }),
      ),
    );
  }
}
