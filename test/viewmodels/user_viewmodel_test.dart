import 'dart:io';
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
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/models/user.dart' as model;
import 'package:snapchef/models/preferences.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/auth_service.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/user_service.dart';
import '../mocks/mock_socket_service.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<db.AppDatabase>(),
  MockSpec<UserDao>(),
  MockSpec<UserStatsDao>(),
  MockSpec<ConnectivityProvider>(),
  MockSpec<UserRepository>(),
  MockSpec<UserService>(),
  MockSpec<FriendService>(),
])
import 'user_viewmodel_test.mocks.dart';

model.User get testUser => model.User(
      id: 'u1',
      firstName: 'Alice',
      lastName: 'Tester',
      email: 'alice@example.com',
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

  late UserViewModel vm;
  late MockUserRepository mockUserRepository;
  late MockConnectivityProvider mockConnectivity;
  late MockUserService mockUserService;
  late MockFriendService mockFriendService;
  late MockAppDatabase mockDb;
  late MockUserDao mockUserDao;
  late MockUserStatsDao mockUserStatsDao;

  setUp(() {
    GetIt.I.reset();
    mockUserRepository = MockUserRepository();
    mockConnectivity = MockConnectivityProvider();
    mockUserService = MockUserService();
    mockFriendService = MockFriendService();
    mockDb = MockAppDatabase();
    mockUserDao = MockUserDao();
    mockUserStatsDao = MockUserStatsDao();

    // Register dependencies
    GetIt.I.registerSingleton<db.AppDatabase>(mockDb);
    GetIt.I.registerSingleton<ConnectivityProvider>(mockConnectivity);
    GetIt.I.registerSingleton<UserRepository>(mockUserRepository);
    GetIt.I.registerSingleton<UserService>(mockUserService);
    GetIt.I.registerSingleton<FriendService>(mockFriendService);
    GetIt.I.registerSingleton<SocketService>(MockSocketService());

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

  test('updateFcmToken updates token and stores locally', () async {
    when(mockUserRepository.updateFcmTokenRemote(any)).thenAnswer((_) async {});
    when(mockUserRepository.storeUserLocal(any)).thenAnswer((_) async {});
    vm.userForTest = testUser;

    await vm.updateFcmToken('token123');
    expect(vm.user!.fcmToken, 'token123');
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

  test('removeFriend calls service and refreshes', () async {
    when(mockFriendService.removeFriend('u2')).thenAnswer((_) async {});
    when(mockDb.userStatsDao).thenReturn(mockUserStatsDao);
    when(mockUserStatsDao.deleteUserStats('u2')).thenAnswer((_) async {});
    when(mockUserRepository.fetchUserLocal()).thenAnswer((_) async => testUser);

    await vm.removeFriend('u2');
    verify(mockFriendService.removeFriend('u2')).called(1);
    verify(mockUserStatsDao.deleteUserStats('u2')).called(1);
  });
}