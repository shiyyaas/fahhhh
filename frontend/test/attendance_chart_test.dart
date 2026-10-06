import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';

void main() {
  testWidgets('AttendanceChart renders header, filters and switches correctly', (WidgetTester tester) async {
    int? selectedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttendanceChart(
            onFilterChanged: (index) {
              selectedFilter = index;
            },
          ),
        ),
      ),
    );

    // Initial render
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // Check header text elements
    expect(find.text('Average Attendance :'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);

    // Check filter options
    expect(find.text('1w'), findsOneWidget);
    expect(find.text('1m'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);

    // Tap on '1w' filter
    await tester.tap(find.text('1w'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(selectedFilter, equals(0));
    expect(find.text('84%'), findsOneWidget);

    // Tap on 'All' filter
    await tester.tap(find.text('All'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(selectedFilter, equals(2));
    expect(find.text('78%'), findsOneWidget);
  });
}
