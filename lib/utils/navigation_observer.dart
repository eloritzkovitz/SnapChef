import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/connectivity_provider.dart';
import '../theme/colors.dart';
import 'package:provider/provider.dart';

class StatusBarObserver extends NavigatorObserver {
  final BuildContext context;
  StatusBarObserver(this.context);

  void _setStatusBar(Route? route) {
    // Check if this is the splash screen route
    final isSplash =
        route?.settings.name == '/' || route?.settings.name == '/splash';
    if (isSplash) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: splashColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: splashColor,
          systemNavigationBarIconBrightness: Brightness.light,          
        ),
      );
      return;
    }

    final isOffline =
        Provider.of<ConnectivityProvider>(context, listen: false).isOffline;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isOffline ? disabledSecondaryColor : Colors.white,
        statusBarIconBrightness: isOffline ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _setStatusBar(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _setStatusBar(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _setStatusBar(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
