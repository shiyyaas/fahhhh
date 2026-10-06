import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/models/department_class.dart';
import 'package:fahhhh/features/department/models/department_subject.dart';
import 'package:fahhhh/features/department/models/department_student.dart';
import 'package:fahhhh/features/my_subjects/models/my_subject_item.dart';

void main() {
  group('SortDropdown Widget Tests', () {
    testWidgets('uncontrolled SortDropdown opens and updates label on tap', (WidgetTester tester) async {
      String? changed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SortDropdown(
                placeholder: 'Sort by',
                options: const ['Roll No', 'Highest', 'Lowest'],
                onChanged: (val) {
                  changed = val;
                },
              ),
            ),
          ),
        ),
      );

      // Initially shows 'Sort by'
      expect(find.text('Sort by'), findsOneWidget);

      // Tap dropdown to open overlay menu
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();

      // Options are visible in overlay
      expect(find.text('Highest'), findsOneWidget);
      expect(find.text('Lowest'), findsOneWidget);

      // Tap 'Highest'
      await tester.tap(find.text('Highest'));
      await tester.pumpAndSettle();

      expect(changed, equals('Highest'));
      expect(find.text('Highest'), findsOneWidget);
    });

    testWidgets('controlled SortDropdown reports selection and reflects value', (WidgetTester tester) async {
      String selected = 'Roll No';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SortDropdown(
                    value: selected,
                    options: const ['Roll No', 'Highest', 'Lowest'],
                    onChanged: (val) {
                      setState(() => selected = val);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Roll No'), findsOneWidget);

      // Tap to open
      await tester.tap(find.text('Roll No'));
      await tester.pumpAndSettle();

      // Select 'Lowest'
      await tester.tap(find.text('Lowest'));
      await tester.pumpAndSettle();

      expect(selected, equals('Lowest'));
      expect(find.text('Lowest'), findsOneWidget);
    });
  });

  group('Sorting Logic Unit Tests', () {
    test('Department classes sort by Highest, Lowest, and Name', () {
      final classes = List<DepartmentClass>.from(mockDepartmentClasses);

      // Highest
      classes.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      expect(classes.first.attendancePercent >= classes.last.attendancePercent, isTrue);

      // Lowest
      classes.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      expect(classes.first.attendancePercent <= classes.last.attendancePercent, isTrue);
      expect(classes.first.attendancePercent, equals(65));

      // Name / Roll No
      classes.sort((a, b) => a.name.compareTo(b.name));
      expect(classes.first.name, equals('S2 BCA'));
    });

    test('Department subjects sort by Highest and Lowest attendance', () {
      final subjects = List<DepartmentSubject>.from(mockDepartmentSubjects);

      // Highest
      subjects.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      expect(subjects.first.attendancePercent, equals(95));

      // Lowest
      subjects.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      expect(subjects.first.attendancePercent, equals(65));

      // Roll No
      subjects.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
      expect(subjects.first.rollNumber, equals('S2023001'));
    });

    test('Department students sort by Roll No, Highest (A-Z), and Lowest (Z-A)', () {
      final students = List<DepartmentStudent>.from(mockDepartmentStudents);

      // A-Z
      students.sort((a, b) => a.name.compareTo(b.name));
      expect(students.first.name, equals('Alice Johnson'));

      // Z-A
      students.sort((a, b) => b.name.compareTo(a.name));
      expect(students.first.name, equals('Jack Anderson'));

      // Roll No
      students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
      expect(students.first.rollNumber, equals('S2023001'));
    });

    test('MySubjectItems sort by Highest, Lowest, and Name', () {
      final items = [
        const MySubjectItem(name: 'Maths', classes: 'S2 BCA', attendancePercent: 78),
        const MySubjectItem(name: 'Data Science', classes: 'S4 BCA', attendancePercent: 95),
        const MySubjectItem(name: 'Flutter', classes: 'S6 BCA', attendancePercent: 65),
      ];

      items.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      expect(items.first.name, equals('Data Science'));

      items.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      expect(items.first.name, equals('Flutter'));

      items.sort((a, b) => a.name.compareTo(b.name));
      expect(items.first.name, equals('Data Science'));
    });
  });
}
