import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/utils/navigation_observer.dart';

void main() {
  testWidgets('StatusBarObserver sets status bar on navigation', (tester) async {
    final observer = StatusBarObserver(
      tester.element(find.byType(Container)), // Dummy context
    );

    final route = MaterialPageRoute(builder: (_) => Container(), settings: RouteSettings(name: '/'));
    final prevRoute = MaterialPageRoute(builder: (_) => Container(), settings: RouteSettings(name: '/main'));

    // These won't actually change the system UI in a test, but should not throw
    observer.didPush(route, prevRoute);
    observer.didPop(route, prevRoute);
    observer.didReplace(newRoute: route, oldRoute: prevRoute);
  });
}