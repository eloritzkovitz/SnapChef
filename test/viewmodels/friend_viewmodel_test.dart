import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/models/friend_request.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

@GenerateNiceMocks([
  MockSpec<FriendService>(),
  MockSpec<UserViewModel>(),
])
import 'friend_viewmodel_test.mocks.dart';

// Test users
User get testUser => User(
      id: 'u1',
      firstName: 'Alice',
      lastName: 'Tester',
      email: 'alice@example.com',
      fridgeId: 'fridge1',
      cookbookId: 'cookbook1',
    );

User get senderUser => User(
      id: 'u2',
      firstName: 'Bob',
      lastName: 'Sender',
      email: 'bob@example.com',
      fridgeId: 'fridge2',
      cookbookId: 'cookbook2',
    );

// Requests
FriendRequest get pendingRequest => FriendRequest(
      id: 'fr1',
      from: testUser,
      to: 'u2', // This will be in pendingRequests for 'u2'
      status: 'pending',
      createdAt: DateTime.now(),
    );

FriendRequest get sentRequest => FriendRequest(
      id: 'fr2',
      from: senderUser, // This will be in sentRequests for 'u2'
      to: 'u3',
      status: 'pending',
      createdAt: DateTime.now(),
    );

void main() {
  late FriendViewModel vm;
  late MockFriendService mockService;
  late MockUserViewModel mockUserVM;

  setUp(() {
    mockService = MockFriendService();
    mockUserVM = MockUserViewModel();
    vm = FriendViewModel(friendService: mockService);
  });

  test('getAllFriendRequests populates pending and sent requests', () async {
    when(mockService.getFriendRequests()).thenAnswer((_) async => [
          pendingRequest,
          sentRequest,
        ]);
    await vm.getAllFriendRequests('u2');
    expect(vm.pendingRequests.any((r) => r.id == pendingRequest.id), isTrue);
    expect(vm.sentRequests.any((r) => r.id == sentRequest.id), isTrue);
    expect(vm.isLoading, isFalse);
  });

  test('getAllFriendRequests sets error on exception', () async {
    when(mockService.getFriendRequests()).thenThrow(Exception('fail'));
    await vm.getAllFriendRequests('u2');
    expect(vm.isLoading, isFalse);
  });

  test('searchUsers returns users on success', () async {
    when(mockService.searchUsers('Ali')).thenAnswer((_) async => [testUser]);
    final result = await vm.searchUsers('Ali');
    expect(result.length, 1);
    expect(result.first.id, testUser.id);
  });

  test('searchUsers sets error and returns empty on failure', () async {
    when(mockService.searchUsers('Ali')).thenThrow(Exception('fail'));
    final result = await vm.searchUsers('Ali');
    expect(result, isEmpty);
  });

  test('sendFriendRequest calls service and refreshes', () async {
    when(mockService.sendFriendRequest('u2')).thenAnswer((_) async => 'sent');
    when(mockService.getFriendRequests()).thenAnswer((_) async => []);
    when(mockUserVM.fetchUserData()).thenAnswer((_) async {});
    final msg = await vm.sendFriendRequest('u2', 'u1', mockUserVM);
    expect(msg, 'sent');
    verify(mockService.sendFriendRequest('u2')).called(1);
    verify(mockUserVM.fetchUserData()).called(1);
  });

  test('sendFriendRequest sets error on failure', () async {
    when(mockService.sendFriendRequest('u2')).thenThrow(Exception('fail'));
    final msg = await vm.sendFriendRequest('u2', 'u1', mockUserVM);
    expect(msg, 'Failed to send request');
  });

  test('cancelFriendRequest calls service and refreshes', () async {
    when(mockService.cancelSentRequest('fr2')).thenAnswer((_) async {});
    when(mockService.getFriendRequests()).thenAnswer((_) async => []);
    when(mockUserVM.fetchUserData()).thenAnswer((_) async {});
    await vm.cancelFriendRequest('fr2', 'u1', mockUserVM);
    verify(mockService.cancelSentRequest('fr2')).called(1);
    verify(mockUserVM.fetchUserData()).called(1);
    expect(vm.isLoading, isFalse);
  });

  test('cancelFriendRequest sets error on failure', () async {
    when(mockService.cancelSentRequest('fr2')).thenThrow(Exception('fail'));
    await vm.cancelFriendRequest('fr2', 'u1', mockUserVM);
    expect(vm.isLoading, isFalse);
  });

  test('respondToRequest calls service and refreshes', () async {
    when(mockService.respondToRequest('fr1', true)).thenAnswer((_) async {});
    when(mockService.getFriendRequests()).thenAnswer((_) async => []);
    when(mockUserVM.fetchUserData()).thenAnswer((_) async {});
    await vm.respondToRequest('fr1', true, 'u1', mockUserVM);
    verify(mockService.respondToRequest('fr1', true)).called(1);
    verify(mockUserVM.fetchUserData()).called(1);
    expect(vm.isLoading, isFalse);
  });

  test('respondToRequest sets error on failure', () async {
    when(mockService.respondToRequest('fr1', true))
        .thenThrow(Exception('fail'));
    await vm.respondToRequest('fr1', true, 'u1', mockUserVM);
    expect(vm.isLoading, isFalse);
  });

  test('pendingRequestUserIds returns correct user ids', () {
    vm.sentRequestsForTest = [
      FriendRequest(
        id: 'fr3',
        from: testUser,
        to: 'u4',
        status: 'pending',
        createdAt: DateTime.now(),
      ),
      FriendRequest(
        id: 'fr4',
        from: testUser,
        to: 'u5',
        status: 'accepted',
        createdAt: DateTime.now(),
      ),
    ];
    final ids = vm.pendingRequestUserIds;
    expect(ids.contains('u4'), isTrue);
    expect(ids.contains('u5'), isFalse);
  });

  test('fetchFriendRequests returns service result', () async {
    when(mockService.getFriendRequests())
        .thenAnswer((_) async => [pendingRequest]);
    final result = await vm.fetchFriendRequests();
    expect(result, isNotEmpty);
    expect(result.first.id, pendingRequest.id);
  });

  test('clear resets requests, error, and loading', () {
    vm.sentRequestsForTest = [sentRequest];
    vm.pendingRequests.add(pendingRequest);
    vm.setError('some error');
    vm.setLoading(true);

    vm.clear();

    expect(vm.pendingRequests, isEmpty);
    expect(vm.sentRequests, isEmpty);
    expect(vm.isLoading, isFalse);
  });
}
