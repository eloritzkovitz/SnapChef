import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/utils/navigation_observer.dart';

void main() {
  testWidgets('StatusBarObserver sets status bar on navigation',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ConnectivityProvider>(
        create: (_) => ConnectivityProvider(),
        child: MaterialApp(home: Container()),
      ),
    );

    final observer = StatusBarObserver(
      tester.element(find.byType(Container)), // Dummy context
    );

    final route = MaterialPageRoute(
        builder: (_) => Container(), settings: RouteSettings(name: '/'));
    final prevRoute = MaterialPageRoute(
        builder: (_) => Container(), settings: RouteSettings(name: '/main'));

    // These won't actually change the system UI in a test, but should not throw
    observer.didPush(route, prevRoute);
    observer.didPop(route, prevRoute);
    observer.didReplace(newRoute: route, oldRoute: prevRoute);
  });
}
