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
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Attendance App"),
        ),
        body: const Center(
          child: Text(
            "Yoh Flutter 🚀",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}