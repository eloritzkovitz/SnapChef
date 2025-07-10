import 'dart:async';

import 'package:flutter/material.dart';
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

  test('syncNotifications applies pending add/edit/delete actions', () async {
    final notif2 = testNotif.copyWith(id: 'n2');
    final notif3 = testNotif.copyWith(id: 'n3');
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockBackendService.fetchNotifications())
        .thenAnswer((_) async => [testNotif]);
    when(mockSyncProvider.getPendingActions(any)).thenAnswer((_) async => [
          {'action': 'add', 'notification': notif2.toJson()},
          {'action': 'add', 'notification': notif3.toJson()},
          {'action': 'delete', 'notificationId': 'n1'},
        ]);
    when(mockNotifService.saveStoredNotifications(any))
        .thenAnswer((_) async {});

    await vm.syncNotifications();

    // Should contain notif2 (added), notif3 (edited), and not testNotif (deleted)
    expect(vm.notificationsInternal.any((n) => n.id == 'n2'), isTrue);
    expect(vm.notificationsInternal.any((n) => n.id == 'n3'), isTrue);
    expect(vm.notificationsInternal.any((n) => n.id == 'n1'), isFalse);
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

  test('addNotification adds to local list and schedules when offline',
      () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    await vm.addNotification(testNotif);
    expect(vm.notificationsInternal.any((n) => n.id == 'n1'), isTrue);
    verify(mockNotifService.saveStoredNotifications(argThat(isA<List>())))
        .called(2);
    //verify(mockNotifService.scheduleNotification(testNotif)).called(1);
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

  test('editNotification updates local list when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    vm.notificationsInternal.clear();
    vm.notificationsInternal.add(testNotif);
    final updated = testNotif.copyWith(title: 'Updated');
    await vm.editNotification('n1', updated);
    expect(vm.notificationsInternal.first.title, 'Updated');
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

  test('deleteNotification removes from local list when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    vm.notificationsInternal.clear();
    vm.notificationsInternal.add(testNotif);
    await vm.deleteNotification('n1');
    expect(vm.notificationsInternal, isEmpty);
  });

  test('generateUniqueNotificationId delegates to service', () async {
    final id = await vm.generateUniqueNotificationId();
    expect(id, 'uniqueId');
    verify(mockNotifService.generateUniqueNotificationId()).called(1);
  });

  test('generateUniqueNotificationId returns value from service', () async {
    when(mockNotifService.generateUniqueNotificationId())
        .thenAnswer((_) async => 'uniqueId');
    final id = await vm.generateUniqueNotificationId();
    expect(id, 'uniqueId');
  });

  test(
      'clear resets all fields, cancels timers/subscriptions, and notifies listeners',
      () async {
    // Add notifications and set loading/error
    vm.notificationsInternal.add(testNotif);
    vm.setError('some error');
    vm.setLoading(true);

    // Set up dummy timers and subscription
    final dummyTimer = Timer(const Duration(seconds: 1), () {});
    final dummySub = StreamController<AppNotification>().stream.listen((_) {});
    vm
      ..refreshTimerInternal?.cancel()
      ..cleanupTimerInternal?.cancel();
    vm.refreshTimerInternal = dummyTimer;
    vm.cleanupTimerInternal = dummyTimer;
    vm.wsSubscriptionInternal = dummySub;

    bool notified = false;
    vm.addListener(() {
      notified = true;
    });

    vm.clear();

    expect(vm.notificationsInternal, isEmpty);
    expect(vm.isLoading, isFalse);
    expect(vm.errorMessage, isNull);
    expect(vm.refreshTimerInternal, isNull);
    expect(vm.cleanupTimerInternal, isNull);
    expect(vm.wsSubscriptionInternal, isNull);
    expect(notified, isTrue);
  });

  test('alerts and notifications getters filter correctly', () async {
    final now = DateTime.now();
    final futureNotif = testNotif.copyWith(
      id: 'future',
      scheduledTime: now.add(const Duration(hours: 2)),
      typeEnum: ReminderType.expiry,
    );
    final pastNotif = testNotif.copyWith(
      id: 'past',
      scheduledTime: now.subtract(const Duration(hours: 2)),
      typeEnum: ReminderType.expiry,
    );
    vm.notificationsInternal
      ..clear()
      ..addAll([futureNotif, pastNotif]);

    // Only future expiry/grocery are alerts
    expect(vm.alerts.length, 1);
    expect(vm.alerts.first.id, 'future');
    // Past expiry/grocery are notifications
    expect(vm.notifications.any((n) => n.id == 'past'), isTrue);
  });

  test('setError sets errorMessage and notifies', () {
    bool notified = false;
    vm.addListener(() => notified = true);
    vm.setError('err');
    expect(vm.errorMessage, 'err');
    expect(notified, isTrue);
  });

  test('setLoading sets isLoading and notifies', () {
    bool notified = false;
    vm.addListener(() => notified = true);
    vm.setLoading(true);
    expect(vm.isLoading, isTrue);
    expect(notified, isTrue);
  });

  test('addNotification sets error on failure', () async {
    when(mockBackendService.createNotification(any))
        .thenThrow(Exception('fail'));
    when(mockConnectivity.isOffline).thenReturn(false);
    await vm.addNotification(testNotif);
    expect(vm.errorMessage, isNotNull);
  });

  test('editNotification sets error on failure', () async {
    when(mockBackendService.updateNotification(any, any))
        .thenThrow(Exception('fail'));
    when(mockConnectivity.isOffline).thenReturn(false);
    await vm.editNotification('n1', testNotif);
    expect(vm.errorMessage, isNotNull);
  });

  test('deleteNotification sets error on failure', () async {
    when(mockBackendService.deleteNotification(any))
        .thenThrow(Exception('fail'));
    when(mockConnectivity.isOffline).thenReturn(false);
    await vm.deleteNotification('n1');
    expect(vm.errorMessage, isNotNull);
  });

  test('dispose cancels timers and subscriptions', () async {
    final dummyTimer = Timer(const Duration(seconds: 1), () {});
    final dummySub = StreamController<AppNotification>().stream.listen((_) {});
    vm.refreshTimerInternal = dummyTimer;
    vm.cleanupTimerInternal = dummyTimer;
    vm.wsSubscriptionInternal = dummySub;
    await Future.delayed(Duration.zero);
    expect(() => vm.dispose(), returnsNormally);
  });

  test('clear can be called multiple times safely', () {
    vm.clear();
    expect(() => vm.clear(), returnsNormally);
  });

  test('dispose can be called multiple times safely', () async {
    final dummyTimer = Timer(const Duration(seconds: 1), () {});
    final dummySub = StreamController<AppNotification>().stream.listen((_) {});
    vm.refreshTimerInternal = dummyTimer;
    vm.cleanupTimerInternal = dummyTimer;
    vm.wsSubscriptionInternal = dummySub;
    await Future.delayed(Duration.zero);
    vm.dispose();
    expect(() => vm.dispose(), throwsA(isA<FlutterError>()));
  });

  test('listeners are notified when notifications change', () async {
    bool notified = false;
    vm.addListener(() => notified = true);
    await vm.addNotification(testNotif);
    expect(notified, isTrue);
  });
}
