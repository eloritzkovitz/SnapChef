import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/friend_viewmodel.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    final friendViewModel = Provider.of<FriendViewModel>(context);

    if (friendViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friendViewModel.friends.isEmpty) {
      return const Center(
        child: Text(
          "You don't have any friends yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(      
      itemCount: friendViewModel.friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final friend = friendViewModel.friends[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],           
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: friend.profilePicture != null
                  ? NetworkImage(friend.profilePicture!)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
            ),
            title: Text(
              friend.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              friend.email,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),            
          ),
        );
      },
    );
  }
}