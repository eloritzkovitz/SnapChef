class ExpiryNotification {
  final int id;
  final String ingredientName;
  final String body;
  final DateTime scheduledTime;

  ExpiryNotification({
    required this.id,
    required this.ingredientName,
    required this.body,
    required this.scheduledTime,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientName': ingredientName,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }

  // Create from JSON
  factory ExpiryNotification.fromJson(Map<String, dynamic> json) {
    return ExpiryNotification(
      id: json['id'],
      ingredientName: json['ingredientName'],
      body: json['body'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
    );
  }
}