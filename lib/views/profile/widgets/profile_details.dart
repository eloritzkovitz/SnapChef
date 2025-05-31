import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/theme/colors.dart';
import '../../../models/user.dart';
import '../../../utils/image_util.dart';
import '../../../utils/ui_util.dart';
import '../../../viewmodels/ingredient_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';

class ProfileDetails extends StatefulWidget {
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

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch stats every time the screen is shown
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.fetchUserStats(userId: widget.user.id);

    final ingredientViewModel =
        Provider.of<IngredientViewModel>(context, listen: false);
    if (ingredientViewModel.ingredients == null &&
        !ingredientViewModel.loading) {
      ingredientViewModel.fetchIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int friendCount = widget.user.friends.length;
    final userStats = Provider.of<UserViewModel>(context).userStats;
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);

    if (userStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ingredientViewModel.ingredients == null ||
        ingredientViewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final int ingredientCount = userStats['ingredientCount'] ?? 0;
    final int recipeCount = userStats['recipeCount'] ?? 0;
    final int favoriteRecipeCount = userStats['favoriteRecipeCount'] ?? 0;
    final int friendCountStat = userStats['friendCount'] ?? friendCount;
    final List<dynamic> mostPopularIngredients =
        userStats['mostPopularIngredients'] ?? [];
    final ingredientMap = ingredientViewModel.ingredientMap ?? {};

    // Function to get the image URL for an ingredient by its name
    String? getIngredientImageUrl(
        String name, Map<String, dynamic> ingredientMap) {
      final lowerName = name.trim().toLowerCase();

      // Only exact match
      final match = ingredientMap[lowerName];
      if (match != null &&
          match['imageURL'] != null &&
          match['imageURL'].toString().isNotEmpty) {
        return match['imageURL'] as String;
      }

      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: widget.user.profilePicture != null
                  ? NetworkImage(
                      ImageUtil().getFullImageUrl(widget.user.profilePicture!))
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
            ),
          ],
        ),
        const SizedBox(height: 30),

        // User Full Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.user.fullName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // User Email and Join Date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
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
                    widget.user.email,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(
                    width: 28,
                    child: Icon(Icons.calendar_today,
                        color: Colors.grey, size: 20),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Joined ${UIUtil.formatDate(widget.user.joinDate)}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- Overview Section ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Overview',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    const Icon(Icons.kitchen,
                        color: Colors.deepOrange, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '$ingredientCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Icon(Icons.menu_book, color: primaryColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '$recipeCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Recipes',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Icon(Icons.favorite, color: primaryColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '$favoriteRecipeCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Favorites',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 36),
                GestureDetector(
                  onTap: widget.friendsClickable ? widget.onFriendsTap : null,
                  child: Column(
                    children: [
                      const Icon(Icons.group, color: Colors.blueGrey, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        '$friendCountStat',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Friends',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // --- Popular Ingredients Section ---
        if (mostPopularIngredients.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Popular Ingredients',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: mostPopularIngredients.map<Widget>((item) {
                        final name = UIUtil().capitalize(item['name'] ?? '');
                        final count = item['count'] ?? 0;
                        final imageURL = getIngredientImageUrl(
                            item['name'] ?? '', ingredientMap);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              imageURL != null && imageURL.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.network(
                                        ImageUtil().getFullImageUrl(imageURL),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.orange[50],
                                          child: const Icon(
                                              Icons.image_not_supported,
                                              size: 32,
                                              color: Colors.orange),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          size: 32,
                                          color: Colors.orange),
                                    ),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '($count)',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}