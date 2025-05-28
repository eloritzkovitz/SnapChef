import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../utils/image_util.dart';

class ProfileDetails extends StatelessWidget {
  final User user;
  final bool showSettings;
  final bool friendsClickable;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onFriendsTap;

  const ProfileDetails({
    super.key,
    required this.user,
    this.showSettings = false,
    this.friendsClickable = false,
    this.onSettingsTap,
    this.onFriendsTap,
  });

  /// Formats the join date from a raw date string.
  String _formatJoinDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final date = DateTime.parse(rawDate);
      return 'Joined ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int friendCount = user.friends.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [       
        // Profile Picture
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(ImageUtil().getFullImageUrl(user.profilePicture!))
                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
            ),
          ],
        ),
        const SizedBox(height: 30),

        // User Full Name
        Text(
          user.fullName,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // User Email and Join Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 28,
                  child: Icon(Icons.email, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 28,
                  child: Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatJoinDate(user.joinDate),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Friends count (clickable or not)
        Center(
          child: GestureDetector(
            onTap: friendsClickable ? onFriendsTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group, color: Colors.black, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    '$friendCount Friend${friendCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  if (friendsClickable)
                    const Icon(Icons.chevron_right, color: Colors.black54, size: 24),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}