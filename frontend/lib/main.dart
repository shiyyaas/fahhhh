import 'package:fahhhh/theme_data/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: DesignSystem.lightTheme,

      home: const Scaffold(
        body: Center(
          child: Text("Shiyas App"),
        ),
      ),
    );
  }
}