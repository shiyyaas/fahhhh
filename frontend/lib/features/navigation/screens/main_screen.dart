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

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/profile/provider/teacher_provider.dart';

// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';

import 'package:flutter/material.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    final auth = ref.watch(authProvider);
    final teacher = ref.watch(teacherProvider);

    final List<NavItem> items = [];

    if (auth.role == UserRole.student) {
      items.addAll([
        NavItem(icon: Icons.home_outlined, label: 'Home', page: const Home()),
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
      ]);
    }

    if (auth.role == UserRole.teacher) {
      items.add(
        NavItem(icon: Icons.home_outlined, label: 'Home', page: const Home()),
      );

      if (teacher.isHod) {
        items.add(
          NavItem(
            icon: Icons.apartment_outlined,
            label: 'Department',
            page: const Department(),
          ),
        );
      }

      if (teacher.isClassTeacher) {
        items.add(
          NavItem(
            icon: Icons.groups_outlined,
            label: 'Class',
            page: const MyClass(),
          ),
        );
      }

      items.add(
        NavItem(
          icon: Icons.menu_book_outlined,
          label: 'Subjects',
          page: const MySubject(),
        ),
      );

      items.add(
        NavItem(
          icon: Icons.person_outline,
          label: 'Profile',
          page: const Profile(),
        ),
      );
    }
    if (auth.role == UserRole.hod) {
      items.addAll([
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
          icon: Icons.person_outline,
          label: 'Profile',
          page: const Profile(),
        ),
      ]);
    }
    if (items.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No navigation items found"),
        ),
      );
    }

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
