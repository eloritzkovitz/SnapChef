import 'package:snapchef/models/friend_request.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

class MockFriendViewModel extends FriendViewModel {
  MockFriendViewModel() : super(friendService: null);

  List<FriendRequest> _testPendingRequests = [];
  List<FriendRequest> _testSentRequests = [];

  // Callbacks for testing
  Future<List<User>> Function(String)? searchUsersCallback;
  Future<String> Function(String, String, UserViewModel)?
      sendFriendRequestCallback;

  void setPendingRequests(List<FriendRequest> requests) {
    _testPendingRequests = requests;
    notifyListeners();
  }

  void setSentRequests(List<FriendRequest> requests) {
    _testSentRequests = requests;
    notifyListeners();
  }

  @override
  List<FriendRequest> get pendingRequests => _testPendingRequests;

  @override
  List<FriendRequest> get sentRequests => _testSentRequests;

  @override
  void clear() {
    _testPendingRequests = [];
    _testSentRequests = [];
    notifyListeners();
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    if (searchUsersCallback != null) {
      return await searchUsersCallback!(query);
    }
    return [];
  }

  @override
  Future<String> sendFriendRequest(
      String userId, String currentUserId, UserViewModel userVm) async {
    if (sendFriendRequestCallback != null) {
      return await sendFriendRequestCallback!(userId, currentUserId, userVm);
    }
    return 'Friend request sent!';
  }

  @override
  Set<String> get pendingRequestUserIds => _testPendingRequests
      .where((req) => req.status == 'pending')
      .map((req) => req.to)
      .toSet();
}
