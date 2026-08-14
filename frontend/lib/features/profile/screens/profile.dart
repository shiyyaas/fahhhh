import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

// Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';

// Models
import 'package:fahhhh/features/auth/models/user_role.dart';

// Widgets
import 'package:fahhhh/core/widgets/white_btn.dart';
import 'package:fahhhh/core/widgets/blue_btn.dart';
import 'package:fahhhh/features/profile/widgets/white_box.dart';

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
    final String? imageUrl = user.imageUrl;
    final String subTitle = isTeacher
        ? (user.isHOD ? "Head Of Department" : "Assistant Professor")
        : (user.className ?? "S2 BCA");
    final String department = user.departmentId ?? "Department of Computer Science";
    final String email = user.email;
    final String phone = user.phone;

    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: imageUrl != null
                          ? AssetImage(imageUrl)
                          : null,
                      child: imageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subTitle,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      department,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              WhiteBtn(
                text: "Edit Profile",
                icon: Icons.edit,
                onPressed: () {
                  context.go('/profile/edit');
                },
                width: double.infinity,
                borderRadius: 50,
                iconSize: 16,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              const SizedBox(height: 25),

              // DETAILS CONTAINER
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    WhiteBox(icon: Icons.email_outlined, title: email),
                    _divider(),
                    WhiteBox(icon: Icons.phone_outlined, title: phone),
                    _divider(),
                    WhiteBox(
                      icon: Icons.school_outlined,
                      title: department,
                    ),

                    // Teacher-only fields
                    if (isTeacher) ...[
                      if (user.isClassTeacher) ...[
                        _divider(),
                        WhiteBox(
                          icon: Icons.groups_outlined,
                          title: user.assignedClassId ?? "S2 BCA",
                        ),
                      ],
                      if (user.isHOD) ...[
                        _divider(),
                        WhiteBox(
                          icon: Icons.admin_panel_settings_outlined,
                          title: "Head Of Department",
                        ),
                      ],
                      if (user.activeSubjects != null && user.activeSubjects!.isNotEmpty) ...[
                        _divider(),
                        WhiteBox(
                          icon: Icons.book_outlined,
                          title: "Subjects: ${user.activeSubjects!.join(', ')}",
                        ),
                      ],
                    ],

                    // Student-only fields
                    if (!isTeacher) ...[
                      _divider(),
                      WhiteBox(
                        icon: Icons.badge_outlined,
                        title: user.rollNumber ?? "21/BCA/04",
                      ),
                      _divider(),
                      WhiteBox(
                        icon: Icons.calendar_today_outlined,
                        title: "Semester ${user.semester ?? '2'}",
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SETTINGS CONTAINER (same for both roles)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    WhiteBox(
                      icon: Icons.access_time_outlined,
                      title: "Timetable Settings",
                      showArrow: true,
                      onTap: () {
                        if (!context.mounted) return;
                        context.push('/timetable');
                      },
                    ),
                    _divider(),
                    WhiteBox(
                      icon: Icons.notifications_none_outlined,
                      title: "Notifications",
                      showSwitch: true,
                      switchValue: notificationsEnabled,
                      onSwitchChanged: (value) {
                        ref.read(notificationsEnabledProvider.notifier).state = value;
                      },
                    ),
                    _divider(),
                    WhiteBox(
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      showArrow: true,
                    ),
                    _divider(),
                    WhiteBox(
                      icon: Icons.settings_outlined,
                      title: "App Settings",
                      showArrow: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _divider() {
  return Divider(height: 1, color: Colors.grey.shade300);
}
