enum HistoryType { trip, delivery }
enum HistoryStatus { completed, cancelled, inProgress }

class HistoryModel {
  final String id, title, subtitle, formattedPrice, formattedDate;
  final HistoryType type;
  final HistoryStatus status;
  const HistoryModel({required this.id, required this.title, required this.subtitle,
    required this.formattedPrice, required this.formattedDate,
    required this.type, required this.status});
}
