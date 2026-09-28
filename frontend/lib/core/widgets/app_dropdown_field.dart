import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_radius.dart';
import '../theme_data/app_text_styles.dart';

class AppDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;
  final bool isExpanded;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 16,
            color: AppColors.labelText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: isExpanded,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.smallText,
          ),
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 14,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            hintText: hintText ?? 'Select $label',
            hintStyle: TextStyle(
              color: AppColors.hintText,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: BorderSide(
                color: AppColors.enabledBorder,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
