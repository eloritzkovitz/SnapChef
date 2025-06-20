import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/providers/sync_actions/notification_sync_actions.dart';
import 'package:snapchef/models/notifications/friend_notification.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/services/backend_notification_service.dart';

class MockBackendNotificationService extends Mock
    implements BackendNotificationService {}

void main() {
  late MockBackendNotificationService mockService;
  late NotificationSyncActions actions;

  setUp(() {
    mockService = MockBackendNotificationService();
    actions = NotificationSyncActions(mockService);
  });

  FriendNotification getTestNotification() => FriendNotification(
        id: 'n1',
        title: 'Test',
        body: 'Body',
        scheduledTime: DateTime.now(),
        friendName: 'Alice',
        senderId: 's1',
        recipientId: 'r1',
      );

  test('add calls createNotification', () async {
    final notification = getTestNotification();
    final action = {
      'action': 'add',
      'notification': notification.toJson(),
    };
    await actions.handleNotificationAction(action);
    verify(mockService.createNotification(argThat(
      isA<FriendNotification>().having((n) => n.title, 'title', 'Test')
    ) as dynamic)).called(1);
  });

  test('edit calls updateNotification', () async {
    final notification = getTestNotification();
    final action = {
      'action': 'edit',
      'notification': notification.toJson(),
    };
    await actions.handleNotificationAction(action);
    verify(mockService.createNotification(argThat(
      isA<FriendNotification>().having((n) => n.title, 'title', 'Test')
    ) as dynamic)).called(1);
  });

  test('delete calls deleteNotification', () async {
    final action = {
      'action': 'delete',
      'notificationId': 'n1',
    };
    await actions.handleNotificationAction(action);
    verify(mockService.deleteNotification('n1')).called(1);
  });
}
