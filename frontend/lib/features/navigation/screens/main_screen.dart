// Screens
import 'package:fahhhh/features/home/screens/home.dart';
import 'package:fahhhh/features/My_class/screens/my_class.dart';
import 'package:fahhhh/features/Department/screens/department.dart';
import 'package:fahhhh/features/profile/screens/profile.dart';
import 'package:fahhhh/features/My_subjects/screens/my_subject.dart';

// Widgets
import 'package:fahhhh/features/navigation/widgets/navbar.dart';

// Models
import 'package:fahhhh/features/navigation/models/nav_item.dart';

// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';

import 'package:flutter/material.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    final List<NavItem> items = [
      NavItem(icon: Icons.home_outlined, label: 'Home', page: const Home()),

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

      return Scaffold(
        body: items[selectedIndex].page,
        bottomNavigationBar: Navbar(
          selectedIndex: selectedIndex,
          onItemTapped: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
          },
          items: items,
        ),
      );
  }
}