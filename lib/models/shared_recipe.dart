import 'recipe.dart';

class SharedRecipe {
  final String id;
  final Recipe recipe;
  final String fromUser;
  final String toUser;
  final DateTime sharedAt;
  final String status;

  SharedRecipe({
    required this.id,
    required this.recipe,
    required this.fromUser,
    required this.toUser,
    required this.sharedAt,
    required this.status,
  });

  factory SharedRecipe.fromJson(Map<String, dynamic> json) {
    return SharedRecipe(
      id: json['_id'] ?? '',
      recipe: Recipe.fromJson(json['recipe']),
      fromUser: json['fromUser'] is Map
          ? json['fromUser']['_id'] ?? ''
          : json['fromUser'] ?? '',
      toUser: json['toUser'] is Map
          ? json['toUser']['_id'] ?? ''
          : json['toUser'] ?? '',
      sharedAt: DateTime.parse(json['sharedAt']),
      status: json['status'] ?? 'pending',
    );
  }
}

class GroupedSharedRecipe {
  final Recipe recipe;
  final List<String> sharedWithUserIds;

  GroupedSharedRecipe({required this.recipe, required this.sharedWithUserIds});
}