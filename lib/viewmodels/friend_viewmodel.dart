import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<Friend> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch friends list
  Future<void> fetchFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _friends = await _friendService.getFriends();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Send a friend request
  Future<void> sendFriendRequest(String friendId) async {
    try {
      await _friendService.sendFriendRequest(friendId);      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove a friend
  Future<void> removeFriend(String friendId) async {
    try {
      await _friendService.removeFriend(friendId);
      _friends.removeWhere((f) => f.id == friendId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }  
}