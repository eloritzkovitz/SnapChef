import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../providers/connectivity_provider.dart';

class SnapChefAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;

  const SnapChefAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0x14000000),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOffline) const SizedBox(height: kOfflineBannerHeight),
          AppBar(
            title: title,
            actions: actions,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: elevation,
            shape: const Border(
              bottom: BorderSide(
                color: Color(0x14000000),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight + kOfflineBannerHeight + 1);
  }
}
