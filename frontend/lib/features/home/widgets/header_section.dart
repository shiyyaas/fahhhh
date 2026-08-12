import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';
import '../../auth/models/current_user.dart';

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isTeacher = auth.role == UserRole.teacher;
    final bool isHod = user?.isHOD ?? false;
    final bool isClassTeacher = user?.isClassTeacher ?? false;

    // Regular Teacher (non-HOD, non-ClassTeacher): compact header with 4 action buttons.
    if (isTeacher && !isHod && !isClassTeacher) {
      return _buildTeacherHeader(context, ref);
    }

    // Class Teacher: header with class assignment info.
    if (isClassTeacher) {
      return _buildClassTeacherHeader(context, user);
    }

    final String name = user?.name ?? '';
    final String subTitle = isTeacher
        ? ((user?.isHOD ?? false) ? 'HOD - ${user?.departmentId ?? "Department of Computer Science"}' : (user?.designation ?? "Assistant Professor"))
        : (user?.className ?? 'S2 BCA');
    final String? imageUrl = user?.imageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
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
                    fontSize: 23,
                    height: 1.1,
                  ),
                ),
                Text(
                  subTitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientTop,
                  AppColors.gradientBottom,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherHeader(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final user = auth.user;
    final String? imageUrl = user?.imageUrl;

    Widget actionButton(IconData icon, VoidCallback onTap) {
      return Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1.5,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF364153),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
            child: imageUrl == null ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                actionButton(Icons.notifications_none_rounded, () {}),
                actionButton(Icons.badge_outlined, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leave management coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }),
                actionButton(Icons.menu_book_outlined, () {
                  context.push('/subjects');
                }),
                actionButton(Icons.person_outline, () {
                  context.push('/profile');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTeacherHeader(BuildContext context, CurrentUser? user) {
    final String? imageUrl = user?.imageUrl;
    final String className = user?.assignedClassId ?? user?.className ?? 'S2 BCA';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
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
                  user?.name ?? '',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 23,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Class Teacher - $className',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientTop,
                  AppColors.gradientBottom,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
