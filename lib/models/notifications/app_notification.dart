abstract class AppNotification {
  int get id;
  String get title;
  String get body;
  DateTime get scheduledTime;

  Map<String, dynamic> toJson();
}