import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_radius.dart';
import '../theme_data/app_text_styles.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 14,
            color: AppColors.labelText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFEFEFE),
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              color: const Color(0xFFa2a2a2),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    validator: (value) {
                      if (validator != null) {
                        return validator(value);
                      }
                      return null;
                    },
                    readOnly: readOnly,
                    enabled: enabled,
                    maxLines: maxLines,
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: '',
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: -27,
                child: Text(
                  hintText,
                  style: AppTextStyles.sfPRO.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF363636),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
