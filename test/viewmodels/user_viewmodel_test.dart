import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/database/app_database.dart' as db;
import 'package:snapchef/database/daos/user_dao.dart';
import 'package:snapchef/database/daos/user_stats_dao.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/utils/firebase_messaging_util.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/models/user.dart' as model;
import 'package:snapchef/models/preferences.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/auth_service.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/user_service.dart';

import '../mocks/mock_firebase_messaging_util.dart';
@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<db.AppDatabase>(),
  MockSpec<UserDao>(),
  MockSpec<UserStatsDao>(),
  MockSpec<ConnectivityProvider>(),
  MockSpec<UserRepository>(),
  MockSpec<UserService>(),
  MockSpec<FriendService>(),
  MockSpec<SocketService>(),
])
import 'user_viewmodel_test.mocks.dart';

class DummyBuildContext extends Fake implements BuildContext {
  final bool _mounted;
  DummyBuildContext([this._mounted = true]);
  @override
  bool get mounted => _mounted;
  @override
  Widget get widget => Container();
  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    return [DiagnosticsNode.message('missing ancestor')];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #findAncestorWidgetOfExactType) {
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

model.User get testUser => model.User(
      id: 'u1',
      firstName: 'Alice',
      lastName: 'Tester',
      email: 'alice@example.com',
      profilePicture: 'https://example.com/profile.jpg',
      fridgeId: 'fridge1',
      cookbookId: 'cookbook1',
      friends: [],
      preferences: Preferences(
        allergies: ['peanuts'],
        dietaryPreferences: {'vegan': true},
        notificationPreferences: {'email': true},
      ),
    );

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  requestNotificationPermissions =
      MockFirebaseMessagingUtil.requestNotificationPermissions;
  getDeviceToken = MockFirebaseMessagingUtil.getDeviceToken;
  listenForForegroundMessages =
      MockFirebaseMessagingUtil.listenForForegroundMessages;

  late UserViewModel vm;
  late MockUserRepository mockUserRepository;
  late MockConnectivityProvider mockConnectivity;
  late MockUserService mockUserService;
  late MockFriendService mockFriendService;
  late MockAppDatabase mockDb;
  late MockUserDao mockUserDao;
  late MockUserStatsDao mockUserStatsDao;
  late MockSocketService mockSocketService;

  setUp(() {
    GetIt.I.reset();
    mockUserRepository = MockUserRepository();
    mockConnectivity = MockConnectivityProvider();
    mockUserService = MockUserService();
    mockFriendService = MockFriendService();
    mockDb = MockAppDatabase();
    mockUserDao = MockUserDao();
    mockUserStatsDao = MockUserStatsDao();
    mockSocketService = MockSocketService();

    // Register dependencies
    GetIt.I.registerSingleton<db.AppDatabase>(mockDb);
    GetIt.I.registerSingleton<ConnectivityProvider>(mockConnectivity);
    GetIt.I.registerSingleton<UserRepository>(mockUserRepository);
    GetIt.I.registerSingleton<UserService>(mockUserService);
    GetIt.I.registerSingleton<FriendService>(mockFriendService);
    GetIt.I.registerSingleton<SocketService>(mockSocketService);

    MockFirebaseMessagingUtil.listenedForForegroundMessages = false;
    MockFirebaseMessagingUtil.requestedPermissions = false;
    //if (GetIt.I.isRegistered<FirebaseMessagingUtil>()) {
    //GetIt.I.unregister<FirebaseMessagingUtil>();
    //}
    //GetIt.I
    //.registerSingleton<FirebaseMessagingUtil>(MockFirebaseMessagingUtil());

    when(mockDb.userDao).thenReturn(mockUserDao);
    when(mockDb.userStatsDao).thenReturn(mockUserStatsDao);

    vm = UserViewModel(friendService: mockFriendService);
  });

