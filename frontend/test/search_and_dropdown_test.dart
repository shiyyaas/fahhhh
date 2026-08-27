import 'package:fahhhh/core/widgets/ui/app_dropdown.dart';
import 'package:fahhhh/core/widgets/ui/global_search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalSearchBarWidget Unit & Widget Tests', () {
    testWidgets('Renders hint text, icon, and handles text entry', (WidgetTester tester) async {
      String enteredText = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchBarWidget(
              controller: controller,
              hintText: 'Search students...',
              onChanged: (val) {
                enteredText = val;
              },
            ),
          ),
        ),
      );

      expect(find.text('Search students...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.pump();

      expect(enteredText, 'John Doe');
      expect(controller.text, 'John Doe');
    });
  });

  group('AppDropdown Unit & Widget Tests', () {
    testWidgets('Renders Form Input variant correctly', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDropdown<String>.formInput(
              value: null,
              labelText: 'Select Subject',
              prefixIcon: Icons.subject_rounded,
              items: const [
                AppDropdownItem(value: 'maths', label: 'Mathematics'),
                AppDropdownItem(value: 'cs', label: 'Computer Science'),
              ],
              onChanged: (val) => selectedValue = val,
            ),
          ),
        ),
      );

      expect(find.text('Select Subject'), findsOneWidget);
      expect(find.byIcon(Icons.subject_rounded), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mathematics'), findsWidgets);
      expect(find.text('Computer Science'), findsWidgets);

      await tester.tap(find.text('Mathematics').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'maths');
    });

    testWidgets('Renders Filter variant correctly', (WidgetTester tester) async {
      String? selectedFilter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: AppDropdown<String>.filter(
                  value: 'Roll No',
                  items: const [
                    AppDropdownItem(value: 'Roll No', label: 'Roll No'),
                    AppDropdownItem(value: 'Highest', label: 'Highest'),
                    AppDropdownItem(value: 'Lowest', label: 'Lowest'),
                  ],
                  onChanged: (val) => selectedFilter = val,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Roll No'), findsOneWidget);

      await tester.tap(find.text('Roll No'));
      await tester.pumpAndSettle();

      expect(find.text('Highest'), findsOneWidget);
      expect(find.text('Lowest'), findsOneWidget);

      await tester.tap(find.text('Highest'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(selectedFilter, 'Highest');
    });

    testWidgets('Renders Action Menu variant correctly', (WidgetTester tester) async {
      String? actionSelected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDropdown<String>.actionMenu(
              items: const [
                AppDropdownItem(value: 'edit', label: 'Edit Class'),
                AppDropdownItem(value: 'delete', label: 'Delete Class', isDestructive: true),
              ],
              onChanged: (val) => actionSelected = val,
              child: const Icon(Icons.more_vert),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit Class'), findsOneWidget);
      expect(find.text('Delete Class'), findsOneWidget);

      await tester.tap(find.text('Edit Class'));
      await tester.pumpAndSettle();

      expect(actionSelected, 'edit');
    });
  });
}
