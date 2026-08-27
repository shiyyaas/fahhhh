import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/features/department/models/department_teacher.dart';
import 'package:fahhhh/features/department/widgets/teacher_list_tile.dart';
import 'package:fahhhh/core/widgets/functional/search_sort_bar.dart';
import 'package:fahhhh/features/department/widgets/upload_teacher_dialog.dart';
import 'package:fahhhh/features/department/widgets/add_teacher_dialog.dart';

class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  // ignore: prefer_final_fields
  Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final teachers = mockDepartmentTeachers
        .where(
          (t) =>
              query.isEmpty ||
              t.name.toLowerCase().contains(query) ||
              t.subject.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFAAA0A0)],
            stops: [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              _Header(onBack: () => context.pop()),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _query = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SortDropdown(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    _ActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Add',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddTeacherDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.upload_rounded,
                      label: 'Upload',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const UploadTeacherDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Hold to select & delete',
                    style: AppTextStyles.small.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    final isSelected = _selectedIndices.contains(index);
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      },
                      child: TeacherListTile(
                        teacher: teacher,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 26, height: 41),
            icon: const Icon(Icons.arrow_back, size: 26),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Settings',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Manage teacher details here',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1C1C21)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.heading.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
