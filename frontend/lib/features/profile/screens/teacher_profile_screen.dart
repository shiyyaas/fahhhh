import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';
import 'package:fahhhh/features/department/models/department_teacher.dart';

// Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/core/network/api_endpoints.dart';

// Widgets
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

// Models
// import 'package:fahhhh/features/auth/models/current_user.dart';

/// Teacher profile view (Figma node 1651:11914).
///
/// Pushed from the bottom-profile sheet on the timetable screen, or from the
/// teacher's profile card in the main feed. Hides the bottom navigation.
///
/// Layout mirrors the Figma design: a floating circular avatar with name/role
/// underneath, two stacked white info cards, and a prominent white-outlined
/// "Time Table schedule" action pill that navigates to the teacher timetable.
class TeacherProfileScreen extends ConsumerWidget {
  final DepartmentTeacher? teacher;

  const TeacherProfileScreen({
    super.key,
    this.teacher,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final selectedTeacher = teacher;

    if (selectedTeacher == null && user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No teacher information found.'),
        ),
      );
    }

    final bool isHOD =
        selectedTeacher == null && (user?.isHOD ?? false);

    final String name =
        selectedTeacher?.name ?? user!.name;

    final String? imageUrl =
      selectedTeacher?.imageUrl ?? user?.imageUrl;

    final String resolvedImageUrl =
        ApiEndpoints.resolveUrl(imageUrl);

    final String designation = selectedTeacher != null
        ? 'Faculty'
        : (user!.designation ??
            (isHOD ? 'Head Of Department' : 'Assistant Professor'));

    final String staffId =
        selectedTeacher?.employeeId ??
        (user?.assignedClassId != null
            ? 'TCH2024-${user!.assignedClassId.hashCode % 1000}'
            : 'TCH2024-012');

    final String department = selectedTeacher != null
        ? 'Department of Computer Science'
        : (user!.departmentId ?? 'Department of Computer Science');

    final String email =
        selectedTeacher?.email ?? user!.email;

    final String phone = selectedTeacher?.phoneNo ??
        (user!.phone.isEmpty ? '—' : user.phone);

    final String classText = selectedTeacher != null
        ? '—'
        : (user!.assignedClassId ?? user.className ?? 'S2 BCA');

    final String subjectsText = selectedTeacher != null
    ? (selectedTeacher.subjects.isNotEmpty
        ? selectedTeacher.subjects.join(', ')
        : 'No subjects assigned')
    : ((user!.activeSubjects?.isNotEmpty ?? false)
        ? user.activeSubjects!.join(', ')
        : 'No subjects assigned');

    return Scaffold(
      body: AppScreenScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppBackHeader(
                title: 'Teacher Profile',
                onBack: () {
                  if (context.mounted) context.pop();
                },
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),

              // Avatar + name block.
              // Centered horizontally, avatar overlaps the info cards below.
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 99,
                      height: 99,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: resolvedImageUrl.isNotEmpty
                          ? Image.network(
                              resolvedImageUrl,
                              width: 99,
                              height: 99,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildInitialAvatar(name);
                              },
                            )
                          : _buildInitialAvatar(name),
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
                      staffId,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                // 30.5px horizontal margin → 341px content box on a 402px
                // canvas, so the button and cards share the same length.
                padding: const EdgeInsets.symmetric(horizontal: 30.5),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Primary action button — white outlined pill, sitting at
                    // the top (below the avatar, above the info cards).
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) context.push('/timetable?mode=teacher');
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
                        child: Text(
                          'Time Table schedule',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoCard(
                      items: [
                        _InfoItem(icon: Icons.mail_outline_rounded, label: 'Email', value: email),
                        _InfoItem(icon: Icons.phone_outlined, label: 'Phone', value: phone),
                        _InfoItem(icon: Icons.business_outlined, label: 'Department', value: department),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      items: [
                        _InfoItem(icon: Icons.groups_outlined, label: 'Class', value: classText),
                        _InfoItem(icon: Icons.book_outlined, label: 'Subjects', value: subjectsText),
                        _InfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Semester',
                          value: selectedTeacher == null
                          ? (user!.semester ?? '—')
                          : '—',
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

/// Builds a circular avatar with the teacher's initials, used as a fallback
/// when the image URL is empty or fails to load.
Widget _buildInitialAvatar(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  final initials = parts.isEmpty || parts.first.isEmpty
      ? '?'
      : parts.length > 1
          ? '${parts.first[0]}${parts[1][0]}'.toUpperCase()
          : parts.first.substring(
              0,
              parts.first.length >= 2 ? 2 : 1,
            ).toUpperCase();

  final colors = [
    Color(0xFFE3EAFE),
    Color(0xFFFCE4EC),
    Color(0xFFE0F2F1),
    Color(0xFFFFF3E0),
    Color(0xFFEDE7F6),
    Color(0xFFE8F5E9),
  ];

  final color = colors[name.hashCode.abs() % colors.length];

  return Container(
    color: color,
    alignment: Alignment.center,
    child: Text(
      initials,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade800,
      ),
    ),
  );
}

/// A single info row inside [_InfoCard]: circular icon + label/value pair.
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Reusable white info card with a thin divider between rows.
///
/// Matches the Figma "Container" nodes (1651:11915 / 1651:11942):
/// white surface, black border, drop shadow, 14px radius, 360px width.
class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                child: _InfoRow(item: item),
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

class _InfoRow extends StatelessWidget {
  final _InfoItem item;

  const _InfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: item.value.isEmpty
              ? Text(
                  item.label,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item.value,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
