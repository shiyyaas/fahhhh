//Design
//Models
import 'package:fahhhh/features/department/models/department_student.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Blue student row card with avatar, name, roll number and attendance pill.
class StudentListTile extends StatelessWidget {
  final DepartmentStudent student;
  final VoidCallback? onTap;

  const StudentListTile({
    super.key,
    required this.student,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: student.name,
      subtitle: student.rollNumber,
      leading: Container(
        width: 49,
        height: 49,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          image: const DecorationImage(
            image: AssetImage('assets/images/student.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      trailing: AttendancePercentageBadge(percent: student.attendancePercent),
      onTap: onTap,
      borderRadius: 20,
    );
  }
}
