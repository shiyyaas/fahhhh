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
import '../../features/department/screens/department_class_screen.dart';
import '../../features/my_subjects/screens/subject_details_screen.dart';
import '../../features/my_subjects/screens/subject_class_lists_screen.dart';
import '../../features/inbox/screens/inbox_screen.dart';
import '../../features/profile/screens/student_profile_screen.dart';
import '../../features/profile/models/student_profile.dart';

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
      // Department Class Detail Route - outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/department-class/:classId',
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          return DepartmentClassScreen(classId: Uri.decodeComponent(classId));
        },
      ),
      // Subject Details Route - outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/subject-details/:subjectName/:className',
        builder: (context, state) {
          final subjectName = Uri.decodeComponent(
              state.pathParameters['subjectName']!);
          final className = Uri.decodeComponent(
              state.pathParameters['className']!);
          return SubjectDetailsScreen(
            subjectName: subjectName,
            className: className,
          );
        },
      ),
      // Subject Class Lists Route - shown when a subject is taught in 2+ classes
      // outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/subject-classes/:subjectName',
        builder: (context, state) {
          final subjectName = Uri.decodeComponent(
              state.pathParameters['subjectName']!);
          return SubjectClassListsScreen(subjectName: subjectName);
        },
      ),
      // Inbox Route - outside StatefulShellRoute to hide bottom navigation bar completely
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const InboxScreen(),
      ),
      // Student Profile Route - pushed from a student card, hides bottom nav
      GoRoute(
        path: '/student-profile/:className/:rollNumber/:name',
        builder: (context, state) {
          final className = Uri.decodeComponent(state.pathParameters['className']!);
          final rollNumber = Uri.decodeComponent(state.pathParameters['rollNumber']!);
          final name = Uri.decodeComponent(state.pathParameters['name']!);
          return StudentProfileScreen(
            profile: buildStudentProfile(
              name: name,
              rollNumber: rollNumber,
              className: className,
            ),
          );
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
