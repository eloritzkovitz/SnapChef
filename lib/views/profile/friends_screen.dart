import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/search_box.dart';
import '../../widgets/snapchef_appbar.dart';
import 'public_profile_screen.dart';
import 'widgets/friend_card.dart';
import 'widgets/friend_search_modal.dart';
import '../../viewmodels/user_viewmodel.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsScreen> {
  String _searchQuery = '';

  // Opens the modal to add a new friend
  void _openAddFriendModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: FriendSearchModal(
          onShowSnackBar: (msg) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          ),
        ),
      ),
    );
  }

  // Opens the public profile of a user
  void _openPublicProfile(BuildContext context, dynamic friend) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final fullProfile = await userViewModel.fetchUserProfile(friend.id);

    if (fullProfile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicProfileScreen(user: fullProfile),
        ),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    }
  }

  // Shows a confirmation dialog to remove a friend
  Future<void> _showRemoveFriendDialog(
      BuildContext context, dynamic friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove ${friend.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<UserViewModel>(context, listen: false)
            .removeFriend(friend.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${friend.fullName} removed from friends.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove friend: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final friends = userViewModel.user?.friends ?? [];
    final isOffline = userViewModel.connectivityProvider.isOffline;

    if (userViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter friends by search query
    final filteredFriends = friends.where((friend) {
      return friend.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return BaseScreen(
        appBar: SnapChefAppBar(
          title: const Text(
            'Friends',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SafeArea(
  child: RefreshIndicator(
    onRefresh: () async {
      await Provider.of<UserViewModel>(context, listen: false).fetchUserData();
    },
    child: Column(
      children: [
        Material(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SearchBox(
                  labelText: 'Search friends...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  isLoading: false,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: friends.isEmpty
              ? Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          "You don't have any friends yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Friends'),
                          onPressed: isOffline
                              ? null
                              : () => _openAddFriendModal(context),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredFriends.isEmpty
                          ? const Center(
                              child: Text(
                                "No friends found.",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(top: 0),
                              itemCount: filteredFriends.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final friend = filteredFriends[index];
                                return FriendCard(
                                  friend: friend,
                                  onViewProfile: () =>
                                      _openPublicProfile(context, friend),
                                  onRemove: () => _showRemoveFriendDialog(
                                      context, friend),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Friends'),
                          onPressed: isOffline
                              ? null
                              : () => _openAddFriendModal(context),
                        ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}  
