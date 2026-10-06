import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fahhhh/features/department/widgets/compact_action_button.dart';
import 'package:fahhhh/features/department/widgets/detail_action_button.dart';

void main() {
  group('CompactActionButton Tests', () {
    testWidgets('renders primary variant and triggers onTap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompactActionButton.primary(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Add',
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1_rounded), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders secondary and danger variants properly', (WidgetTester tester) async {
      bool uploadTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                CompactActionButton.secondary(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  onTap: () => uploadTapped = true,
                ),
                CompactActionButton.danger(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete (2)',
                  onTap: () => deleteTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Delete (2)'), findsOneWidget);

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(uploadTapped, isTrue);

      await tester.tap(find.text('Delete (2)'));
      await tester.pumpAndSettle();
      expect(deleteTapped, isTrue);
    });
  });

  group('DetailActionButton Tests', () {
    testWidgets('renders primary and danger detail buttons and fires callbacks', (WidgetTester tester) async {
      bool deleteFired = false;
      bool saveFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: DetailActionButton.danger(
                    text: 'Delete',
                    onPressed: () => deleteFired = true,
                  ),
                ),
                Expanded(
                  child: DetailActionButton.primary(
                    text: 'Save',
                    onPressed: () => saveFired = true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleteFired, isTrue);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saveFired, isTrue);
    });
  });
}
