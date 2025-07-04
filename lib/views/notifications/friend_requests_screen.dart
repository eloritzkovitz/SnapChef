import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/friend_request_list_item.dart';
import '../../viewmodels/friend_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/user.dart';

class FriendRequestsScreen extends StatefulWidget {
  final bool skipFetch;
  const FriendRequestsScreen({super.key, this.skipFetch = false});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  bool showSentByMe = false;
  final Map<String, User?> _userCache = {};
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    if (!widget.skipFetch) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      if (userViewModel.user != null) {
        Provider.of<FriendViewModel>(context, listen: false)
            .getAllFriendRequests(userViewModel.user!.id)
            .then((_) => _preloadSentUsers());
      }
    }
  }

  @override
  void didUpdateWidget(covariant FriendRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _preloadSentUsers();
  }

  Future<void> _preloadSentUsers() async {
    setState(() => _loadingUsers = true);
    final friendViewModel =
        Provider.of<FriendViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final sentRequests = friendViewModel.sentRequests
        .where((req) => req.status == 'pending')
        .toList();
    final missingUserIds = sentRequests
        .map((req) => req.to)
        .where((id) => !_userCache.containsKey(id))
        .toSet();
    for (final userId in missingUserIds) {
      final user = await userViewModel.fetchUserProfile(userId);
      _userCache[userId] = user;
    }
    setState(() => _loadingUsers = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer2<UserViewModel, FriendViewModel>(
        builder: (context, userViewModel, friendViewModel, _) {
          final currentUser = userViewModel.user;
          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = showSentByMe
              ? friendViewModel.sentRequests
                  .where((req) => req.status == 'pending')
                  .toList()
              : friendViewModel.pendingRequests;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Requests to me'),
                      selected: !showSentByMe,
                      onSelected: (selected) {
                        if (showSentByMe && selected) {
                          setState(() => showSentByMe = false);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Requests by me'),
                      selected: showSentByMe,
                      onSelected: (selected) {
                        if (!showSentByMe && selected) {
                          setState(() => showSentByMe = true);
                          _preloadSentUsers();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: friendViewModel.isLoading || _loadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : friendViewModel.errorMessage != null
                        ? Center(
                            child: Text(friendViewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red)))
                        : requests.isEmpty
                            ? Center(
                                child: Text(
                                  showSentByMe
                                      ? 'You have not sent any friend requests.'
                                      : 'No friend requests.',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: requests.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final req = requests[index];
                                  if (showSentByMe) {
                                    final user = _userCache[req.to];
                                    if (user == null) {
                                      return _buildCardSkeleton();
                                    }
                                    return FriendRequestListItem(
                                      user: user,
                                      req: req,
                                      showSentByMe: true,
                                      currentUser: currentUser,
                                      friendViewModel: friendViewModel,
                                      userViewModel: userViewModel,
                                      onRefresh: () =>
                                          Provider.of<FriendViewModel>(context,
                                                  listen: false)
                                              .getAllFriendRequests(
                                                  currentUser.id),
                                      preloadSentUsers: _preloadSentUsers,
                                    );
                                  } else {
                                    return FriendRequestListItem(
                                      user: req.from,
                                      req: req,
                                      showSentByMe: false,
                                      currentUser: currentUser,
                                      friendViewModel: friendViewModel,
                                      userViewModel: userViewModel,
                                      onRefresh: () =>
                                          Provider.of<FriendViewModel>(context,
                                                  listen: false)
                                              .getAllFriendRequests(
                                                  currentUser.id),
                                      preloadSentUsers: _preloadSentUsers,
                                    );
                                  }
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 12),
                SizedBox(
                  width: 120,
                  height: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
