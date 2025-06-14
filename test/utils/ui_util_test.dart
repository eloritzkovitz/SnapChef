import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/utils/ui_util.dart';

void main() {
  group('UIUtil', () {
    test('capitalize capitalizes each word', () {
      expect(UIUtil().capitalize('hello world'), 'Hello World');
      expect(UIUtil().capitalize('flutter'), 'Flutter');
    });

    test('getGreeting returns a string', () {
      final greeting = UIUtil().getGreeting();
      expect(greeting, isA<String>());
    });

    test('formatDate formats date', () {
      final date = DateTime(2023, 5, 7);
      expect(UIUtil.formatDate(date), '07-05-2023');
      expect(UIUtil.formatDate(null), '');
    });

    test('formatNotificationRelative returns correct unit', () {
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
  });
}