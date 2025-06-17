import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/views/home/home_screen.dart';
import 'package:snapchef/views/home/widgets/favorites_gallery.dart';
import 'package:snapchef/views/home/widgets/quick_actions.dart';

import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';

void main() {
  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(create: (_) => MockConnectivityProvider()),
        ChangeNotifierProvider<CookbookViewModel>(create: (_) => MockCookbookViewModel()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => const HomeScreen(),
        ),
      ),
    );
  }

  testWidgets('HomeScreen displays greeting, title, welcome, and widgets', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('SnapChef'), findsOneWidget);
    expect(find.textContaining('Test'), findsOneWidget);
    expect(find.text('Welcome back to SnapChef! Let’s get cooking.'), findsOneWidget);
    expect(find.byType(QuickActions), findsOneWidget);
    expect(find.byType(FavoritesGallery), findsOneWidget);
  });
}