//Design
//Models
import 'package:fahhhh/features/my_subjects/models/my_subject_item.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

import 'package:flutter/material.dart';

/// Subject row card for My Subjects screen: subject name, classes, attendance pill.
class MySubjectListTile extends StatelessWidget {
  final MySubjectItem item;
  final VoidCallback? onTap;

  const MySubjectListTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DirectoryListTile(
      title: item.name,
      subtitle: item.classes,
      trailing: AttendancePercentageBadge(percent: item.attendancePercent),
      onTap: onTap,
      borderRadius: 17,
    );
  }
}
