//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Blue student row card with avatar, student name and roll number.
class StudentListTile extends StatelessWidget {
  final DepartmentStudent student;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const StudentListTile({
    super.key,
    required this.student,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: student.name,
      subtitle: student.rollNumber,
      leading: Container(
        width: 47,
        height: 47,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 0.8),
          image: DecorationImage(
            image: AssetImage(student.imageUrl ?? 'assets/images/student.png'),
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