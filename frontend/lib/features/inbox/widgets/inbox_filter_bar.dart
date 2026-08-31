import 'package:flutter/material.dart';

import '../../../core/widgets/app_segmented_control.dart';

/// Inbox filter pills (All / Teacher / Student / leave).
/// Selected pill: dark #47494C bg with white text; others white with border.
class InboxFilterBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const InboxFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSegmentedControl(
      labels: labels,
      selectedIndex: selectedIndex,
      onChanged: onChanged,
      variant: AppSegmentedControlVariant.solid,
    );
  }
}
