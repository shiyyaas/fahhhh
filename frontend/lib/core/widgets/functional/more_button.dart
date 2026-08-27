import 'package:fahhhh/core/widgets/ui/app_dropdown.dart';
import 'package:fahhhh/features/department/utils/header_menu_config.dart';
import 'package:flutter/material.dart';

/// Gradient circle with three white dots used in department/class headers.
/// When clicked, presents a dynamic dropdown popup menu based on page type and active segment.
class MoreButton extends StatelessWidget {
  final HeaderPageType? pageType;
  final int selectedSegmentIndex;
  final String? activeSegmentLabel;
  final List<String>? customItems;
  final ValueChanged<String>? onOptionSelected;
  final VoidCallback? onTap;

  const MoreButton({
    super.key,
    this.pageType,
    this.selectedSegmentIndex = 0,
    this.activeSegmentLabel,
    this.customItems,
    this.onOptionSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> items = customItems ??
        (pageType != null
            ? HeaderMenuConfig.getMenuItems(
                pageType: pageType!,
                selectedSegmentIndex: selectedSegmentIndex,
                activeSegmentLabel: activeSegmentLabel,
              )
            : const []);

    final buttonGraphic = SizedBox(
      width: 43,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 37,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7198EE), Color(0xFF163B8E)],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Container(
                width: 18,
                height: 3.9,
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (items.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: buttonGraphic,
      );
    }

    return AppDropdown<String>.actionMenu(
      items: items
          .map((item) => AppDropdownItem<String>(value: item, label: item))
          .toList(),
      onChanged: (option) {
        if (option != null) {
          debugPrint('Selected option: $option');
          onOptionSelected?.call(option);
          onTap?.call();
        }
      },
      child: buttonGraphic,
    );
  }
}
