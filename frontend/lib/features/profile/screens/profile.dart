import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

// Providers
import 'package:fahhhh/features/profile/provider/teacher_provider.dart';
import 'package:fahhhh/features/auth/providers/auth_provider.dart';

// Routes
import 'package:fahhhh/core/routes/app_routes.dart';

// Widgets
import 'package:fahhhh/core/widgets/white_btn.dart';
import 'package:fahhhh/core/widgets/blue_btn.dart';
import 'package:fahhhh/features/profile/widgets/white_box.dart';

class Profile extends ConsumerWidget {

  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final teacher = ref.watch(teacherProvider);
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
                      backgroundImage:
                          teacher.imageUrl != null
                              ? AssetImage(
                                  teacher.imageUrl!,
                                )
                              : null,
                      child: teacher.imageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      teacher.name,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.designation,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      teacher.department,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              WhiteBtn(
                text: "Edit Profile",
                icon: Icons.edit,
                onPressed: () {},
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
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    WhiteBox(
                      icon: Icons.email_outlined,
                      title: teacher.email,
                    ),
                    _divider(),
                    WhiteBox(
                      icon: Icons.phone_outlined,
                      title: teacher.phone,
                    ),
                    _divider(),
                    WhiteBox(
                      icon: Icons.school_outlined,
                      title: teacher.department,
                    ),
                    if (teacher.isClassTeacher) ...[
                      _divider(),
                      WhiteBox(
                        icon: Icons.groups_outlined,
                        title: teacher.classTeacherOf!,
                      ),
                    ],
                    if (teacher.isHod) ...[
                      _divider(),
                      WhiteBox(
                        icon:
                            Icons.admin_panel_settings_outlined,
                        title: "Head Of Department",
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SETTINGS CONTAINER
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    WhiteBox(
                      icon: Icons.access_time_outlined,
                      title: "Time table settings",
                      showArrow: true,
                    ),
                    _divider(),
                    WhiteBox(
                      icon:
                          Icons.notifications_none_outlined,
                      title: "Notifications",
                      showSwitch: true,
                      switchValue: true,
                      onSwitchChanged: (value) {
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
                onPressed: () {
                  ref.read(authProvider.notifier).state = false;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
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
  return Divider(
    height: 1,
    color: Colors.grey.shade300,
  );
}