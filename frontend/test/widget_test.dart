import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fahhhh/features/auth/models/current_user.dart';
import 'package:fahhhh/features/auth/models/auth_state.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/profile/screens/profile.dart';

void main() {
  testWidgets('Profile Screen renders authenticated user details correctly', (WidgetTester tester) async {
    const mockUser = CurrentUser(
      email: "student@mescas.org",
      name: "Shiyas ps",
      role: UserRole.student,
      phone: "6235223761",
      imageUrl: null,
      rollNumber: "21/BCA/04",
      semester: "2",
      className: "S2 BCA",
      departmentId: "Department of Computer Science",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => const Authenticated(mockUser)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Profile(),
          ),
        ),
      ),
    );

    // Verify name, email and other details render
    expect(find.text('Shiyas ps'), findsOneWidget);
    expect(find.text('S2 BCA'), findsOneWidget);
    expect(find.text('Department of Computer Science'), findsAtLeastNWidgets(1));

    // Verify student-specific roll number is displayed via WhiteBox or Text
    expect(find.text('21/BCA/04'), findsOneWidget);
  });
}
