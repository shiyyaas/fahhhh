//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';

//Models
import 'package:fahhhh/features/department/models/department_subject.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Blue subject row card with avatar, subject name and teacher.
class SubjectListTile extends StatelessWidget {
  final DepartmentSubject subject;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const SubjectListTile({
    super.key,
    required this.subject,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: subject.name,
      subtitle: '${subject.teacher} · ${subject.attendancePercent}%',
      leading: Container(
        width: 47,
        height: 47,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 0.8),
          image: const DecorationImage(
            image: AssetImage('assets/images/logo.png'),
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