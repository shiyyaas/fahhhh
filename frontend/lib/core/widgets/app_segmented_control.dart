import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_radius.dart';

enum AppSegmentedControlVariant { gradient, solid, compact }

class AppSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final AppSegmentedControlVariant variant;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const AppSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = AppSegmentedControlVariant.gradient,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppSegmentedControlVariant.solid:
        return _buildSolid();
      case AppSegmentedControlVariant.compact:
        return _buildCompact();
      case AppSegmentedControlVariant.gradient:
        return _buildGradient();
    }
  }

  Widget _buildGradient() {
    return Container(
      height: height ?? 38,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 26),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 30,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.background : const Color(0xFF404752),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSolid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF47494C) : AppColors.background,
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
                    fontSize: 14,
                    color: isSelected ? AppColors.background : const Color(0xFF4B4A4A),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompact() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.enabledBorder,
                ),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.background : AppColors.darkText,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
