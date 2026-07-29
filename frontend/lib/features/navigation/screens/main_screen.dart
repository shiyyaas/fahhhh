import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Widgets
import 'package:fahhhh/features/navigation/widgets/navbar.dart';

// Models
import 'package:fahhhh/features/navigation/models/nav_item.dart';

// Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/profile/provider/teacher_provider.dart';

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final teacher = ref.watch(teacherProvider);

    final List<NavItem> items = [];

    if (auth.role == UserRole.student) {
      items.addAll([
        const NavItem(icon: Icons.home_outlined, label: 'Home', branchIndex: 0),
        const NavItem(
          icon: Icons.menu_book_outlined,
          label: 'Subjects',
          branchIndex: 3,
        ),
        const NavItem(
          icon: Icons.person_outline,
          label: 'Profile',
          branchIndex: 4,
        ),
      ]);
    } else if (auth.role == UserRole.teacher) {
      items.add(
        const NavItem(icon: Icons.home_outlined, label: 'Home', branchIndex: 0),
      );

      if (teacher.isHod) {
        items.add(
          const NavItem(
            icon: Icons.apartment_outlined,
            label: 'Department',
            branchIndex: 1,
          ),
        );
      }

      if (teacher.isClassTeacher) {
        items.add(
          const NavItem(
            icon: Icons.groups_outlined,
            label: 'Class',
            branchIndex: 2,
          ),
        );
      }

      items.addAll([
        const NavItem(
          icon: Icons.menu_book_outlined,
          label: 'Subjects',
          branchIndex: 3,
        ),
        const NavItem(
          icon: Icons.person_outline,
          label: 'Profile',
          branchIndex: 4,
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

    int selectedIndex = items.indexWhere(
      (item) => item.branchIndex == navigationShell.currentIndex,
    );
    if (selectedIndex == -1) {
      selectedIndex = 0;
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Navbar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          navigationShell.goBranch(
            items[index].branchIndex,
            initialLocation: index == selectedIndex,
          );
        },
        items: items,
      ),
    );
  }
}
