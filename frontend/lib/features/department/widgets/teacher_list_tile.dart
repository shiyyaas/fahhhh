
import 'package:flutter/material.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/network/api_endpoints.dart';
import 'package:fahhhh/features/department/models/department_teacher.dart';
import 'package:fahhhh/features/department/widgets/directory_list_tile.dart';

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
      leading: _TeacherAvatar(
        name: teacher.name,
        imageUrl: teacher.imageUrl,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      borderRadius: 20,
      padding: const EdgeInsets.only(left: 11, right: 12),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _TeacherAvatar({
    required this.name,
    this.imageUrl,
  });

  static const List<Color> _colors = [
    Color(0xFFE3EAFE),
    Color(0xFFFCE4EC),
    Color(0xFFE0F2F1),
    Color(0xFFFFF3E0),
    Color(0xFFEDE7F6),
    Color(0xFFE8F5E9),
    Color(0xFFFFEBEE),
  ];

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(
        0,
        parts.first.length >= 2 ? 2 : 1,
      ).toUpperCase();
    }

    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = ApiEndpoints.resolveUrl(imageUrl);
    final backgroundColor =
        _colors[name.hashCode.abs() % _colors.length];

    Widget fallback() {
      return Container(
        width: 47,
        height: 47,
        alignment: Alignment.center,
        color: backgroundColor,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
      );
    }

    return Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback(),
            )
          : fallback(),
    );
  }
}
