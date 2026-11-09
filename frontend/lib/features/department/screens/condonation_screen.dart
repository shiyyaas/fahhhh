import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/condonation_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';

//Providers
import 'package:fahhhh/features/department/providers/department_provider.dart';

/// Condonation Report: a searchable roster of students whose attendance is below 75% (< 75%),
/// fetched from backend defaulters endpoint (`GET /api/attendance/defaulters`).
class CondonationScreen extends ConsumerStatefulWidget {
  const CondonationScreen({super.key});

  @override
  ConsumerState<CondonationScreen> createState() => _CondonationScreenState();
}

class _CondonationScreenState extends ConsumerState<CondonationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Roll No';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultersAsync = ref.watch(defaultersProvider);
    final List<_CondonationEntry> students = defaultersAsync.maybeWhen(
      data: (defaulters) {
        return defaulters.map((d) {
          final percent = double.tryParse(d['attendancePercentage']?.toString() ?? '0')?.round() ?? 0;
          return _CondonationEntry(
            student: DepartmentStudent(
              id: d['studentId']?.toString(),
              name: d['studentName']?.toString() ?? 'Student',
              rollNumber: d['registerNo']?.toString() ?? '',
            ),
            percent: percent,
          );
        }).toList();
      },
      orElse: () => const [],
    );
    final query = _query.trim().toLowerCase();
    var visible = students
        .where((s) =>
            query.isEmpty ||
            s.student.name.toLowerCase().contains(query) ||
            s.student.rollNumber.toLowerCase().contains(query))
        .toList();

    visible = _sort(visible, _sortOption);

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 8),
            AppBackHeader(
              title: 'Check Condonation',
              subtitle: 'Students with attendance below 75%',
              onBack: () {
                if (context.mounted) context.pop();
              },
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SortDropdown(
                    value: _sortOption,
                    onChanged: (value) => setState(() => _sortOption = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: visible.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 40),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final entry = visible[index];
                        return StudentListTile(
                          student: entry.student,
                          trailing:
                              CondonationPercentageBadge(percent: entry.percent),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_CondonationEntry> _sort(
      List<_CondonationEntry> entries, String option) {
    final sorted = List<_CondonationEntry>.from(entries);
    switch (option) {
      case 'Highest':
        sorted.sort((a, b) => b.percent.compareTo(a.percent));
      case 'Lowest':
        sorted.sort((a, b) => a.percent.compareTo(b.percent));
      default:
        // 'Roll No' — keep natural order.
    }
    return sorted;
  }
}

class _CondonationEntry {
  final DepartmentStudent student;
  final int percent;

  const _CondonationEntry({required this.student, required this.percent});
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No students with condonation shortage (< 75%)',
        style: AppTextStyles.small.copyWith(fontSize: 15),
      ),
    );
  }
}
