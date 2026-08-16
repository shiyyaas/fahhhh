//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/department/models/department_class.dart';
import 'package:fahhhh/features/department/utils/header_menu_config.dart';
import 'package:fahhhh/features/department/widgets/more_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Department header: department name + HOD name / class count + dynamic more button.
class DepartmentHeader extends ConsumerWidget {
  final String? countLabel;
  final int selectedSegmentIndex;
  final ValueChanged<String>? onOptionSelected;

  const DepartmentHeader({
    super.key,
    this.countLabel,
    this.selectedSegmentIndex = 0,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    final String hodName = user?.name ?? "Anu Varghese";
    final String count = countLabel ?? '${mockDepartmentClasses.length} Classes';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Computer Science',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 2),
                Text(
                  '$hodName · $count',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MoreButton(
            pageType: HeaderPageType.department,
            selectedSegmentIndex: selectedSegmentIndex,
            onOptionSelected: onOptionSelected,
          ),
        ],
      ),
    );
  }
}
