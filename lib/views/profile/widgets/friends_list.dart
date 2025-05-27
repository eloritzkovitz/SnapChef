import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../public_profile_screen.dart';
import '../widgets/friend_search_modal.dart';
import '../../../viewmodels/user_viewmodel.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

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
  void _openPublicProfile(BuildContext context, user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final friends = userViewModel.user?.friends ?? [];

    if (userViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friends.isEmpty) {
      return Column(
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
                label: const Text('Add Friend'),
                onPressed: () => _openAddFriendModal(context),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 0),
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return GestureDetector(
                onTap: () => _openPublicProfile(context, friend),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: friend.profilePicture != null
                            ? NetworkImage(friend.profilePicture!)
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
                              friend.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              friend.email,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'remove') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Remove Friend'),
                                content: Text(
                                    'Are you sure you want to remove ${friend.fullName}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Remove',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              try {
                                await Provider.of<UserViewModel>(context,
                                        listen: false)
                                    .removeFriend(friend.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${friend.fullName} removed from friends.')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to remove friend: $e')),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.person_remove, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Remove Friend',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
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
              label: const Text('Add Friend'),
              onPressed: () => _openAddFriendModal(context),
            ),
          ),
        ),
      ],
    );
  }
}
