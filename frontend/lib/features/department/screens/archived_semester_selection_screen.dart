import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_text_styles.dart';

class ArchivedSemesterSelectionScreen extends StatelessWidget {
  final String batchName;

  const ArchivedSemesterSelectionScreen({
    super.key,
    required this.batchName,
  });

  static const List<String> semesters = [
    'S1',
    'S2',
    'S3',
    'S4',
    'S5',
    'S6',
    'S7',
    'S8',
  ];

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              _Header(
                batchName: batchName,
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: semesters.map((sem) {
                    return _SemesterChip(
                      semester: sem,
                      onTap: () {
                        if (!context.mounted) return;
                        final fullClassId = '$batchName $sem';
                        context.push('/department-class/${Uri.encodeComponent(fullClassId)}');
                      },
                    );
                  }).toList(),
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
  final String batchName;
  final VoidCallback onBack;

  const _Header({
    required this.batchName,
    required this.onBack,
  });

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
                  'Select the semester',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'View previous batches Attendance & Reports',
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

class _SemesterChip extends StatelessWidget {
  final String semester;
  final VoidCallback onTap;

  const _SemesterChip({
    required this.semester,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.15),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            semester,
            style: AppTextStyles.sfPRO.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF364153),
            ),
          ),
        ),
      ),
    );
  }
}
