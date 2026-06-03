
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {

  static TextStyle heading = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    color: const Color.fromARGB(255, 19, 18, 18),
  );

  static TextStyle small = GoogleFonts.itim(
    color: AppColors.smallText,
  );

  static TextStyle sfPRO = GoogleFonts.inter(
    // fontWeight: FontWeight.w500,
    color: AppColors.headingText,
  );

}