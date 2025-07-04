import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/notifications/upcoming_alerts_screen.dart';
import 'package:snapchef/views/notifications/widgets/alert_list_item.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_services.dart';
import '../../mocks/mock_user_viewmodel.dart';

import 'package:get_it/get_it.dart';

import '../../providers/connectivity_provider_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  late MockNotificationsViewModel notificationsViewModel;
  late MockUserViewModel userViewModel;
  late MockConnectivityProvider connectivityProvider;
  late MockSyncProvider mockSyncProvider;
  late MockSyncManager mockSyncManager;

  final getIt = GetIt.instance;

  setUp(() async {
    notificationsViewModel = MockNotificationsViewModel();
    userViewModel = MockUserViewModel();
    connectivityProvider = MockConnectivityProvider();
    mockSyncProvider = MockSyncProvider();
    mockSyncManager = MockSyncManager();

    await getIt.reset();

    getIt.registerSingleton<UserViewModel>(userViewModel);
    getIt.registerSingleton<NotificationsViewModel>(notificationsViewModel);
    getIt.registerSingleton<ConnectivityProvider>(connectivityProvider);
    getIt.registerSingleton<SyncProvider>(mockSyncProvider);
    getIt.registerSingleton<SyncManager>(mockSyncManager);

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

  tearDown(() async {
    await getIt.reset();
  });

  Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
        ChangeNotifierProvider<NotificationsViewModel>.value(
            value: notificationsViewModel),
        ChangeNotifierProvider<ConnectivityProvider>.value(
            value: connectivityProvider),
        ChangeNotifierProvider<SyncProvider>.value(value: mockSyncProvider),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('UpcomingAlertsScreen', () {
    testWidgets('shows alerts and filters', (tester) async {
      notificationsViewModel.alerts = [
        IngredientReminder(
          id: 'a1',
          ingredientName: 'Tomato',
          title: 'Tomato',
          body: 'Expires soon',
          scheduledTime: DateTime.now().add(const Duration(days: 1)),
          typeEnum: ReminderType.expiry,
          recipientId: userViewModel.user!.id,
        ),
        IngredientReminder(
          id: 'a2',
          ingredientName: 'Milk',
          title: 'Milk',
          body: 'Buy soon',
          scheduledTime: DateTime.now().add(const Duration(days: 2)),
          typeEnum: ReminderType.grocery,
          recipientId: userViewModel.user!.id,
        ),
      ] as List<AppNotification>;
      notificationsViewModel.isLoading = false;
      notificationsViewModel.notifyListeners();

      await tester.pumpWidget(
        wrapWithProviders(
          UpcomingAlertsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming Alerts'), findsOneWidget);
      expect(find.byType(AlertListItem), findsNWidgets(2));

      await tester.tap(find.byType(DropdownButton<ReminderType?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expiry').last);
      await tester.pumpAndSettle();
      expect(find.byType(AlertListItem), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<ReminderType?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grocery').last);
      await tester.pumpAndSettle();
      expect(find.byType(AlertListItem), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      notificationsViewModel.alerts = [];
      notificationsViewModel.isLoading = false;
      notificationsViewModel.notifyListeners();

      await tester.pumpWidget(
        wrapWithProviders(
          UpcomingAlertsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No upcoming alerts.'), findsOneWidget);
    });
  });

  group('AlertListItem', () {
    testWidgets('renders and triggers callbacks', (tester) async {
      final reminder = IngredientReminder(
        id: 'a1',
        ingredientName: 'Tomato',
        title: 'Tomato',
        body: 'Expires soon',
        scheduledTime: DateTime.now(),
        typeEnum: ReminderType.expiry,
        recipientId: 'u1',
      );
      bool edited = false;
      bool deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AlertListItem(
            notification: reminder,
            onEdit: () => edited = true,
            onDelete: () => deleted = true,
          ),
        ),
      );
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(edited, isTrue);
      expect(deleted, isTrue);
    });
  });
}
