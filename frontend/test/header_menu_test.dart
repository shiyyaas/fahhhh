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
      expect(items, ['Timetable', 'Archived Batches']);
    });

    test('Department Page - Teachers toggle returns correct items', () {
      final items = HeaderMenuConfig.getMenuItems(
        pageType: HeaderPageType.department,
        selectedSegmentIndex: 1,
      );
      expect(
        items,
        ['Timetable', 'Archived Batches', 'Teachers Settings'],
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
        'Timetable',
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
        'Timetable',
        'Check Condonation',
        'Subject Settings',
      ]);
    });

    test('Department Timetable routes to admin timetable', () {
      expect(
        HeaderMenuConfig.routeFor(
          'Timetable',
          pageType: HeaderPageType.department,
        ),
        '/timetable',
      );
    });

    test('My Class Timetable routes to teacher timetable', () {
      expect(
        HeaderMenuConfig.routeFor(
          'Timetable',
          pageType: HeaderPageType.myClass,
        ),
        '/timetable?mode=teacher',
      );
    });

    test('Attendance history routes to attendance history screen', () {
      expect(
        HeaderMenuConfig.routeFor('Attendance history'),
        '/attendance-history',
      );
    });

    test('Generate Report routes to the report screen', () {
      expect(
        HeaderMenuConfig.routeFor(
          'Generate Report',
          pageType: HeaderPageType.myClass,
        ),
        '/generate-report',
      );
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
      expect(find.text('Timetable'), findsOneWidget);
      expect(find.text('Archived Batches'), findsOneWidget);

      // Tap item
      await tester.tap(find.text('Timetable'));
      await tester.pumpAndSettle();

      expect(selectedOption, equals('Timetable'));
    });
  });
}
