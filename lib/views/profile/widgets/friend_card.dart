import 'package:flutter/material.dart';
import '../../../utils/image_util.dart';

class FriendCard extends StatelessWidget {
  final dynamic friend;
  final VoidCallback onViewProfile;
  final VoidCallback onRemove;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onViewProfile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewProfile,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[200],
              backgroundImage: (friend.profilePicture != null &&
                      friend.profilePicture!.isNotEmpty)
                  ? NetworkImage(
                      ImageUtil().getFullImageUrl(friend.profilePicture!))
                  : const AssetImage('assets/images/default_profile.png'),
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
              onSelected: (value) {
                if (value == 'view') {
                  onViewProfile();
                } else if (value == 'remove') {
                  onRemove();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: const [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text('View Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Remove Friend'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
