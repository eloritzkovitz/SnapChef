import 'package:flutter/material.dart';
import '../models/friend_request.dart';
import '../models/user.dart';
import '../services/friend_service.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<FriendRequest> _pendingRequests = [];
  List<FriendRequest> _sentRequests = [];
  bool _isLoading = false;
  String? _error;

  List<FriendRequest> get pendingRequests => _pendingRequests;
  List<FriendRequest> get sentRequests => _sentRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// IDs of users you have sent a pending request to
  Set<String> get pendingRequestUserIds => _sentRequests
      .where((req) => req.status == 'pending')
      .map((req) => req.to)
      .toSet();

  /// Fetch all friend requests involving the current user (sent and received)
  Future<void> getAllFriendRequests(String currentUserId) async {
    _setLoading(true);
    try {
      final allRequests = await _friendService
          .getFriendRequests(); // returns all requests involving the user

      // Requests you received (where you are the "to" and still pending)
      _pendingRequests = allRequests
          .where((req) => req.to == currentUserId && req.status == 'pending')
          .toList();

      // Requests you sent (where you are the "from")
      _sentRequests =
          allRequests.where((req) => req.from.id == currentUserId).toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Fetch both on demand (call this in your modal init)
  Future<void> refreshRequests(String currentUserId) async {
    await getAllFriendRequests(currentUserId);
  }

  // Fetch pending friend requests (FutureBuilder)
  Future<List<FriendRequest>> fetchFriendRequests() async {
    return await _friendService.getFriendRequests();
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      return await _friendService.searchUsers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Send a friend request
  Future<String?> sendFriendRequest(String userId, String currentUserId) async {
    try {
      final message = await _friendService.sendFriendRequest(userId);
      // Refresh sent/received requests after sending
      await getAllFriendRequests(currentUserId);
      return message;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 'Failed to send request';
    }
  }

  // Accept or decline a friend request
  Future<void> respondToRequest(
      String requestId, bool accept, String currentUserId) async {
    _setLoading(true);
    try {
      await _friendService.respondToRequest(requestId, accept);
      await getAllFriendRequests(currentUserId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
