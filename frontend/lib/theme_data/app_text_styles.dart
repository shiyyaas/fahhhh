
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {

  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.headingText,
  );

  static TextStyle small = GoogleFonts.itim(
    fontSize: 14,
    color: AppColors.smallText,
  );

  static TextStyle sfPRO = GoogleFonts.inter(
    // fontWeight: FontWeight.w500,
    color: AppColors.headingText,
  );

}