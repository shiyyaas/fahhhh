//Design
//Models
import 'package:fahhhh/features/department/models/department_subject.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Blue subject row card with teacher avatar, subject name, teacher name and attendance pill.
class SubjectListTile extends StatelessWidget {
  final DepartmentSubject subject;
  final VoidCallback? onTap;

  const SubjectListTile({
    super.key,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: subject.name,
      subtitle: subject.teacher,
      leading: Container(
        width: 47,
        height: 47,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFF141212), width: 0.8),
          image: const DecorationImage(
            image: AssetImage('assets/images/teacher.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      trailing: AttendancePercentageBadge(percent: subject.attendancePercent),
      onTap: onTap,
      borderRadius: 20,
    );
  }
}
