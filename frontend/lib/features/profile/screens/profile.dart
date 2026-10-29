import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';

// Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';

// Models
import 'package:fahhhh/features/auth/models/user_role.dart';

// Widgets
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/blue_btn.dart';

// Local state provider for notifications
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    // Fallback if not authenticated
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No authenticated user session found.'),
        ),
      );
    }

    final isTeacher = user.role == UserRole.teacher;

    // Common values depending on role
    final String name = user.name;
    final String imageUrl = user.imageUrl ?? (isTeacher ? 'assets/images/teacher.png' : 'assets/images/student.png');
    final String designation = isTeacher
        ? (user.isHOD ? "Head Of Department" : "Assistant Professor")
        : (user.className ?? "S2 BCA");
    final String identifier = isTeacher
        ? (user.assignedClassId != null ? 'TCH2024-${user.assignedClassId.hashCode % 1000}' : 'TCH2024-012')
        : (user.rollNumber ?? '21/BCA/04');
    final String department =
        user.departmentId ?? "Department of Computer Science";
    final String email = user.email;
    final String phone = user.phone.isEmpty ? '—' : user.phone;
    final String classText = user.assignedClassId ?? user.className ?? 'S2 BCA';
    final String subjectsText = (user.activeSubjects?.isNotEmpty ?? false)
        ? user.activeSubjects!.join(', ')
        : 'Python, Software Engineering';

    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      body: AppScreenScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title matching teacher/student profile screens
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar + name block (centered, 99x99 circle)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 99,
                      height: 99,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1),
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      designation,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      identifier,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Content container width matching other profiles (horizontal: 30.5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.5),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Edit Profile action button — white outlined pill
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) context.push('/profile/edit');
                      },
                      child: Container(
                        width: double.infinity,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit, size: 16, color: AppColors.headingText),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Profile',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.headingText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DETAILS CARD 1
                    _InfoCard(
                      items: [
                        _InfoItem(icon: Icons.mail_outline_rounded, label: 'Email', value: email),
                        _InfoItem(icon: Icons.phone_outlined, label: 'Phone', value: phone),
                        _InfoItem(icon: Icons.business_outlined, label: 'Department', value: department),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DETAILS CARD 2
                    _InfoCard(
                      items: [
                        _InfoItem(icon: Icons.groups_outlined, label: 'Class', value: classText),
                        _InfoItem(icon: Icons.book_outlined, label: 'Subjects', value: subjectsText),
                        _InfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Semester',
                          value: user.semester?.toString() ?? '2',
                        ),
                        if (!isTeacher && user.rollNumber != null)
                          _InfoItem(
                            icon: Icons.badge_outlined,
                            label: 'Roll Number',
                            value: user.rollNumber!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SETTINGS CARD
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: isTeacher ? Icons.access_time_outlined : Icons.calendar_month_rounded,
                          label: isTeacher ? 'Timetable Settings' : 'Attendance History',
                          value: '',
                          showArrow: true,
                          onTap: () {
                            if (!context.mounted) return;
                            context.push(isTeacher ? '/timetable' : '/attendance-history');
                          },
                        ),
                        _InfoItem(
                          icon: Icons.notifications_none_outlined,
                          label: 'Notifications',
                          value: '',
                          showSwitch: true,
                          switchValue: notificationsEnabled,
                          onSwitchChanged: (value) {
                            ref.read(notificationsEnabledProvider.notifier).state = value;
                          },
                        ),
                        _InfoItem(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          value: '',
                          showArrow: true,
                        ),
                        _InfoItem(
                          icon: Icons.settings_outlined,
                          label: 'App Settings',
                          value: '',
                          showArrow: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // LOGOUT BUTTON
                    BlueBtn(
                      text: "Logout",
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).logout();
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      mainAxisAlignment: MainAxisAlignment.center,
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

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool showSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.showArrow = false,
    this.showSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
  });
}

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
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
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
                        child: item.value.isEmpty
                            ? Text(
                                item.label,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.headingText,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: AppTextStyles.small.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    item.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.headingText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (item.showArrow)
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      if (item.showSwitch)
                        Switch(
                          value: item.switchValue,
                          onChanged: item.onSwitchChanged,
                          activeThumbColor: AppColors.primary,
                          inactiveThumbColor: AppColors.smallText,
                          inactiveTrackColor: AppColors.outline.withValues(alpha: 0.4),
                        ),
                    ],
                  ),
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
