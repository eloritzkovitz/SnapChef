import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../models/notifications/app_notification.dart';
import '../models/notifications/ingredient_reminder.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_provider.dart';
import '../services/backend_notification_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../utils/token_util.dart';
import '../viewmodels/user_viewmodel.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService;
  final BackendNotificationService _backendService;
  final ConnectivityProvider connectivityProvider;
  final SyncProvider syncProvider;
  final SyncManager syncManager;

  NotificationsViewModel({
    NotificationService? notificationService,
    BackendNotificationService? backendNotificationService,
    ConnectivityProvider? connectivityProvider,
    SyncProvider? syncProvider,
    SyncManager? syncManager,
  })  : _notificationService = notificationService ?? NotificationService(),
        _backendService = backendNotificationService ??
            BackendNotificationService(baseUrl: dotenv.env['SERVER_IP']!),
        connectivityProvider =
            connectivityProvider ?? GetIt.I<ConnectivityProvider>(),
        syncProvider = syncProvider ?? GetIt.I<SyncProvider>(),
        syncManager = syncManager ?? GetIt.I<SyncManager>() {
    _initialize();
    _startAutoRefresh();
    _startAutoCleanup();
  }

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  StreamSubscription<AppNotification>? _wsSubscription;
  Timer? _refreshTimer;
  Timer? _cleanupTimer;

  // Alerts: only future expiry/grocery notifications
  List<AppNotification> get alerts => _notifications
      .where((n) =>
          (n.type == 'expiry' || n.type == 'grocery') &&
          n.scheduledTime.isAfter(DateTime.now()))
      .toList();

  // Notifications: all others, plus expired alerts
  List<AppNotification> get notifications => _notifications
      .where((n) =>
          n.type != 'expiry' && n.type != 'grocery' ||
          ((n.type == 'expiry' || n.type == 'grocery') &&
              n.scheduledTime.isBefore(DateTime.now())))
      .toList();

  bool get isLoading => _isLoading;  

  /// Starts a periodic timer to refresh notifications every 5 minutes.
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      syncNotifications();
    });
  }

  /// Periodically moves expired alerts to notifications and removes from alerts.
  void _startAutoCleanup() {
    _cleanupTimer?.cancel(); // Cancel previous timer if any
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      final expiredAlerts = _notifications
          .where((n) =>
              (n.type == 'expiry' || n.type == 'grocery') &&
              n.scheduledTime.isBefore(now))
          .toList();

      for (final alert in expiredAlerts) {
        // Promote to a persistent notification of type 'notice'
        final notice = IngredientReminder(
          id: await generateUniqueNotificationId(),
          ingredientName: (alert as IngredientReminder).ingredientName,
          title: alert.title,
          body: alert.body,
          scheduledTime: now,
          typeEnum: ReminderType.notice,
          recipientId: alert.recipientId,
        );
        await addNotification(notice);

        // Try to remove the expired alert
        try {
          await deleteNotification(alert.id);
        } catch (e) {
          debugPrint('Failed to delete alert ${alert.id}: $e');
        }
      }

      // Only notify if not disposed
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _cleanupTimer?.cancel();
    _wsSubscription?.cancel();
    _backendService.disconnectWebSocket();
    super.dispose();
  }

  /// Initializes the notification service and loads the notifications
  Future<void> _initialize() async {
    await _notificationService.initNotification();
    await syncNotifications();
  }

  /// Connects to WebSocket and listens for real-time notifications using context.
  Future<void> connectWebSocketAndListenWithContext(
      BuildContext context) async {
    final userToken = await TokenUtil.getAccessToken();
    if (userToken == null) return;

    if (context.mounted) {
      // Get userId from the UserViewModel using Provider and the given context
      final userId =
          Provider.of<UserViewModel>(context, listen: false).user?.id;
      if (userId == null) return;

      _backendService.connectToWebSocket(userToken, userId);

      _wsSubscription =
          _backendService.notificationStream?.listen((notif) async {
        await _notificationService.showNotification(notif.title, notif.body);
        // Prevent duplicates
        if (!_notifications.any((n) => n.id == notif.id)) {
          _notifications.insert(0, notif);
          notifyListeners();
        }
      });
    }
  }

  /// Syncs backend and local notifications.
  Future<void> syncNotifications() async {
    _isLoading = true;
    notifyListeners();

    final isOffline = connectivityProvider.isOffline;

    if (isOffline) {
      _notifications = await _notificationService.getStoredNotifications();
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 1. Fetch from backend
    final backendNotifications = await _backendService.fetchNotifications();

    // 2. Get pending notification actions (add/edit) from SyncProvider
    final pendingActions = await syncProvider.getPendingActions('notifications');

    // 3. Apply pending actions to backendNotifications
    List<AppNotification> mergedNotifications = List.from(backendNotifications);
    for (final action in pendingActions) {
      switch (action['action']) {
        case 'add':
          mergedNotifications.insert(
              0, AppNotification.fromJson(action['notification']));
          break;
        case 'edit':
          final idx = mergedNotifications
              .indexWhere((n) => n.id == action['notification']['id']);
          if (idx != -1) {
            mergedNotifications[idx] =
                AppNotification.fromJson(action['notification']);
          }
          break;
        case 'delete':
          mergedNotifications
              .removeWhere((n) => n.id == action['notificationId']);
          break;
      }
    }

    // 4. Save merged list to local storage and update _notifications
    await _notificationService.saveStoredNotifications(mergedNotifications);
    _notifications = mergedNotifications;
    _isLoading = false;
    notifyListeners();
  }

  /// Generates a unique notification ID.
  Future<String> generateUniqueNotificationId() async {
    return await _notificationService.generateUniqueNotificationId();
  }

  /// Adds a new notification.
  Future<void> addNotification(AppNotification notification,
      [String? userId]) async {
    if (connectivityProvider.isOffline) {
      // Queue the action for later sync
      GetIt.I<SyncProvider>().addPendingAction(
        'notifications',
        {
          'action': 'add',
          'notification': notification.toJson(),
        },
      );
      // Optionally add to local list for immediate UI feedback
      if (userId == null) {
        _notifications.insert(0, notification);
        notifyListeners();
        // Persist to local storage
        await _notificationService.saveStoredNotifications(_notifications);
        // Schedule with local notifications plugin
        await _notificationService.scheduleNotification(notification);
      }
      return;
    }
    final created = await _backendService.createNotification(notification);
    if (userId == null) {
      _notifications.insert(0, created);
      notifyListeners();
    }
  }

  /// Updates an existing notification.
  Future<void> editNotification(
      String id, AppNotification updatedNotification) async {
    if (connectivityProvider.isOffline) {
      GetIt.I<SyncProvider>().addPendingAction(
        'notifications',
        {
          'action': 'edit',
          'notification': updatedNotification.toJson()..['id'] = id,
        },
      );
      // Optionally update local list for immediate UI feedback
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = updatedNotification;
        notifyListeners();
      }
      return;
    }
    final backendNotif =
        await _backendService.updateNotification(id, updatedNotification);
    await _notificationService.editNotification(id, backendNotif);
  }

  /// Deletes a notification.
  Future<void> deleteNotification(String id) async {
    if (connectivityProvider.isOffline) {
      GetIt.I<SyncProvider>().addPendingAction(
        'notifications',
        {
          'action': 'delete',
          'notificationId': id,
        },
      );
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
      return;
    }
    await _backendService.deleteNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}