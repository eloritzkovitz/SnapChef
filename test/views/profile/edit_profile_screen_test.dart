import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/edit_profile_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_user_viewmodel.dart';

void main() {
  group('EditProfileScreen', () {
    late MockUserViewModel userViewModel;

    setUp(() {
      userViewModel = MockUserViewModel();
      userViewModel.setUser(
        User(
          id: 'u1',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          fridgeId: 'fridge1',
          cookbookId: 'cb1',
        ),
      );
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>(
            create: (_) => userViewModel,
          ),
          ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider(),
          ),
        ],
        child: const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
    }

    testWidgets('renders EditProfileScreen and fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });
  });
}