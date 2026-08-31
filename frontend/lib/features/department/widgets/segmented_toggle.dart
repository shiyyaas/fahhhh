import 'package:flutter/material.dart';

import '../../../core/widgets/app_segmented_control.dart';

/// Segmented pill toggle (e.g. Classes | Teachers) matching the design's
/// rounded control with a gradient highlight on the active segment.
class SegmentedToggle extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedToggle({
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
    );
  }
}
