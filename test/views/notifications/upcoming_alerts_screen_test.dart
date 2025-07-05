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

    testWidgets('shows loading indicator', (tester) async {
      notificationsViewModel.isLoading = true;
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(UpcomingAlertsScreen()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('filters out alerts for other users', (tester) async {
      notificationsViewModel.isLoading = false;
      notificationsViewModel.alerts = [
        IngredientReminder(
          id: 'a3',
          ingredientName: 'Egg',
          title: 'Egg',
          body: 'Other user alert',
          scheduledTime: DateTime.now(),
          typeEnum: ReminderType.expiry,
          recipientId: 'other_user',
        ),
      ];
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(UpcomingAlertsScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('No upcoming alerts.'), findsOneWidget);
    });

    testWidgets('edit dialog opens and cancel works', (tester) async {
      notificationsViewModel.isLoading = false;
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
      ];
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(UpcomingAlertsScreen()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      expect(find.text('Edit Reminder'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Reminder'), findsNothing);
    });

    testWidgets('edit dialog save works', (tester) async {
      notificationsViewModel.isLoading = false;
      notificationsViewModel.disableTimeFilter = true;
      await notificationsViewModel.addNotification(
        IngredientReminder(
          id: 'a1',
          ingredientName: 'Tomato',
          title: 'Tomato',
          body: 'Expires soon',
          scheduledTime: DateTime.now().add(const Duration(days: 7)),
          typeEnum: ReminderType.expiry,
          recipientId: userViewModel.user!.id,
        ),
      );
      
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(const UpcomingAlertsScreen()),
      );
      await tester.pumpAndSettle();

      // Scroll to the alert by text (ingredient name) to ensure it's visible
      final tomatoText = find.text('Tomato');
      await tester.ensureVisible(tomatoText);
      await tester.pumpAndSettle();

      // Find the AlertListItem for 'Tomato'
      final alertItem = find.ancestor(
        of: tomatoText,
        matching: find.byType(AlertListItem),
      );

      // Find the edit icon for this specific alert
      final editIcon = find.descendant(
        of: alertItem,
        matching: find.byIcon(Icons.edit),
      );
      await tester.ensureVisible(editIcon);
      await tester.pumpAndSettle();

      // Try normal tap first, fallback to gesture if warning persists
      try {
        await tester.tap(editIcon);
        await tester.pumpAndSettle();
      } catch (_) {
        final editIconElement = editIcon.evaluate().first;
        final renderBox = editIconElement.renderObject as RenderBox;
        final center =
            renderBox.localToGlobal(renderBox.size.center(Offset.zero));
        final gesture = await tester.startGesture(center);
        await gesture.up();
        await tester.pumpAndSettle();
      }

      // Confirm the dialog opened
      expect(find.text('Edit Reminder'), findsOneWidget);

      // Interact with date/time pickers if present and change the value
      final datePicker = find.byIcon(Icons.calendar_today);
      if (datePicker.evaluate().isNotEmpty) {
        await tester.tap(datePicker);
        await tester.pumpAndSettle();
        // Try to pick a different year if possible
        if (find.text('2026').evaluate().isNotEmpty) {
          await tester.tap(find.text('2026'));
          await tester.pumpAndSettle();
        }
        if (find.text('OK').evaluate().isNotEmpty) {
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
        } else if (find.text('Save').evaluate().isNotEmpty) {
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
        }
      }
      final timePicker = find.byIcon(Icons.access_time);
      if (timePicker.evaluate().isNotEmpty) {
        await tester.tap(timePicker);
        await tester.pumpAndSettle();
        // Pick a different hour than the current one
        int hourToTap = -1;
        for (int i = 0; i < 24; i++) {
          final hourFinder = find.text(i.toString());
          if (hourFinder.evaluate().isNotEmpty && i != 10) {
            hourToTap = i;
            break;
          }
        }
        if (hourToTap != -1) {
          final hourText = find.text(hourToTap.toString());
          await tester.tap(hourText.first);
          await tester.pumpAndSettle();
        }
        if (find.text('OK').evaluate().isNotEmpty) {
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
        } else if (find.text('Save').evaluate().isNotEmpty) {
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
        }
      }

      // Tap the Save button in the dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();
    });

    testWidgets('edit dialog shows error on exception', (tester) async {
      notificationsViewModel.isLoading = false;
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
      ];
      notificationsViewModel.editNotificationCallback =
          (String id, AppNotification notif) async {
        throw Exception('fail');
      };
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(UpcomingAlertsScreen()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('delete dialog opens and cancel works', (tester) async {
      notificationsViewModel.isLoading = false;
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
      ];
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(UpcomingAlertsScreen()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text('Delete Notification'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Notification'), findsNothing);
    });

    testWidgets('delete dialog confirm works', (tester) async {
      notificationsViewModel.isLoading = false;
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
      ];
      bool deleteCalled = false;
      notificationsViewModel.deleteNotificationCallback = (String id) async {
        deleteCalled = true;
      };
      notificationsViewModel.notifyListeners();
      await tester.pumpWidget(
        wrapWithProviders(UpcomingAlertsScreen()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
      expect(find.text('Delete Notification'), findsNothing);
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
