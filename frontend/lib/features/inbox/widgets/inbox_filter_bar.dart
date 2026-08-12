import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              width: 107,
              height: 28,
              margin: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF47494C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFB5B5B5), width: 1),
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected ? Colors.white : const Color(0xFF4B4A4A),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}