import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/features/department/models/department_subject.dart';
import 'package:fahhhh/features/department/screens/add_subject_dialog.dart';
import 'package:fahhhh/features/department/screens/upload_subject_dialog.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/compact_action_button.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/subject_list_tile.dart';

class SubjectSettingsScreen extends StatefulWidget {
  const SubjectSettingsScreen({super.key});

  @override
  State<SubjectSettingsScreen> createState() => _SubjectSettingsScreenState();
}

class _SubjectSettingsScreenState extends State<SubjectSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Roll No';
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (!_selectedIndices.remove(index)) {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final subjects = mockDepartmentSubjects
        .where(
          (s) =>
              query.isEmpty ||
              s.name.toLowerCase().contains(query) ||
              s.teacher.toLowerCase().contains(query),
        )
        .toList();

    switch (_sortOption) {
      case 'Highest':
        subjects.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      case 'Lowest':
        subjects.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      default: // 'Roll No'
        subjects.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    }

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 18),
            AppBackHeader(
              title: 'Subject Settings',
              subtitle: 'Manage subject details here',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _query = val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SortDropdown(
                    value: _sortOption,
                    onChanged: (val) => setState(() => _sortOption = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  CompactActionButton(
                    icon: Icons.add_rounded,
                    label: 'Add',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const AddSubjectDialog(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CompactActionButton(
                    icon: Icons.upload_rounded,
                    label: 'Upload',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const UploadSubjectDialog(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Hold to select & delete',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectListTile(
                    subject: subject,
                    isSelected: _selectedIndices.contains(index),
                    onLongPress: () => _toggleSelection(index),
                    onTap: () => context.push(
                      '/subject-details/${Uri.encodeComponent(subject.name)}/${Uri.encodeComponent(subject.teacher)}/${Uri.encodeComponent(subject.rollNumber)}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
