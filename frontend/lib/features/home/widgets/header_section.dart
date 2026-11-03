import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme_data/app_colors.dart';
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
    final bool isHod = user?.isHOD ?? false;
    final bool isClassTeacher = user?.isClassTeacher ?? false;

    final String name = user?.name ?? '';
    
    final String subTitle;
    if (isTeacher) {
      if (isHod) {
        subTitle = 'HOD - ${user?.departmentId ?? "Department of Computer Science"}';
      } else if (isClassTeacher) {
        final className = user?.assignedClassId ?? user?.className ?? 'S2 BCA';
        subTitle = 'Class Teacher - $className';
      } else {
        subTitle = user?.designation ?? "Assistant Professor";
      }
    } else {
      subTitle = user?.className ?? 'S2 BCA';
    }

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
            ),
            child: ClipOval(
              child: imageUrl != null &&
                      imageUrl.isNotEmpty &&
                      imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
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
              onPressed: () {
                context.push('/inbox');
              },
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
