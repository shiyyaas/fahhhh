// Screens
import 'package:fahhhh/screens/home.dart';
import 'package:fahhhh/screens/my_class.dart';
import 'package:fahhhh/screens/department.dart';
import 'package:fahhhh/screens/profile.dart';
import 'package:fahhhh/screens/my_subject.dart';

// Widgets
import 'package:fahhhh/widgets/navbar.dart';

// Models
import 'package:fahhhh/models/nav_item.dart';

import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  final List<NavItem> items = [

    NavItem(
      icon: Icons.home_outlined,
      label: 'Home',
      page: const Home(),
    ),

    NavItem(
      icon: Icons.apartment_outlined,
      label: 'Department',
      page: const Department(),
    ),

    NavItem(
      icon: Icons.groups_outlined,
      label: 'Class',
      page: const MyClass(),
    ),

    NavItem(
      icon: Icons.menu_book_outlined,
      label: 'Subjects',
      page: const MySubject(),
    ),

    NavItem(
      icon: Icons.person_outline,
      label: 'Profile',
      page: const Profile(),
    ),

  ];

  void onItemTapped(int index) {

    setState(() {
      selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: items[selectedIndex].page,
      bottomNavigationBar: Navbar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
        items: items,
      ),

    );

  }

}