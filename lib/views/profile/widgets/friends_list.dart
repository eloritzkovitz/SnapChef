import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/user_viewmodel.dart';
import 'friend_search_modal.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

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
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final friend = userViewModel.user?.friends[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: friend != null && friend.profilePicture != null
                        ? NetworkImage(friend.profilePicture!)
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                  ),
                  title: Text(
                    friend?.fullName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    friend?.email ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  onTap: () {
                    // Navigate to friend's profile
                  },
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