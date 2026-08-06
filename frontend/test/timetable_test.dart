import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fahhhh/features/auth/models/current_user.dart';
import 'package:fahhhh/features/auth/models/auth_state.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/timetable/screens/timetable_screen.dart';

void main() {
  testWidgets('Timetable Screen renders correctly for student', (WidgetTester tester) async {
    const mockUser = CurrentUser(
      email: "student@mescas.org",
      name: "shiyas ps",
      role: UserRole.student,
      phone: "6235223761",
      className: "S2 BCA",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => const Authenticated(mockUser)),
        ],
        child: const MaterialApp(
          home: TimetableScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Student view should show the main Time Table header but NO toggles/segmented controls/dropdowns
    expect(find.text("Time Table"), findsOneWidget);
    expect(find.text("Classes"), findsNothing);
    expect(find.text("Teachers"), findsNothing);
  });

  testWidgets('Timetable Screen renders controls for HOD', (WidgetTester tester) async {
    const mockUser = CurrentUser(
      email: "anu@mescas.org",
      name: "Anu varghese",
      role: UserRole.teacher,
      isHOD: true,
      phone: "8796543231",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => const Authenticated(mockUser)),
        ],
        child: const MaterialApp(
          home: TimetableScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // HOD should see Classes / Teachers segmented controls, Edit button, and Sort dropdown
    expect(find.text("Classes"), findsOneWidget);
    expect(find.text("Teachers"), findsOneWidget);
    expect(find.text("Edit"), findsOneWidget);

    // Default mode is Classes, should show "S2 BCA" select dropdown
    expect(find.text("S2 BCA"), findsOneWidget);
  });
}
