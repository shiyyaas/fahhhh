import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';

/// Shared page background for settings and detail screens.
///
/// Keeps the white-to-muted vertical wash consistent across the app instead
/// of each screen re-declaring its own [BoxDecoration].
class AppScreenScaffold extends StatelessWidget {
  final Widget child;

  const AppScreenScaffold({super.key, required this.child});

  static const BoxDecoration background = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, AppColors.screenGradientEnd],
      stops: [0.25, 1.0],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: background,
      child: SafeArea(child: child),
    );
  }
}
