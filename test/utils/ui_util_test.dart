import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/utils/ui_util.dart';

void main() {
  group('UIUtil', () {
    test('capitalize capitalizes each word and handles edge cases', () {
      expect(UIUtil().capitalize('hello world'), 'Hello World');
      expect(UIUtil().capitalize('flutter'), 'Flutter');
      expect(UIUtil().capitalize(''), '');
      expect(UIUtil().capitalize('  multiple   spaces  '),
          '  Multiple   Spaces  ');
    });

    test('getGreeting returns correct greeting for all times', () {
      final greeting = UIUtil().getGreeting();
      expect(['Good morning', 'Good afternoon', 'Good evening'],
          contains(greeting));
    });

    test('formatDate formats date and handles null', () {
      final date = DateTime(2023, 5, 7);
      expect(UIUtil.formatDate(date), '07-05-2023');
      expect(UIUtil.formatDate(null), '');
    });

    test('formatDate handles invalid date (catch block)', () {
      expect(UIUtil.formatDate(null), '');
    });

    test('formatNotificationRelative returns correct unit for all ranges', () {
      final now = DateTime.now();
      expect(UIUtil.formatNotificationRelative(now.add(Duration(seconds: 10))),
          contains('s'));
      expect(UIUtil.formatNotificationRelative(now.add(Duration(minutes: 10))),
          contains('m'));
      expect(UIUtil.formatNotificationRelative(now.add(Duration(hours: 2))),
          contains('h'));
      expect(UIUtil.formatNotificationRelative(now.add(Duration(days: 2))),
          contains('d'));
      expect(UIUtil.formatNotificationRelative(now.add(Duration(days: 10))),
          contains('w'));
      expect(UIUtil.formatNotificationRelative(now.add(Duration(days: 40))),
          contains('mo'));
      expect(UIUtil.formatNotificationRelative(now.add(Duration(days: 400))),
          contains('y'));
    });

    test('formatNotificationRelative handles negative (past) dates', () {
      final now = DateTime.now();
      expect(
          UIUtil.formatNotificationRelative(
              now.subtract(Duration(seconds: 10))),
          contains('s'));
      expect(
          UIUtil.formatNotificationRelative(
              now.subtract(Duration(minutes: 10))),
          contains('m'));
      expect(
          UIUtil.formatNotificationRelative(now.subtract(Duration(hours: 2))),
          contains('h'));
      expect(UIUtil.formatNotificationRelative(now.subtract(Duration(days: 2))),
          contains('d'));
      expect(
          UIUtil.formatNotificationRelative(now.subtract(Duration(days: 10))),
          contains('w'));
      expect(
          UIUtil.formatNotificationRelative(now.subtract(Duration(days: 40))),
          contains('mo'));
      expect(
          UIUtil.formatNotificationRelative(now.subtract(Duration(days: 400))),
          contains('y'));
    });

    testWidgets(
        'showError, showUnavailableOffline, showOffline, showBackOnline show SnackBars',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => UIUtil.showError(context, 'error'),
                      child: const Text('Error'),
                    ),
                    ElevatedButton(
                      onPressed: () => UIUtil.showUnavailableOffline(context),
                      child: const Text('Unavailable'),
                    ),
                    ElevatedButton(
                      onPressed: () => UIUtil.showOffline(context),
                      child: const Text('Offline'),
                    ),
                    ElevatedButton(
                      onPressed: () => UIUtil.showBackOnline(context),
                      child: const Text('BackOnline'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Show error
      await tester.tap(find.text('Error'));
      await tester.pump();
      expect(find.text('error'), findsOneWidget);

      // Dismiss the SnackBar
      await tester.runAsync(() async {
        ScaffoldMessenger.of(tester.element(find.text('Error'))).clearSnackBars();
      });
      await tester.pumpAndSettle();

      // Show unavailable offline
      await tester.tap(find.text('Unavailable'));
      await tester.pump();
      expect(find.text('Unavailable offline.'), findsOneWidget);

      // Dismiss the SnackBar
      await tester.runAsync(() async {
        ScaffoldMessenger.of(tester.element(find.text('Unavailable'))).clearSnackBars();
      });
      await tester.pumpAndSettle();

      // Show offline
      await tester.tap(find.text('Offline'));
      await tester.pump();
      expect(find.text('You are offline.'), findsOneWidget);

      // Dismiss the SnackBar
      await tester.runAsync(() async {
        ScaffoldMessenger.of(tester.element(find.text('Offline'))).clearSnackBars();
      });
      await tester.pumpAndSettle();

      // Show back online
      await tester.tap(find.text('BackOnline'));
      await tester.pump();
      expect(find.text('Back online!'), findsOneWidget);
    });
  });
}
