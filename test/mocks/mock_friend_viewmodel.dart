import 'dart:async';
import 'package:snapchef/models/friend_request.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

class MockFriendViewModel extends FriendViewModel {
  MockFriendViewModel() : super(friendService: null);

  List<FriendRequest> _testPendingRequests = [];
  List<FriendRequest> _testSentRequests = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Callback fields for test injection
  Future<List<User>> Function(String)? searchUsersCallback;
  Future<String?> Function(String, String, UserViewModel)?
      sendFriendRequestCallback;
  Future<void> Function(String, String, UserViewModel)?
      cancelFriendRequestCallback;
  Future<void> Function(String, bool, String, UserViewModel)?
      respondToRequestCallback;

  // Setters for test control
  void setPendingRequests(List<FriendRequest> requests) {
    _testPendingRequests = requests;
    notifyListeners();
  }

  void setSentRequests(List<FriendRequest> requests) {
    _testSentRequests = requests;
    notifyListeners();
  }

  @override
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  List<FriendRequest> get pendingRequests => _testPendingRequests;

  @override
  List<FriendRequest> get sentRequests => _testSentRequests;

  @override
  Set<String> get pendingRequestUserIds => _testPendingRequests
      .where((req) => req.status == 'pending')
      .map((req) => req.to)
      .toSet();

  @override
  String? get errorMessage => _errorMessage;

  bool get loading => _isLoading;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> getAllFriendRequests(String currentUserId) async {}
  
  List<FriendRequest> getAllFriendRequestsSync() {
    return [..._testPendingRequests, ..._testSentRequests];
  }

  @override
  Future<void> refreshRequests(String currentUserId) async {}

  @override
  Future<List<FriendRequest>> fetchFriendRequests() async {
    return [..._testPendingRequests, ..._testSentRequests];
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    if (searchUsersCallback != null) {
      return await searchUsersCallback!(query);
    }
    return [];
  }

  @override
  Future<String?> sendFriendRequest(
      String userId, String currentUserId, UserViewModel userViewModel) async {
    if (sendFriendRequestCallback != null) {
      return await sendFriendRequestCallback!(
          userId, currentUserId, userViewModel);
    }
    return 'Friend request sent!';
  }

  @override
  Future<void> cancelFriendRequest(String requestId, String currentUserId,
      UserViewModel userViewModel) async {
    if (cancelFriendRequestCallback != null) {
      return await cancelFriendRequestCallback!(
          requestId, currentUserId, userViewModel);
    }
    return;
  }

  @override
  Future<void> respondToRequest(String requestId, bool accept,
      String currentUserId, UserViewModel userViewModel) async {
    if (respondToRequestCallback != null) {
      return await respondToRequestCallback!(
          requestId, accept, currentUserId, userViewModel);
    }
    return;
  }

  @override
  void clear() {
    _testPendingRequests = [];
    _testSentRequests = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
