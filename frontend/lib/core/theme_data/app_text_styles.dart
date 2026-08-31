import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle heading = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    color: AppColors.headingText,
  );

  static final TextStyle small = GoogleFonts.itim(
    color: AppColors.smallText,
  );

  static final TextStyle sfPRO = GoogleFonts.inter(
    color: AppColors.headingText,
  );
}