import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import '../../../core/widgets/app_back_header.dart';
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';

class ArchivedBatch {
  final String name;
  final String classTeacher;
  final int attendancePercent;

  const ArchivedBatch({
    required this.name,
    required this.classTeacher,
    required this.attendancePercent,
  });
}

const archivedBatches = [
  ArchivedBatch(
    name: '2024 - 28 BCA',
    classTeacher: 'Rijina N M',
    attendancePercent: 95,
  ),
  ArchivedBatch(
    name: '2023 - 27 BCA',
    classTeacher: 'Anu Varghese',
    attendancePercent: 65,
  ),
  ArchivedBatch(
    name: '2022 - 26 BCA',
    classTeacher: 'Sheetal miss',
    attendancePercent: 95,
  ),
  ArchivedBatch(
    name: '2021 - 25 BCA',
    classTeacher: 'Rijina N M',
    attendancePercent: 65,
  ),
  ArchivedBatch(
    name: '2020 - 24 BCA',
    classTeacher: 'Anu Varghese',
    attendancePercent: 95,
  ),
];

class ArchivedBatchesScreen extends StatefulWidget {
  const ArchivedBatchesScreen({super.key});

  @override
  State<ArchivedBatchesScreen> createState() => _ArchivedBatchesScreenState();
}

class _ArchivedBatchesScreenState extends State<ArchivedBatchesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final batches = archivedBatches
        .where(
          (batch) =>
              query.isEmpty ||
              batch.name.toLowerCase().contains(query) ||
              batch.classTeacher.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.screenGradientEnd],
            stops: [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              AppBackHeader(
                title: 'Archived batches',
                subtitle: 'View previous batches Attendance & Reports',
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: AppSearchBar(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: 17),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: batches.length,
                  itemBuilder: (context, index) => _ArchivedBatchTile(
                    batch: batches[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedBatchTile extends StatelessWidget {
  final ArchivedBatch batch;

  const _ArchivedBatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!context.mounted) return;
        context.push('/archived-batch-semesters/${Uri.encodeComponent(batch.name)}');
      },
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 5.5),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.black, width: 0.81),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 16.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    batch.classTeacher,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 12.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AttendancePercentageBadge(percent: batch.attendancePercent),
          ],
        ),
      ),
    );
  }
}
