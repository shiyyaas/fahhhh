import 'dart:async';
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';

// Routes
import 'package:fahhhh/core/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();
    final isoLoggedIn = ref.read(authProvider);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Step 1: Fade IN
    _controller.forward().then((_) {
      // Step 2: Stay for 1 seconds
      Timer(const Duration(milliseconds: 1000), () {
        // Step 3: Fade OUT
        _controller.reverse().then((_) {
          // Step 4: Navigate
          if(isoLoggedIn){
            Navigator.pushReplacementNamed(context, AppRoutes.main);
          }else{
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset('assets/images/logo.png', width: 140),
        ),
      ),
    );
  }
}
