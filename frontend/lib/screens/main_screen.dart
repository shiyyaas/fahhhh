// Screens
import 'package:fahhhh/screens/home.dart';
import 'package:fahhhh/screens/my_class.dart';
import 'package:fahhhh/screens/department.dart';
import 'package:fahhhh/screens/profile.dart';
import 'package:fahhhh/screens/my_subject.dart';

// Widgets
import 'package:fahhhh/widgets/navbar.dart';

import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  final List<Widget> pages = [

    const Home(),
    const Department(),
    const MyClass(),
    const MySubject(),
    const Profile(),

  ];

  void onItemTapped(int index) {

    setState(() {
      selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[selectedIndex],
      bottomNavigationBar: Navbar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),

    );

  }

}