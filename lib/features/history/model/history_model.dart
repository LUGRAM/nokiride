enum HistoryType { trip, delivery, market }
enum HistoryStatus { completed, cancelled, inProgress, pending }

class HistoryModel {
  final String id;
  final String title;           // "Akanda → Charbonnages"
  final String subtitle;        // "Moto-Taxi Standard"
  final String formattedPrice;
  final String formattedDate;   // "Aujourd'hui, 16:42"
  final String groupDate;       // "24 avril 2026"
  final String courierName;
  final String courierVehicle;
  final double courierRating;
  final HistoryType   type;
  final HistoryStatus status;

  const HistoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.formattedPrice,
    required this.formattedDate,
    required this.groupDate,
    required this.courierName,
    required this.courierVehicle,
    required this.courierRating,
    required this.type,
    required this.status,
  });
}
