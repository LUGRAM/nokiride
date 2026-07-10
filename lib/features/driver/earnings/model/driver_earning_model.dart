class DriverEarningModel {
  const DriverEarningModel({
    required this.tripId,
    required this.date,
    required this.amountFCFA,
    required this.distanceKm,
  });

  final String tripId;
  final DateTime date;
  final int amountFCFA;
  final double distanceKm;

  int get netAmountFCFA => (amountFCFA * 0.85).round();

  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'date': date.toIso8601String(),
        'amount_fcfa': amountFCFA,
        'distance_km': distanceKm,
      };

  factory DriverEarningModel.fromJson(Map<String, dynamic> json) {
    return DriverEarningModel(
      tripId: '${json['trip_id'] ?? ''}',
      date: DateTime.tryParse('${json['date'] ?? ''}') ?? DateTime.now(),
      amountFCFA: int.tryParse('${json['amount_fcfa'] ?? 0}') ?? 0,
      distanceKm: double.tryParse('${json['distance_km'] ?? 0}') ?? 0,
    );
  }
}
