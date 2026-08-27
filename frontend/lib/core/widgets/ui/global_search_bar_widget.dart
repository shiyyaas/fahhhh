import 'package:flutter/material.dart';
import '../../theme_data/app_text_styles.dart';

/// Standardized iOS Spotlight-style search bar component.
///
/// Features:
/// - Clean white pill container with subtle shadow & border
/// - Fixed left magnifying glass search icon
/// - Muted placeholder text
/// - Persistent focus text cursor
class GlobalSearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final double height;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const GlobalSearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search',
    this.height = 30.0,
    this.focusNode,
    this.onTap,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4.0,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        cursorColor: const Color(0xFF373737),
        style: AppTextStyles.sfPRO.copyWith(
          fontSize: 13.5,
          color: const Color(0xFF373737),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8, right: 6),
            child: Icon(
              Icons.search,
              size: 16,
              color: Color(0xFF635959),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 16,
          ),
          hintText: hintText,
          hintStyle: AppTextStyles.sfPRO.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF8E8E93),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
