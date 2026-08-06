import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/navigation/screens/main_screen.dart';
import '../../features/home/screens/home.dart';
import '../../features/department/screens/department.dart';
import '../../features/my_class/screens/my_class.dart';
import '../../features/my_subjects/screens/my_subject.dart';
import '../../features/profile/screens/profile.dart';
import '../../features/profile/screens/edit_profile.dart';
import '../../features/attendance/screens/attendance_taking_screen.dart';
import '../../features/timetable/screens/timetable_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // Timetable Screen Route - outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/timetable',
        builder: (context, state) => const TimetableScreen(),
      ),
      // Attendance Taking Route - outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/attendance-taking/:slotId',
        builder: (context, state) {
          final slotId = state.pathParameters['slotId']!;
          return AttendanceTakingScreen(slotId: slotId);
        },
      ),
      // Attendance View Route - outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/attendance-view/:slotId',
        builder: (context, state) {
          final slotId = state.pathParameters['slotId']!;
          return AttendanceTakingScreen(slotId: slotId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Home(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/department',
                builder: (context, state) => const Department(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/class',
                builder: (context, state) => const MyClass(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subjects',
                builder: (context, state) => const MySubject(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const Profile(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
