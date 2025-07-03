import 'package:snapchef/models/friend_request.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';

class MockFriendViewModel extends FriendViewModel {
  MockFriendViewModel() : super(friendService: null);

  List<FriendRequest> _testPendingRequests = [];
  List<FriendRequest> _testSentRequests = [];

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
}