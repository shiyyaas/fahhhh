//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

import 'package:flutter/material.dart';

/// Compact search pill + "Sort by" dropdown row used on department screens.
class SearchSortBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onQueryChanged;

  const SearchSortBar({super.key, this.controller, this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: SearchField(
              controller: controller,
              onChanged: onQueryChanged,
            ),
          ),
          const SizedBox(width: 10),
          const SortDropdown(),
        ],
      ),
    );
  }
}

/// White pill search field matching the design's search bar.
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3.6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: const Color(0xFF373737),
        style: AppTextStyles.sfPRO.copyWith(
          fontSize: 13.5,
          color: const Color(0xFF373737),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: Color(0xFF373737),
          ),
          hintText: 'Search',
          hintStyle: AppTextStyles.sfPRO.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

/// White pill "Sort by" dropdown matching the design.
class SortDropdown extends StatelessWidget {
  const SortDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2292),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3.6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sort by',
            style: AppTextStyles.sfPRO.copyWith(
              fontSize: 15.7,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }
}
