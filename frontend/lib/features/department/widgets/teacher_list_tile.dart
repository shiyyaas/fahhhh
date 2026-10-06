//Design
//Models
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/features/department/models/department_teacher.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Blue teacher row card with avatar, teacher name and subject.
class TeacherListTile extends StatelessWidget {
  final DepartmentTeacher teacher;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const TeacherListTile({
    super.key,
    required this.teacher,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: teacher.name,
      subtitle: teacher.subject,
      leading: Container(
        width: 47,
        height: 47,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 0.8),
          image: DecorationImage(
            image: AssetImage(teacher.imageUrl ?? 'assets/images/teacher.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      borderRadius: 20,
      padding: const EdgeInsets.only(left: 11, right: 12),
    );
  }
}
