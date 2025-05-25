import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../viewmodels/friend_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';

class FriendSearchModal extends StatefulWidget {
  final void Function(String message)? onShowSnackBar;
  const FriendSearchModal({super.key, this.onShowSnackBar});

  @override
  State<FriendSearchModal> createState() => _FriendSearchModalState();
}

class _FriendSearchModalState extends State<FriendSearchModal> {
  String _searchQuery = '';
  bool _isLoading = false;
  List<User> _results = [];
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value, BuildContext context) {
    setState(() {
      _searchQuery = value;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchQuery.isNotEmpty) {
        _search(context);
      } else {
        setState(() {
          _results = [];
        });
      }
    });
  }

  // Perform the search operation
  Future<void> _search(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await Provider.of<FriendViewModel>(context, listen: false)
          .searchUsers(_searchQuery);

      // Exclude current user from results
      final currentUserId =
          Provider.of<UserViewModel>(context, listen: false).user?.id;
      final filteredUsers = users.where((u) => u.id != currentUserId).toList();

      setState(() {
        _results = filteredUsers;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Send a friend request to the selected user
  Future<void> _sendRequest(BuildContext context, String userId) async {   
    setState(() {
      _isLoading = true;
      _error = null;
    });
    String? message;
    try {
      message = await Provider.of<FriendViewModel>(context, listen: false)
          .sendFriendRequest(userId);
      if (message == null || message.isEmpty) {
        message = 'Friend request sent!';
      }
    } catch (e) {
      message = 'Failed to send friend request: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      // Use parent callback if provided, else fallback to local context
      if (widget.onShowSnackBar != null) {
        widget.onShowSnackBar!(message!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Search users by name',
                hintText: 'Enter first or last name',
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
              ),
              onChanged: (value) => _onSearchChanged(value, context),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (!_isLoading && _results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : const AssetImage(
                                  'assets/images/default_profile.png')
                              as ImageProvider,
                    ),
                    title: Text(user.fullName),
                    subtitle: Text(user.email),
                    trailing: ElevatedButton(
                      onPressed: _isLoading ? null : () => _sendRequest(context, user.id),
                      child: const Text('Add'),
                    ),
                  );
                },
              ),
            ),
          if (!_isLoading && _results.isEmpty && _searchQuery.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No users found.'),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}