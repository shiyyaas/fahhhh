//Design
//Models
import 'package:fahhhh/features/department/models/department_class.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Blue class row card with class name, class teacher and attendance pill.
class ClassListTile extends StatelessWidget {
  final DepartmentClass data;
  final VoidCallback? onTap;

  const ClassListTile({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: data.name,
      subtitle: data.classTeacher,
      trailing: AttendancePercentageBadge(percent: data.attendancePercent),
      onTap: onTap,
      borderRadius: 17,
    );
  }
}
