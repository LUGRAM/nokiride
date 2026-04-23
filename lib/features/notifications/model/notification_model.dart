enum NotifType { trip, delivery, promo, system }
class NotificationModel {
  final String id, title, body, time;
  final NotifType type;
  final bool isRead;
  const NotificationModel({required this.id, required this.title, required this.body,
    required this.time, required this.type, this.isRead = false});
}
