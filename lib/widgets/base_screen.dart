import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/offline_banner.dart';
import '../providers/connectivity_provider.dart';

class BaseScreen extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool showOfflineBanner;

  const BaseScreen({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.showOfflineBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    return Stack(
      children: [
        // Main content (Scaffold)
        Scaffold(
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
        // Offline banner at the very top
        if (showOfflineBanner && isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: OfflineBanner(),
            ),
          ),
      ],
    );
  }
}
