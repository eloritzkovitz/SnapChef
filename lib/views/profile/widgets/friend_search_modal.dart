import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/theme/colors.dart';
import '../../../models/user.dart';
import '../../../utils/image_util.dart';
import '../../../viewmodels/friend_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../widgets/search_box.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final currentUserId = userViewModel.user?.id;
      if (currentUserId != null) {
        await Provider.of<FriendViewModel>(context, listen: false)
            .getAllFriendRequests(currentUserId);
        setState(() {});
      }
    });
  }

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

    // Exclude current user from results
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUserId = userViewModel.user?.id;

    try {
      final users = await Provider.of<FriendViewModel>(context, listen: false)
          .searchUsers(_searchQuery);

      setState(() {
        _results = users.where((u) => u.id != currentUserId).toList();
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
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final currentUserId = userViewModel.user?.id;
      if (currentUserId == null) {
        throw Exception('Current user ID is null');
      }
      // Pass userViewModel to sendFriendRequest so it updates user data too
      message = await Provider.of<FriendViewModel>(context, listen: false)
          .sendFriendRequest(userId, currentUserId, userViewModel);
      if (message == null || message.isEmpty) {
        message = 'Friend request sent!';
      }
      if (context.mounted) {
        // After sending, refresh all friend requests and update results
        await Provider.of<FriendViewModel>(context, listen: false)
            .getAllFriendRequests(currentUserId);
      }
      if (context.mounted) {
        await _search(context);
      }
    } catch (e) {
      message = 'Failed to send friend request: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
      // Only show snackbar if still mounted
      if (mounted) {
        // Use parent callback if provided, else fallback to local context
        if (widget.onShowSnackBar != null) {
          widget.onShowSnackBar!(message!);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message!)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentFriends = userViewModel.user?.friends ?? [];
    final currentFriendIds = currentFriends.map((f) => f.id).toSet();
    final pendingRequestUserIds =
        Provider.of<FriendViewModel>(context).pendingRequestUserIds;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBox(
              labelText: 'Search users',
              hintText: 'Enter first, last name or email',
              onChanged: (value) => _onSearchChanged(value, context),
              isLoading: _isLoading,
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
                  final isFriend = currentFriendIds.contains(user.id);
                  final isPending = pendingRequestUserIds.contains(user.id);

                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (user.profilePicture != null &&
                                    user.profilePicture!.isNotEmpty)
                                ? NetworkImage(ImageUtil()
                                    .getFullImageUrl(user.profilePicture!))
                                : const AssetImage(
                                        'assets/images/default_profile.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isFriend)
                            Chip(
                              label: const Text('Friend'),
                              avatar: const Icon(Icons.check,
                                  color: Colors.white, size: 18),
                              backgroundColor: primarySwatch[200],
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                            )
                          else if (isPending)
                            const Chip(
                              label: Text('Pending'),
                              avatar: Icon(Icons.hourglass_top,
                                  color: Colors.orange, size: 18),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                            )
                          else
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _isLoading
                                  ? null
                                  : () => _sendRequest(context, user.id),
                              child: Chip(
                                label: const Text('Add'),
                                avatar: const Icon(Icons.person_add,
                                    color: Colors.blue, size: 18),
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
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
