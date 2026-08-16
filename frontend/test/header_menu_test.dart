import 'package:fahhhh/features/department/utils/header_menu_config.dart';
import 'package:fahhhh/features/department/widgets/more_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeaderMenuConfig Unit Tests', () {
    test('Department Page - Classes toggle returns correct items', () {
      final items = HeaderMenuConfig.getMenuItems(
        pageType: HeaderPageType.department,
        selectedSegmentIndex: 0,
      );
      expect(items, ['TimeTableSettings', 'Archived Batches']);
    });

    test('Department Page - Teachers toggle returns correct items', () {
      final items = HeaderMenuConfig.getMenuItems(
        pageType: HeaderPageType.department,
        selectedSegmentIndex: 1,
      );
      expect(
        items,
        ['TimeTableSettings', 'Archived Batches', 'Teachers Settings'],
      );
    });

    test('My Class Page - Students toggle returns correct items', () {
      final items = HeaderMenuConfig.getMenuItems(
        pageType: HeaderPageType.myClass,
        selectedSegmentIndex: 0,
      );
      expect(items, [
        'Generate Report',
        'Attendance history',
        'Time table',
        'Check Condonation',
        'Student settings',
      ]);
    });

    test('My Class Page - Subjects toggle returns correct items', () {
      final items = HeaderMenuConfig.getMenuItems(
        pageType: HeaderPageType.myClass,
        selectedSegmentIndex: 1,
      );
      expect(items, [
        'Generate Report',
        'Attendance history',
        'Time table',
        'Check Condonation',
        'Subject Settings',
      ]);
    });
  });

  group('MoreButton Widget Tests', () {
    testWidgets('Opens popup menu and triggers callback on item tap',
        (WidgetTester tester) async {
      String? selectedOption;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoreButton(
                pageType: HeaderPageType.department,
                selectedSegmentIndex: 0,
                onOptionSelected: (option) {
                  selectedOption = option;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MoreButton), findsOneWidget);

      // Tap MoreButton to display the popup menu
      await tester.tap(find.byType(MoreButton));
      await tester.pumpAndSettle();

      // Verify menu items present
      expect(find.text('TimeTableSettings'), findsOneWidget);
      expect(find.text('Archived Batches'), findsOneWidget);

      // Tap item
      await tester.tap(find.text('TimeTableSettings'));
      await tester.pumpAndSettle();

      expect(selectedOption, equals('TimeTableSettings'));
    });
  });
}
