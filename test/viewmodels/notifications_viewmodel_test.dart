import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/services/backend_notification_service.dart';
import 'package:snapchef/services/notification_service.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';

@GenerateNiceMocks([
  MockSpec<NotificationService>(),
  MockSpec<BackendNotificationService>(),
  MockSpec<ConnectivityProvider>(),
  MockSpec<SyncProvider>(),
  MockSpec<SyncManager>(),
])
import 'notifications_viewmodel_test.mocks.dart';

IngredientReminder get testNotif => IngredientReminder(
      id: 'n1',
      ingredientName: 'Tomato',
      title: 'Test',
      body: 'Body',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      typeEnum: ReminderType.notice,
      recipientId: 'u1',
    );

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  const MethodChannel timezoneChannel = MethodChannel('flutter_timezone');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    timezoneChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    },
  );
  await dotenv.load(fileName: ".env");

  late NotificationsViewModel vm;
  late MockNotificationService mockNotifService;
  late MockBackendNotificationService mockBackendService;
  late MockConnectivityProvider mockConnectivity;
  late MockSyncProvider mockSyncProvider;
  late MockSyncManager mockSyncManager;

  setUp(() {
    GetIt.I.reset();
    mockNotifService = MockNotificationService();
    mockBackendService = MockBackendNotificationService();
    mockConnectivity = MockConnectivityProvider();
    mockSyncProvider = MockSyncProvider();
    mockSyncManager = MockSyncManager();

    GetIt.I.registerSingleton<NotificationService>(mockNotifService);
    GetIt.I.registerSingleton<BackendNotificationService>(mockBackendService);
    GetIt.I.registerSingleton<ConnectivityProvider>(mockConnectivity);
    GetIt.I.registerSingleton<SyncProvider>(mockSyncProvider);
    GetIt.I.registerSingleton<SyncManager>(mockSyncManager);

    when(mockNotifService.initNotification()).thenAnswer((_) async {});
    when(mockNotifService.getStoredNotifications())
        .thenAnswer((_) async => [testNotif]);
    when(mockNotifService.saveStoredNotifications(any))
        .thenAnswer((_) async {});
    when(mockNotifService.scheduleNotification(any)).thenAnswer((_) async {});
    when(mockNotifService.editNotification(any, any)).thenAnswer((_) async {});
    when(mockNotifService.generateUniqueNotificationId())
        .thenAnswer((_) async => 'uniqueId');

    when(mockBackendService.fetchNotifications())
        .thenAnswer((_) async => [testNotif]);
    when(mockBackendService.createNotification(any))
        .thenAnswer((_) async => testNotif);
    when(mockBackendService.updateNotification(any, any))
        .thenAnswer((_) async => testNotif);
    when(mockBackendService.deleteNotification(any)).thenAnswer((_) async {});

    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockSyncProvider.getPendingActions(any)).thenAnswer((_) async => []);
    when(mockSyncProvider.addPendingAction(any, any)).thenReturn(null);

    vm = NotificationsViewModel(
      notificationService: mockNotifService,
      backendNotificationService: mockBackendService,
      connectivityProvider: mockConnectivity,
      syncProvider: mockSyncProvider,
      syncManager: mockSyncManager,
    );
  });

  test('syncNotifications loads from local when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockNotifService.getStoredNotifications())
        .thenAnswer((_) async => [testNotif]);

    await vm.syncNotifications();

    expect(vm.isLoading, isFalse);
    expect(vm.alerts.length + vm.notifications.length, 1);
  });

  test('syncNotifications loads from backend when online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockBackendService.fetchNotifications())
        .thenAnswer((_) async => [testNotif]);
    when(mockSyncProvider.getPendingActions(any)).thenAnswer((_) async => []);

    await vm.syncNotifications();

    expect(vm.isLoading, isFalse);
    expect(vm.alerts.length + vm.notifications.length, 1);
  });

  test('addNotification queues when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    await vm.addNotification(testNotif);
    verify(mockSyncProvider.addPendingAction('notifications', any)).called(1);
    expect(vm.alerts.length + vm.notifications.length, greaterThanOrEqualTo(1));
  });

  test('addNotification calls backend when online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    await vm.addNotification(testNotif);
    verify(mockBackendService.createNotification(any)).called(1);
    expect(vm.alerts.length + vm.notifications.length, greaterThanOrEqualTo(1));
  });

  test('editNotification queues when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    await vm.editNotification('n1', testNotif);
    verify(mockSyncProvider.addPendingAction('notifications', any)).called(1);
  });

  test('editNotification calls backend when online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    await vm.editNotification('n1', testNotif);
    verify(mockBackendService.updateNotification(any, any)).called(1);
    verify(mockNotifService.editNotification(any, any)).called(1);
  });

  test('deleteNotification queues when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    await vm.deleteNotification('n1');
    verify(mockSyncProvider.addPendingAction('notifications', any)).called(1);
    expect(vm.alerts.where((n) => n.id == 'n1'), isEmpty);
    expect(vm.notifications.where((n) => n.id == 'n1'), isEmpty);
  });

  test('deleteNotification calls backend when online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    await vm.addNotification(testNotif);
    await vm.deleteNotification('n1');
    verify(mockBackendService.deleteNotification('n1')).called(1);
    expect(vm.alerts.where((n) => n.id == 'n1'), isEmpty);
    expect(vm.notifications.where((n) => n.id == 'n1'), isEmpty);
  });

  test('generateUniqueNotificationId delegates to service', () async {
    final id = await vm.generateUniqueNotificationId();
    expect(id, 'uniqueId');
    verify(mockNotifService.generateUniqueNotificationId()).called(1);
  });

  test('dispose cancels timers and subscriptions', () async {
    final sub = StreamController<AppNotification>();
    when(mockBackendService.notificationStream).thenAnswer((_) => sub.stream);
    vm.dispose();    
  }, skip: true);
}