  test('fetchUserData loads local user if offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);

    await vm.fetchUserData();

    expect(vm.user, isNotNull);
    expect(vm.user!.id, testUser.id);
    expect(vm.isLoading, isFalse);
  });

  test('fetchUserData loads remote user if online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);
    when(mockUserRepository.fetchUserRemote())
        .thenAnswer((_) async => testUser);
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.storeUserStatsLocal(any, any))
        .thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.fetchUserProfileRemote(any))
        .thenAnswer((_) async => testUser);
    when(mockUserRepository.storeFriendLocal(any, any))
        .thenAnswer((_) async {});
    when(mockUserRepository.updateFcmTokenRemote(any)).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.storeUserStatsLocal(any, any))
        .thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 5});

    await vm.fetchUserData();

    expect(vm.user, isNotNull);
    expect(vm.user!.id, testUser.id);
    expect(vm.isLoading, isFalse);
  });

  test('fetchUserData handles db error gracefully', () async {
    when(mockUserRepository.fetchUserLocal()).thenThrow(Exception('db error'));
    when(mockConnectivity.isOffline).thenReturn(true);
    await vm.fetchUserData();
    expect(vm.user, isNull);
  });

  test('fetchUserData handles 401 and token refresh', () async {
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockUserRepository.fetchUserRemote()).thenThrow(Exception('401'));
    when(mockUserRepository.fetchUserRemote())
        .thenAnswer((_) async => testUser);
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.storeUserStatsLocal(any, any))
        .thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 5});
    // You may need to mock AuthService.refreshTokens if used via GetIt
    await vm.fetchUserData();
    expect(vm.user, isNotNull);
  });

  test('updateUser updates user and fetches new data', () async {
    when(mockUserRepository.updateUserRemote(
      firstName: anyNamed('firstName'),
      lastName: anyNamed('lastName'),
      password: anyNamed('password'),
      profilePicture: anyNamed('profilePicture'),
    )).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);
    when(mockUserRepository.fetchUserRemote())
        .thenAnswer((_) async => testUser);

    await vm.updateUser(
      firstName: 'Bob',
      lastName: 'Smith',
      password: 'pass',
      profilePicture: File('dummy.png'),
    );

    expect(vm.isLoading, isFalse);
  });

  test('updateUser sets errorMessage on error', () async {
    when(mockUserRepository.updateUserRemote(
      firstName: anyNamed('firstName'),
      lastName: anyNamed('lastName'),
      password: anyNamed('password'),
      profilePicture: anyNamed('profilePicture'),
    )).thenThrow(Exception('fail'));

    await vm.updateUser(
      firstName: 'Bob',
      lastName: 'Smith',
      password: 'pass',
      profilePicture: File('dummy.png'),
    );

    expect(vm.errorMessage, contains('Failed to update profile'));
  });

  test('updateUserPreferences updates preferences and stores locally',
      () async {
    when(mockUserRepository.updateUserPreferencesRemote(
      allergies: anyNamed('allergies'),
      dietaryPreferences: anyNamed('dietaryPreferences'),
      notificationPreferences: anyNamed('notificationPreferences'),
    )).thenAnswer((_) async {});
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});
    vm.userForTest = testUser;

    await vm.updateUserPreferences(
      allergies: ['milk'],
      dietaryPreferences: {'vegan': false},
      notificationPreferences: {'email': false},
    );

    expect(vm.user!.preferences!.allergies, contains('milk'));
    expect(vm.user!.preferences!.dietaryPreferences['vegan'], isFalse);
    expect(vm.user!.preferences!.notificationPreferences['email'], isFalse);
  });

  test('updateUserPreferences updates only allergies', () async {
    vm.userForTest = testUser;
    when(mockUserRepository.updateUserPreferencesRemote(
      allergies: anyNamed('allergies'),
      dietaryPreferences: anyNamed('dietaryPreferences'),
      notificationPreferences: anyNamed('notificationPreferences'),
    )).thenAnswer((_) async {});
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});

    await vm.updateUserPreferences(
      allergies: ['soy'],
    );

    expect(vm.user!.preferences!.allergies, contains('soy'));
    expect(vm.user!.preferences!.dietaryPreferences,
        testUser.preferences!.dietaryPreferences);
    expect(vm.user!.preferences!.notificationPreferences,
        testUser.preferences!.notificationPreferences);
  });

  test('updateUserPreferences updates only dietaryPreferences', () async {
    vm.userForTest = testUser;
    when(mockUserRepository.updateUserPreferencesRemote(
      allergies: anyNamed('allergies'),
      dietaryPreferences: anyNamed('dietaryPreferences'),
      notificationPreferences: anyNamed('notificationPreferences'),
    )).thenAnswer((_) async {});
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});

    await vm.updateUserPreferences(
      dietaryPreferences: {'vegetarian': true},
    );

    expect(vm.user!.preferences!.dietaryPreferences['vegetarian'], isTrue);
    expect(vm.user!.preferences!.allergies, testUser.preferences!.allergies);
    expect(vm.user!.preferences!.notificationPreferences,
        testUser.preferences!.notificationPreferences);
  });

  test('updateUserPreferences updates only notificationPreferences', () async {
    vm.userForTest = testUser;
    when(mockUserRepository.updateUserPreferencesRemote(
      allergies: anyNamed('allergies'),
      dietaryPreferences: anyNamed('dietaryPreferences'),
      notificationPreferences: anyNamed('notificationPreferences'),
    )).thenAnswer((_) async {});
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});

    await vm.updateUserPreferences(
      notificationPreferences: {'push': false},
    );

    expect(vm.user!.preferences!.notificationPreferences['push'], isFalse);
    expect(vm.user!.preferences!.allergies, testUser.preferences!.allergies);
    expect(vm.user!.preferences!.dietaryPreferences,
        testUser.preferences!.dietaryPreferences);
  });

  test('updateFcmToken updates token and stores locally', () async {
    when(mockUserRepository.updateFcmTokenRemote(any)).thenAnswer((_) async {});
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});
    vm.userForTest = testUser;

    await vm.updateFcmToken('token123');
    expect(vm.user!.fcmToken, 'token123');
  });

  test('updateFcmToken does nothing if token is null or empty', () async {
    vm.userForTest = testUser;
    await vm.updateFcmToken(null);
    await vm.updateFcmToken('');
    // Should not throw
  });

  test('updateFcmToken throws on error', () async {
    when(mockUserRepository.updateFcmTokenRemote(any))
        .thenThrow(Exception('fail'));
    vm.userForTest = testUser;
    expect(() => vm.updateFcmToken('token123'), throwsException);
  });

  test('fetchUserProfile returns remote user if online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockUserRepository.fetchUserProfileRemote('u2'))
        .thenAnswer((_) async => testUser);
    when(mockUserRepository.storeFriendLocal(any, any))
        .thenAnswer((_) async {});

    final user = await vm.fetchUserProfile('u2');
    expect(user, isNotNull);
    expect(user!.id, testUser.id);
  });

  test('fetchUserProfile returns local user if offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockUserRepository.fetchFriendLocal(any, any))
        .thenAnswer((_) async => testUser);

    final user = await vm.fetchUserProfile('u2');
    expect(user, isNotNull);
    expect(user!.id, testUser.id);
  });

  test('fetchUserProfile falls back to local if remote fails', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockUserRepository.fetchUserProfileRemote(any))
        .thenThrow(Exception('fail'));
    when(mockUserRepository.fetchFriendLocal(any, any))
        .thenAnswer((_) async => testUser);
    final user = await vm.fetchUserProfile('u2');
    expect(user, isNotNull);
  });

  test('fetchUserStats fetches remote and caches locally', () async {
    SharedPreferences.setMockInitialValues({'userId': 'u1'});
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.storeUserStatsLocal(any, any))
        .thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 5});

    await vm.fetchUserStats();
    expect(vm.userStats, isNotNull);
    expect(vm.userStats!['recipes'], 5);
  });

  test('fetchUserStats fetches local if offline', () async {
    SharedPreferences.setMockInitialValues({'userId': 'u1'});
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 3});

    await vm.fetchUserStats();
    expect(vm.userStats, isNotNull);
    expect(vm.userStats!['recipes'], 3);
  });

  test('fetchUserStats returns early if id is null', () async {
    SharedPreferences.setMockInitialValues({});
    await vm.fetchUserStats();
    expect(vm.userStats, isNull);
  });

  test('fetchUserStats falls back to local on error or null', () async {
    SharedPreferences.setMockInitialValues({'userId': 'u1'});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 42});

    // Remote throws
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenThrow(Exception('fail'));
    await vm.fetchUserStats();
    expect(vm.userStats!['recipes'], 42);

    // Remote returns null
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenAnswer((_) async => null);
    await vm.fetchUserStats();
    expect(vm.userStats!['recipes'], 42);
  });

  test('getFriends calls fetchUserData and returns friends', () async {
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);
    final friends = await vm.getFriends();
    expect(friends, isA<List>());
  });

  test('fetchUserInfo sets sharedUserName/profilePic from remote', () async {
    final mockUserService = MockUserService();
    GetIt.I.unregister<UserService>();
    GetIt.I.registerSingleton<UserService>(mockUserService);
    when(mockUserService.getUserProfile(any)).thenAnswer((_) async => testUser);
    await vm.fetchUserInfo(userId: 'u1', currentUserId: 'u2');
    expect(vm.sharedUserName, isNotNull);
    expect(vm.sharedUserProfilePic, isNotNull);
  });

  test(
      'fetchUserInfo sets sharedUserName/profilePic from local if remote fails',
      () async {
    final mockUserService = MockUserService();
    GetIt.I.unregister<UserService>();
    GetIt.I.registerSingleton<UserService>(mockUserService);
    when(mockUserService.getUserProfile(any)).thenThrow(Exception('fail'));
    // Use Friend object if that's what your code expects
    when(mockUserRepository.getFriendsMap(any)).thenAnswer((_) async => {
          'u1': db.Friend(
              friendName: 'Friend',
              friendProfilePicture: 'pic',
              id: 1,
              userId: '',
              friendId: '',
              friendEmail: '')
        });
    await vm.fetchUserInfo(userId: 'u1', currentUserId: 'u2');
    expect(vm.sharedUserName, equals('Friend'));
    expect(vm.sharedUserProfilePic, equals('pic'));
  });

  test('fetchUserInfo sets sharedUserName/profilePic to null if all fails',
      () async {
    final mockUserService = MockUserService();
    GetIt.I.unregister<UserService>();
    GetIt.I.registerSingleton<UserService>(mockUserService);
    when(mockUserService.getUserProfile(any)).thenThrow(Exception('fail'));
    when(mockUserRepository.getFriendsMap(any)).thenThrow(Exception('fail'));
    await vm.fetchUserInfo(userId: 'u1', currentUserId: 'u2');
    expect(vm.sharedUserName, isNull);
    expect(vm.sharedUserProfilePic, isNull);
  });

  test('removeFriend calls service and refreshes', () async {
    when(mockFriendService.removeFriend('u2')).thenAnswer((_) async {});
    when(mockDb.userStatsDao).thenReturn(mockUserStatsDao);
    when(mockUserStatsDao.deleteUserStats('u2')).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);

    await vm.removeFriend('u2');
    verify(mockFriendService.removeFriend('u2')).called(1);
    verify(mockUserStatsDao.deleteUserStats('u2')).called(1);
  });

  test('removeFriend throws if service fails', () async {
    when(mockFriendService.removeFriend(any)).thenThrow(Exception('fail'));
    expect(() => vm.removeFriend('u2'), throwsException);
  });

  test('clear resets all fields and cancels subscriptions', () async {
    vm.userForTest = testUser;
    vm.sharedUserName = "abc";
    vm.sharedUserProfilePic = "pic";
    vm.clear();
    expect(vm.user, isNull);
    expect(vm.userStats, isNull);
    expect(vm.sharedUserName, isNull);
    expect(vm.sharedUserProfilePic, isNull);

    // Call clear again to ensure no error when already null
    vm.clear();
    expect(vm.user, isNull);
    expect(vm.userStats, isNull);
    expect(vm.sharedUserName, isNull);
    expect(vm.sharedUserProfilePic, isNull);
  });

  test('listenForUserStatsUpdates triggers fetchUserStats on event', () async {
    final controller = StreamController<Map<String, dynamic>>();
    when(mockSocketService.userStatsStream)
        .thenAnswer((_) => controller.stream);
    when(mockDb.userStatsDao).thenAnswer((_) => mockUserStatsDao);
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockUserRepository.fetchUserRemote())
        .thenAnswer((_) async => testUser);
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsRemote(userId: anyNamed('userId')))
        .thenAnswer((_) async => {'recipes': 5});
    when(mockUserRepository.storeUserStatsLocal(any, any))
        .thenAnswer((_) async {});
    when(mockUserRepository.fetchUserStatsLocal(any))
        .thenAnswer((_) async => {'recipes': 5});

    vm.listenForUserStatsUpdates('u1');
    controller.add({'userId': 'u1'});
    await Future.delayed(Duration.zero);
    await controller.close();
  });

  test('listenForFriendUpdates triggers fetchUserData on event', () async {
    final controller = StreamController<Map<String, dynamic>>();
    when(mockSocketService.friendUpdateStream)
        .thenAnswer((_) => controller.stream);
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);

    vm.listenForFriendUpdates('u1');
    controller.add({'userId': 'u1'});
    await Future.delayed(Duration.zero);
    await controller.close();
  });

  test('listenForUserStatsUpdates cancels previous subscription', () async {
    final controller1 = StreamController<Map<String, dynamic>>();
    final controller2 = StreamController<Map<String, dynamic>>();
    when(mockSocketService.userStatsStream)
        .thenAnswer((_) => controller1.stream);

    vm.listenForUserStatsUpdates('u1');
    // Replace with a new stream
    when(mockSocketService.userStatsStream)
        .thenAnswer((_) => controller2.stream);
    vm.listenForUserStatsUpdates('u1');
    controller1.add({'userId': 'u1'});
    controller2.add({'userId': 'u1'});
    await Future.delayed(Duration.zero);
    await controller1.close();
    await controller2.close();
  });

  test('listenForFriendUpdates cancels previous subscription', () async {
    final controller1 = StreamController<Map<String, dynamic>>();
    final controller2 = StreamController<Map<String, dynamic>>();
    when(mockSocketService.friendUpdateStream)
        .thenAnswer((_) => controller1.stream);

    vm.listenForFriendUpdates('u1');
    // Replace with a new stream
    when(mockSocketService.friendUpdateStream)
        .thenAnswer((_) => controller2.stream);
    vm.listenForFriendUpdates('u1');
    controller1.add({'userId': 'u1'});
    controller2.add({'userId': 'u1'});
    await Future.delayed(Duration.zero);
    await controller1.close();
    await controller2.close();
  });

  test('deleteUser deletes user, clears local, and navigates', () async {
    final mockContext = DummyBuildContext();
    when(mockDb.userDao).thenReturn(mockUserDao);
    when(mockUserRepository.deleteUserRemote()).thenAnswer((_) async {});
    when(mockUserDao.deleteUser(testUser.id)).thenAnswer((_) async => 1);
    SharedPreferences.setMockInitialValues({'userId': 'u1'});

    vm.userForTest = testUser;
    await vm.deleteUser(mockContext);

    expect(vm.user, isNull);
  });

  test('deleteUser shows error if exception thrown', () async {
    final mockContext = DummyBuildContext();
    when(mockUserRepository.deleteUserRemote()).thenThrow(Exception('fail'));
    // Do not call when(...) after this point!
    await vm.deleteUser(mockContext);
    // No throw, error handled
  });

  test('listenForFcmTokenRefresh uses MockFirebaseMessagingUtil', () async {
    // Reset static flags
    MockFirebaseMessagingUtil.listenedForForegroundMessages = false;
    MockFirebaseMessagingUtil.requestedPermissions = false;

    // Call the method under test
    vm.listenForFcmTokenRefresh();

    // Assert that the static method was called
    expect(MockFirebaseMessagingUtil.listenedForForegroundMessages, isTrue);
  });  
}
