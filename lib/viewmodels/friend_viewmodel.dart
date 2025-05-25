import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/user.dart';
import '../services/friend_service.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<Friend> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch friends list
  Future<void> fetchFriends() async {
    _setLoading(true);
    try {
      _friends = await _friendService.getFriends();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Fetch pending friend requests (statetful UI)
  Future<void> getFriendRequests() async {
    _setLoading(true);
    try {
      _pendingRequests = await _friendService.getFriendRequests();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
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
  Future<String?> sendFriendRequest(String userId) async {
    try {
      final message = await _friendService.sendFriendRequest(userId);
      return message;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 'Failed to send request';
    }
  }

  // Accept or decline a friend request
  Future<void> respondToRequest(String requestId, bool accept) async {
    _setLoading(true);
    try {
      await _friendService.respondToRequest(requestId, accept);
      await getFriendRequests();
      await fetchFriends();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Remove a friend
  Future<void> removeFriend(String friendId) async {
    _setLoading(true);
    try {
      await _friendService.removeFriend(friendId);
      _friends.removeWhere((f) => f.id == friendId);
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
