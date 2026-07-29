import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme_data/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isTeacher = auth.role == UserRole.teacher;

    final String name = user?.name ?? '';
    final String subTitle = isTeacher
        ? ((user?.isHOD ?? false) ? 'HOD - ${user?.departmentId ?? "Department of Computer Science"}' : (user?.designation ?? "Assistant Professor"))
        : (user?.className ?? 'S2 BCA');
    final String? imageUrl = user?.imageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              image: imageUrl != null ? DecorationImage(
                image: AssetImage(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: imageUrl == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading.copyWith(
                    height: 0.9,
                  ),
                ),
                Text(
                  subTitle,
                  style: AppTextStyles.small.copyWith(
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4A7DFF),
                  Color(0xFF1B3EA7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
