import 'package:flutter/material.dart';

class AppColors {
  // Main Colors
  static const Color primary = Color(0xFF136BB3);
  static const Color secondary = Color(0xFFD0E1FB);
  static const Color background = Colors.white;
  static const Color surface = Colors.white;

  // Brand Gradients
  static const Color gradientTop = Color(0xFF7198EE);
  static const Color gradientBottom = Color(0xFF163B8E);

  // Navigation Bar
  static const Color navBar = Color(0xFF262525);
  static const Color navBarBg = Color(0xFF262525);

  // Text Colors
  static const Color headingText = Colors.black;
  static const Color smallText = Color(0xFF635959);
  static const Color labelText = Color.fromARGB(255, 59, 59, 59);
  static const Color hintText = Color.fromARGB(255, 80, 79, 79);
  static const Color darkText = Color(0xFF373737);
  static const Color textSecondary = Color(0xFF666666);

  // Common UI Colors
  static const Color border = Color(0xFF1A1A1A); // Outline token
  static const Color outline = Color(0xFF1A1A1A);
  static const Color enabledBorder = Color.fromARGB(255, 172, 172, 172);

  // Screen Background
  static const Color screenGradientEnd = Color(0xFFAAA0A0);

  // Upload / dropzone surface
  static const Color uploadSurface = Color(0xFFF0F7FF);

  // Restrained elevation for floating controls
  static const Color controlShadow = Color(0x1A000000);

  // Semantic Status Colors (from design.md)
  static const Color success = Color(0xFF48AE8C);
  static const Color warning = Color(0xFFD0B238);
  static const Color danger = Color(0xFFE57373);
  static const Color missed = Color(0xFF775471);
  static const Color recordNow = Color(0xFF9DB6EE);
  static const Color pending = Color(0xFF5F6B7A);

  // Legacy Aliases (mapped to new semantic tokens)
  static const Color present = success;
  static const Color absent = danger;
  static const Color ongoing = recordNow;

  // Attendance Badge Colors (legacy - leaving intact so we don't break screens not yet refactored)
  static const Color goodAttendance = Color(0x996BDB72);
  static const Color badAttendance = Color(0x99BA4545);
  static const Color goodAttendanceBg = Color(0xFF9EEDBB);
  static const Color badAttendanceBg = Color(0xFFFFCDCE);
}
