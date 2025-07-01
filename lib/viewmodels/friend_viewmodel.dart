import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/base_viewmodel.dart';
import '../models/friend_request.dart';
import '../models/user.dart';
import '../services/friend_service.dart';
import 'user_viewmodel.dart';

class FriendViewModel extends BaseViewModel {
  final FriendService _friendService;
  FriendViewModel({FriendService? friendService})
      : _friendService = friendService ?? FriendService();

  @visibleForTesting
  set sentRequestsForTest(List<FriendRequest> value) => _sentRequests = value;

  List<FriendRequest> _pendingRequests = [];
  List<FriendRequest> _sentRequests = [];  

  List<FriendRequest> get pendingRequests => _pendingRequests;
  List<FriendRequest> get sentRequests => _sentRequests; 

  /// IDs of users you have sent a pending request to
  Set<String> get pendingRequestUserIds => _sentRequests
      .where((req) => req.status == 'pending')
      .map((req) => req.to)
      .toSet();

  /// Fetch all friend requests involving the current user (sent and received)
  Future<void> getAllFriendRequests(String currentUserId) async {
    setLoading(true);
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

      setError(null);
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
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
      setError(e.toString());      
      return [];
    }
  }

  // Send a friend request
  Future<String?> sendFriendRequest(
      String userId, String currentUserId, UserViewModel userViewModel) async {
    try {
      final message = await _friendService.sendFriendRequest(userId);
      // Refresh sent/received requests after sending
      await getAllFriendRequests(currentUserId);
      await userViewModel.fetchUserData();
      return message;
    } catch (e) {
      setError(e.toString());      
      return 'Failed to send request';
    }
  }

  // Cancel a sent friend request
  Future<void> cancelFriendRequest(String requestId, String currentUserId,
      UserViewModel userViewModel) async {
    setLoading(true);
    try {
      await _friendService.cancelSentRequest(requestId);
      await getAllFriendRequests(currentUserId);
      await userViewModel.fetchUserData();
      setError(null);
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  // Accept or decline a friend request
  Future<void> respondToRequest(String requestId, bool accept,
      String currentUserId, UserViewModel userViewModel) async {
    setLoading(true);
    try {
      await _friendService.respondToRequest(requestId, accept);
      await getAllFriendRequests(currentUserId);
      await userViewModel.fetchUserData();
      setError(null);
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  } 

  @override
  void clear() {
    _pendingRequests.clear();
    _sentRequests.clear();
    setError(null);
    setLoading(false);
  } 
}
