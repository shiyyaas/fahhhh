import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class DesignSystem {

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    fontFamily: "Poppins",

    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.background,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
    ),

    textTheme: const TextTheme(

      headlineLarge: AppTextStyles.heading,

      headlineMedium: AppTextStyles.heading,

      titleMedium: AppTextStyles.small,

      bodyMedium: AppTextStyles.small,

    ),

    inputDecorationTheme: InputDecorationTheme(

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        elevation: 0,

        minimumSize: const Size(
          double.infinity,
          55,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.large,
          ),
        ),
      ),
    ),
  );
}