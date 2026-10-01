import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Poppins — headings, subject names, major navigation labels
  static final TextStyle heading = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    color: AppColors.headingText,
  );

  // Inter — general UI, metadata, dense data
  static final TextStyle body = GoogleFonts.inter(
    color: AppColors.headingText,
  );

  // Inter — supporting / secondary text
  static final TextStyle small = GoogleFonts.inter(
    color: AppColors.smallText,
  );

  // Itim — decorative content only; do not use for attendance or navigation data
  static final TextStyle decorative = GoogleFonts.itim(
    color: AppColors.headingText,
  );

  // Kept for backwards compatibility — prefer AppTextStyles.body for new code
  static final TextStyle sfPRO = body;
}