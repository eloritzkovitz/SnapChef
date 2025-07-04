import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/models/notifications/friend_notification.dart';
import 'package:snapchef/models/notifications/share_notification.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/notifications/widgets/notification_list_item.dart';
import 'package:snapchef/views/notifications/notifications_screen.dart';

import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';

class TestNotification extends AppNotification {
  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime scheduledTime;
  @override
  String get type => 'test';

  TestNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
  });

  @override
  Map<String, dynamic> toJson() => {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

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

  group('NotificationListItem', () {
    late MockUserViewModel userViewModel;

    setUp(() {
      userViewModel = MockUserViewModel();
      userViewModel.setFriends([
        User(
          id: 'sender1',
          firstName: 'Sender',
          lastName: 'One',
          email: 'sender1@example.com',
          fridgeId: 'f1',
          cookbookId: 'cb1',
          profilePicture: 'profile.jpg',
        ),
        User(
          id: 'sender2',
          firstName: 'Sender',
          lastName: 'Two',
          email: 'sender2@example.com',
          fridgeId: 'f2',
          cookbookId: 'cb2',
          profilePicture: '',
        ),
        User(
          id: 'sender3',
          firstName: 'Sender',
          lastName: 'NullPic',
          email: 'sender3@example.com',
          fridgeId: 'f3',
          cookbookId: 'cb3',
          profilePicture: null,
        ),
      ]);
    });

    Widget wrapNotif(Widget child) =>
        ChangeNotifierProvider<UserViewModel>.value(
          value: userViewModel,
          child: MaterialApp(home: Scaffold(body: child)),
        );

    testWidgets('renders generic notification', (tester) async {
      final notif = TestNotification(
        id: 'n5',
        title: 'Generic!',
        body: 'Generic notification.',
        scheduledTime: DateTime.now(),
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Generic!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('renders ShareNotification with missing sender',
        (tester) async {
      final notif = ShareNotification(
        id: 'n7',
        senderId: 'not_in_friends',
        recipientId: 'u1',
        title: 'Shared!',
        body: 'A recipe was shared.',
        scheduledTime: DateTime.now(),
        friendName: 'Unknown',
        recipeName: 'Mystery',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders FriendNotification with missing sender',
        (tester) async {
      final notif = FriendNotification(
        id: 'n8',
        senderId: 'not_in_friends',
        recipientId: 'u1',
        title: 'Friend!',
        body: 'You have a new friend.',
        scheduledTime: DateTime.now(),
        friendName: 'Unknown',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders notification with empty body', (tester) async {
      final notif = ShareNotification(
        id: 'n9',
        senderId: 'sender1',
        recipientId: 'u1',
        title: 'Shared!',
        body: '',
        scheduledTime: DateTime.now(),
        friendName: 'Sender One',
        recipeName: 'Pizza',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Shared!'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('renders ShareNotification with profile picture',
        (tester) async {
      final notif = ShareNotification(
        id: 'n1',
        senderId: 'sender1',
        recipientId: 'u1',
        title: 'Shared!',
        body: 'A recipe was shared.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender One',
        recipeName: 'Pizza',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Shared!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders ShareNotification without profile picture',
        (tester) async {
      final notif = ShareNotification(
        id: 'n2',
        senderId: 'sender2',
        recipientId: 'u1',
        title: 'Shared!',
        body: 'A recipe was shared.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender Two',
        recipeName: 'Cake',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Shared!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders ShareNotification with null profile picture',
        (tester) async {
      final notif = ShareNotification(
        id: 'n10',
        senderId: 'sender3',
        recipientId: 'u1',
        title: 'Shared!',
        body: 'Null profile picture.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender NullPic',
        recipeName: 'Soup',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders FriendNotification with profile picture',
        (tester) async {
      final notif = FriendNotification(
        id: 'n3',
        senderId: 'sender1',
        recipientId: 'u1',
        title: 'Friend!',
        body: 'You have a new friend.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender One',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Friend!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders FriendNotification without profile picture',
        (tester) async {
      final notif = FriendNotification(
        id: 'n4',
        senderId: 'sender2',
        recipientId: 'u1',
        title: 'Friend!',
        body: 'You have a new friend.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender Two',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Friend!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders FriendNotification with null profile picture',
        (tester) async {
      final notif = FriendNotification(
        id: 'n11',
        senderId: 'sender3',
        recipientId: 'u1',
        title: 'Friend!',
        body: 'Null profile picture.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender NullPic',
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders notification with formatted time', (tester) async {
      final notif = TestNotification(
        id: 'n12',
        title: 'Time Test',
        body: 'Check time formatting.',
        scheduledTime: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      final textWidgets = find.byType(Text);
      final regex =
          RegExp(r'\b\d+[smhdwyo]{1,2}\b');
      bool found = false;
      for (final element in textWidgets.evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null && regex.hasMatch(widget.data!)) {
          found = true;
          break;
        }
      }
      expect(found, isTrue,
          reason:
              'No text matching notification time format found in any Text widget');
    });

    testWidgets('shows delete icon when swiped', (tester) async {
      final notif = TestNotification(
        id: 'n13',
        title: 'Swipe Test',
        body: 'Swipe to delete.',
        scheduledTime: DateTime.now(),
      );
      await tester
          .pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(Dismissible)));
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      expect(find.byIcon(Icons.delete), findsOneWidget);
      await gesture.up();
    });

    testWidgets('calls onDelete and onDismissed', (tester) async {
      bool dismissed = false;
      final notif = ShareNotification(
        id: 'n6',
        title: 'Dismiss!',
        body: 'Dismiss notification.',
        scheduledTime: DateTime.now(),
        senderId: '',
        recipientId: '',
      );
      await tester.pumpWidget(wrapNotif(NotificationListItem(
        notification: notif,
        onDelete: () {},
        onDismissed: (_) => dismissed = true,
        confirmDismiss: (_) async => true,
      )));
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });
  });

  group('NotificationsScreen', () {
    late MockNotificationsViewModel notificationsViewModel;
    late MockConnectivityProvider connectivityProvider;

    setUp(() {
      notificationsViewModel = MockNotificationsViewModel();
      connectivityProvider = MockConnectivityProvider();
    });

    Widget wrapNotifScreen() => MultiProvider(
          providers: [
            ChangeNotifierProvider<NotificationsViewModel>.value(
                value: notificationsViewModel),
            ChangeNotifierProvider<ConnectivityProvider>.value(
                value: connectivityProvider),
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ],
          child: const MaterialApp(home: NotificationsScreen()),
        );

    testWidgets('shows loading indicator', (tester) async {
      notificationsViewModel.setLoading(true);
      await tester.pumpWidget(wrapNotifScreen());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message', (tester) async {
      notificationsViewModel.setError('Failed to load');
      await tester.pumpWidget(wrapNotifScreen());
      expect(find.textContaining('Failed'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      notificationsViewModel.setLoading(false);
      notificationsViewModel.notifications = [];
      await tester.pumpWidget(wrapNotifScreen());
      await tester.pumpAndSettle();
      expect(find.textContaining('No notifications'), findsOneWidget);
    });

    testWidgets('shows notifications list', (tester) async {
      notificationsViewModel.setLoading(false);
      notificationsViewModel.notifications = [
        TestNotification(
          id: 'n1',
          title: 'Test',
          body: 'Body',
          scheduledTime: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(wrapNotifScreen());
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('shows offline message', (tester) async {
      connectivityProvider.isOffline = true;
      await tester.pumpWidget(wrapNotifScreen());
      expect(find.textContaining('unavailable offline'), findsOneWidget);
    });

    testWidgets('can dismiss and undo notification', (tester) async {
      notificationsViewModel.setLoading(false);
      notificationsViewModel.notifications = [
        TestNotification(
          id: 'n1',
          title: 'Test',
          body: 'Body',
          scheduledTime: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(wrapNotifScreen());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.textContaining('removed'), findsOneWidget);
      // Tap undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
